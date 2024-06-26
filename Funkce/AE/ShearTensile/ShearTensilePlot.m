classdef ShearTensilePlot < handle
    %SHEARTENSILEPLOT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        DataSets ShearTensile;
        STEstimator;
        XLine;
        YLine;
        LineFunction;
        LineSet=false;
        Ax;
        AxSet=false;
        Fig;
        FigSet=false;
        CloseCallBackSet=false;
        Red;
        XLim=[0,0];
        YLim=[0,0];
        Alpha;
        Beta;
        MaxXLim=0;
        MaxYLim=0;
        Latex=false;

    end
    
    properties (Dependent)
        Count;
    end
    
    properties (SetAccess=private)
        GUIHan;
    end

    methods
        function obj = ShearTensilePlot(~)
            obj.STEstimator=ShearEstimator(obj);
        end
        
        function UpdateSet(obj,set,id)
            arguments
                obj ShearTensilePlot
                set ShearTensile
                id int64
            end
            
            if id>0
                set.SetParent(obj);
                obj.DataSets(id)=set;
            elseif isempty(id)
                set.SetParent(obj);
                obj.DataSets(1)=set;
            end
            
        end

        function AddSet(obj,set)
            set.SetParent(obj);
            obj.DataSets(obj.Count+1)=set;
        end
        
        function SetAx(obj,ax)
            obj.Ax=ax;
            obj.Fig=ax.Parent;
            
            obj.FigSet=true;
            obj.AxSet=true;
            
            if obj.CloseCallBackSet==false
                obj.Fig.CloseRequestFcn=@obj.CloseFigure;
                obj.CloseCallBackSet=true;
            end
        end
        
        function SetLine(obj)
            if ~obj.LineSet
                SetLim(obj);
                [x,y]=GetLine(obj);
                obj.YLine=y;
                obj.XLine=x;
                obj.LineSet=true;
            end
        end
        
        function [x,y]=GetLine(obj)
            x=linspace(obj.XLim(1),obj.XLim(2),10e+3);
            y=x.*obj.Alpha;
            obj.YLine=y;
            obj.XLine=x;
        end
        
        function CalculateLine(obj,type,varargin)
            switch type
                case 'cetris_b'
                    obj.Alpha=538;
                case 'cetris'
                    obj.Alpha=40;
                case 'concrete'
                    obj.Alpha=40;
                case '3DPrintedContrete'
                    obj.Alpha=260;
                case 'custom'
                    obj.Alpha=varargin{1};
            end
            obj.Beta=0;
            obj.LineFunction=@(x) x*obj.Alpha+obj.Beta;
        end
        
        function RemoveSet(obj,idx)
            if idx<=obj.Count && idx>=0
                obj.Count(idx)=[];
            end
        end
        
        function count=get.Count(obj)
            count=numel(obj.DataSets);
        end
        
        function SetFig(obj)
            fig=figure('CloseRequestFcn',@obj.CloseFigure);
            obj.CloseCallBackSet=true;
            obj.Fig=fig;
            
            obj.FigSet=true;
            ax=gca;
            hold(ax,'on');
            obj.SetAx(ax);
        end
        
        function set_xlim(obj,xlimarr)
            obj.XLim=xlimarr;
            xlim(obj.Ax,xlimarr);
            UpdateGUI(obj);
        end

        function set_ylim(obj,ylimarr)
            obj.YLim=ylimarr;
            ylim(obj.Ax,ylimarr);
            UpdateGUI(obj);
        end

        function SetLim(obj)
            for i=1:obj.Count
                [xlim,ylim]=GetLim(obj.DataSets(i));
                
                if xlim(1)<obj.XLim(1)
                    obj.XLim(1)=xlim(1);
                end
                
                if xlim(2)>obj.XLim(2)
                    obj.XLim(2)=xlim(2);
                end
                
                if ylim(1)<obj.YLim(1)
                    obj.YLim(1)=ylim(1);
                end
                
                if ylim(2)>obj.YLim(2)
                    obj.YLim(2)=ylim(2);
                end
            end
        end
        
        function Run(obj)
            obj.XLim=[1000,0];
            obj.YLim=[1000,0];
            SetLim(obj);
            SetLine(obj);
            for i=1:obj.Count
                Run(obj.DataSets(i));
            end
        end

        function GenerateLine(obj)
            if obj.Count>0
                % obj.XLim=[inf,0];
                % obj.YLim=[inf,0];
                SetLim(obj);
                SetLine(obj);
            end
        end
        
        function plot(obj,varargin)
            if obj.AxSet==false
                SetFig(obj);
            end
            Run(obj);
            colset=false;
            seltype=false;

            while numel(varargin)>0
                switch lower(varargin{1})
                    case 'latex'
                        obj.Latex=varargin{2};
                    case 'alpha'
                        alpha=true;
                        alphaval=varargin{2};
                    case 'colortype'
                        switch lower(varargin{2})
                            case 'basic'
                                tcol=winter(obj.Count);
                                scol=spring(obj.Count);
                            case 'bicolor'
                                scol=zeros(obj.Count,3);
                                scol(:,1)=linspace(1,0.3,obj.Count);
                                scol(:,2)=0.3;
                                scol(:,3)=linspace(1,0.7,obj.Count);
                                
                                tcol=zeros(obj.Count,3);
                                tcol(:,1)=0;
                                tcol(:,2)=linspace(1,0.3,obj.Count);
                                tcol(:,3)=linspace(1,0.7,obj.Count);
                        end
                        colset=true;
                    case 'type'
                        seltype=true;
                        type=varargin{2};
                end
                varargin(1:2)=[];
            end
            
            rcol=linspace(0.5,1,obj.Count);
            
            GenerateLine(obj);
            
            if ~colset
                tcol=lines(obj.Count);
                scol=tcol;
            end

            if ~alpha
                alphaval=0.2;
            end

            if ~seltype
                type='both';
            end

            for i=1:obj.Count
                SetGUIParams(obj.DataSets(i),'Alpha',alphaval);
                
                plot(obj.DataSets(i),type);

                switch type
                    case 'cloud'
                        SetColorCloud(obj.DataSets(i),tcol(i,:),scol(i,:));
                    case 'centers'
                        SetColorCenter(obj.DataSets(i),tcol(i,:),scol(i,:));
                    case 'both'
                        SetColor(obj.DataSets(i),tcol(i,:),scol(i,:));
                end
            end
            
            
            switch type
                case 'cloud'
                    obj.GetLimits('cloud');
                case 'centers'
                    obj.GetLimits('center');
                case 'both'
                    obj.GetLimits('cloud');
            end

            if ~strcmp(type,'cloud')
                for i=1:obj.Count
                    uistack(obj.DataSets(i).Centers{1},'top' );
                    uistack(obj.DataSets(i).Centers{2},'top' );
                end
            end

            set(obj.Ax,'XScale','log');
            set(obj.Ax,'YScale','log');
            
            DrawAnnotation(obj);
            SetLim(obj);
            xlim(obj.Ax,obj.XLim);
            ylim(obj.Ax,obj.YLim);
            
        end
        
        function RunDivision(obj)
            for st=obj.DataSets
                st.Run;
            end
        end

        function ShowLegend(obj,varargin)
            if obj.Latex
                lgd=legend(varargin{:},'Interpreter','latex','location','best');
            else
                lgd=legend(varargin{:},'location','best');
            end
            lgd.FontSize=8;
            lgd.NumColumns=2;
            lgd.EdgeColor='none';
            lgd.Color='none';
        end
        
        function GetLimits(obj,type)
            xsmax=0;
            ysmax=0;
            xtmax=0;
            ytmax=0;

            xsmin=20e+10;
            ysmin=20e+10;
            xtmin=20e+10;
            ytmin=20e+10;
            switch type
                case 'center'
                    for i=1:obj.Count
                        %max
                        if max(obj.DataSets(i).Param.XSM)>xsmax
                            xsmax=max(obj.DataSets(i).Param.XSM);
                        end
                        
                        if max(obj.DataSets(i).Param.YSM)>ysmax
                            ysmax=max(obj.DataSets(i).Param.YSM);
                        end
                        
                        if max(obj.DataSets(i).Param.XTM)>xtmax
                            xtmax=max(obj.DataSets(i).Param.XTM);
                        end
                        
                        if max(obj.DataSets(i).Param.YTM)>ytmax
                            ytmax=max(obj.DataSets(i).Param.YTM);
                        end
                        
                        %min
                        if min(obj.DataSets(i).Param.XSM)<xsmin
                            xsmin=min(obj.DataSets(i).Param.XSM);
                        end
                        
                        if min(obj.DataSets(i).Param.YSM)<ysmin
                            ysmin=min(obj.DataSets(i).Param.YSM);
                        end
                        
                        if min(obj.DataSets(i).Param.XTM)<xtmin
                            xtmin=min(obj.DataSets(i).Param.XTM);
                        end
                        
                        if min(obj.DataSets(i).Param.YTM)<ytmin
                            ytmin=min(obj.DataSets(i).Param.YTM);
                        end
                        
                    end
                    
                    
                    
                case 'cloud'
                    for i=1:obj.Count
                        %max§
                        idx=obj.DataSets(i).Idx;
                        if max(obj.DataSets(i).Param.XSM)>xsmax
                            xsmax=max(obj.DataSets(i).RAVal(idx));
                        end
                        
                        if max(obj.DataSets(i).Param.YSM)>ysmax
                            ysmax=max(obj.DataSets(i).AvgFreq(idx));
                        end
                        
                        if max(obj.DataSets(i).Param.XTM)>xtmax
                            xtmax=max(obj.DataSets(i).RAVal(~idx));
                        end
                        
                        if max(obj.DataSets(i).Param.YTM)>ytmax
                            ytmax=max(obj.DataSets(i).AvgFreq(~idx));
                        end
                        
                        %min
                        if min(obj.DataSets(i).Param.XSM)<xsmin
                            xsmin=min(obj.DataSets(i).RAVal(idx));
                        end
                        
                        if min(obj.DataSets(i).Param.YSM)<ysmin
                            ysmin=min(obj.DataSets(i).AvgFreq(idx));
                        end
                        
                        if min(obj.DataSets(i).Param.XTM)<xtmin
                            xtmin=min(obj.DataSets(i).RAVal(~idx));
                        end
                        
                        if min(obj.DataSets(i).Param.YTM)<ytmin
                            ytmin=min(obj.DataSets(i).AvgFreq(~idx));
                        end
                        
                    end
                    
            end
            
            if obj.MaxXLim==0
                obj.XLim=[0,max([xsmax,xtmax])*1.5];
            else
                obj.XLim=[0,obj.MaxXLim];
            end
            
            if obj.MaxYLim==0
                obj.YLim=[ysmin*0.9,max([ysmax,ytmax])*1.1];
            else
                obj.YLim=[ysmin*0.9,obj.MaxYLim];
            end
        end
        
        
        function DrawAnnotation(obj)
            ax=obj.Ax;
            obj.Red=[0.70 0.80];

            lineHandle=plot(obj.Ax,obj.XLine,obj.YLine,'-k','HandleVisibility','off');
            
            tx(1)=text(ax,[.05],[.1],'Intermediate damage','Units','normalized','FontName','Palatino linotype');
            tx(2)=text(ax,[.05],[.95],'High damage','Units','normalized','FontName','Palatino linotype');
            tx(3)=text(ax,[.95],[.1],'Low damage','Units','normalized','HorizontalAlignment','right','FontName','Palatino linotype');
            tx(4)=text(ax,[.95],[.95],'Intermediate damage','Units','normalized','HorizontalAlignment','right','FontName','Palatino linotype');
            

            
            idx=find(obj.YLine>=(obj.YLim(2)-obj.YLim(1))*1/5,1,'first');
            if isempty(idx)
                idx=int32(numel(obj.XLine)/2);
            end

            if obj.Latex
                STR={'$\leftarrow Tensile crack$','$Shear crack \rightarrow$'};
                tx(5)=text(ax,obj.XLine(idx)*obj.Red(1),obj.YLine(idx)*obj.Red(2),STR{1},'HorizontalAlignment','right','FontSize',8,...
                'FontName','cmr12','FontWeight','bold','interpreter','latex');

                tx(6)=text(ax,obj.XLine(idx),obj.YLine(idx)*obj.Red(2),STR{2},'HorizontalAlignment','left',...
                    'FontSize',8,'interpreter','latex',...
                    'FontName','cmr12','FontWeight','bold');
            else
                STR={'\leftarrow Tensile crack','Shear crack \rightarrow'};
                tx(5)=text(ax,obj.XLine(idx)*obj.Red(1),obj.YLine(idx)*obj.Red(2),STR{1},'HorizontalAlignment','right','FontSize',8,...
                'FontName','Palatino linotype','FontWeight','bold');

                tx(6)=text(ax,obj.XLine(idx),obj.YLine(idx)*obj.Red(2),STR{2},'HorizontalAlignment','left',...
                    'FontSize',8,...
                    'FontName','Palatino linotype','FontWeight','bold');
            end
            
            
            [x,y]=GetLine(obj);
            ar=area(x,y,'FaceAlpha',0.2,'FaceColor',[0.6 0.6 .6],'HandleVisibility','off','EdgeColor','non');
            uistack(ar,'bottom');
            
            xlabel(ax,'Rise angle [s/V]','FontName','Palatino linotype');
            ylabel(ax,'Average freqeuncy [Hz]','FontName','Palatino linotype');
            
            if obj.Latex
                for i=1:numel(tx)
                    STR={'$\leftarrow Tensile crack$','$Shear crack \rightarrow$'};
                    switch i
                        case 5
                            set(tx(i),'interpreter','latex','FontName','cmr12','String',STR{1});
                        case 6
                            set(tx(i),'interpreter','latex','FontName','cmr12','String',STR{2});
                        otherwise
                            set(tx(i),'interpreter','latex','FontName','cmr12');
                    end
                end
            end
            
            if obj.Latex
                str=sprintf("Coefficient $\\alpha$: $%0.0f$ V $\\cdot s^{-2}$",obj.Alpha);
                tx(7)=text(ax,0.7,-0.09,str,...
                'Units','normalized','HorizontalAlignment','left','Interpreter','latex');
            else

                tx(7)=text(ax,0.7,-0.09,sprintf("\alpha: %0.0f V \cdot s^{-2}",obj.Alpha),...
                    'Units','normalized','HorizontalAlignment','left','FontName','Palatino linotype');
            end

            han=struct;
            han.Line=lineHandle;
            han.DamageText=tx(1:4);
            han.ArrowLeft=tx(5);
            han.ArrowRight=tx(6);
            han.Area=ar;
            obj.GUIHan=han;
        end

        function UpdateGUI(obj)
            han=obj.GUIHan;
            GetLine(obj);
            set(han.Line,'XData',obj.XLine,'YData',obj.YLine);
            set(han.Area,'XData',obj.XLine,'YData',obj.YLine);

            idx=find(log(obj.XLine)>=log(mean(obj.XLine)*0.01),1,'first');

            % if isempty(idx)
            %     idx=int32(numel(obj.XLine)/2);
            % end

            set(han.ArrowLeft,'position',[obj.XLine(idx)*obj.Red(1),obj.YLine(idx)*obj.Red(2)]);
            set(han.ArrowRight,'position',[obj.XLine(idx),obj.YLine(idx)*obj.Red(2)]);
        end

    end
    
    methods %callbacks
        function CloseFigure(obj,src,evnt)
            obj.FigSet=false;
            obj.AxSet=false;
            delete(obj.Fig);
            obj.Fig=[];
            obj.Ax=[];
            obj.CloseCallBackSet=false;
            
        end
    end
end

