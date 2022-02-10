classdef ShearTensilePlot < handle
    %SHEARTENSILEPLOT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        DataSets ShearTensile;
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
        XLim=[inf,0];
        YLim=[inf,0];
        Alpha;
        Beta;
        MaxXLim=0;
        MaxYLim=0;
    end
    
    properties (Dependent)
        Count;
    end
    
    methods
        function obj = ShearTensilePlot(~)
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
%         
r

        function AddSet(obj,set)
            set.SetParent(obj);
            obj.DataSets(obj.Count+1)=set;
%             set.Run;
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
                [x,y]=GetLine(obj);
                obj.YLine=y;
                obj.XLine=x;
                obj.LineSet=true;
            end
        end
        
        function [x,y]=GetLine(obj)
            x=linspace(obj.XLim(1),obj.XLim(2),10e+3);
            y=x.*obj.Alpha;
        end
        
        function CalculateLine(obj,type)
            switch type
                case 'cetris'
                    obj.Alpha=40;
                case 'concrete'
                    obj.Alpha=40;
                case '3DPrintedContrete'
                    obj.Alpha=260;
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
        
        function SetLim(obj)
%             xlimTmp=[inf,0];
%             ylimTmp=[inf,0];
            for i=1:obj.Count
                [xlim,ylim]=GetLim(obj.DataSets(i));
                
                if obj.XLim(1)>xlim(1)
                    obj.XLim(1)=xlim(1);
                end
                
                if obj.XLim(2)<xlim(2)
                    obj.XLim(2)=xlim(2);
                end
                
                if obj.YLim(1)>ylim(1)
                    obj.YLim(1)=ylim(1);
                end
                
                if obj.YLim(2)<ylim(2)
                    obj.YLim(2)=ylim(2);
                end
            end
        end
        
        function Run(obj)
            obj.XLim=[inf,0];
            obj.YLim=[inf,0];
            SetLim(obj);
            SetLine(obj);
            for i=1:obj.Count
                Run(obj.DataSets(i));
            end
        end
        
        function plot(obj,type)
            if obj.AxSet==false
%                 SetFig(obj);
            end
            
            obj.Ax=gca;
            
            rcol=linspace(0.5,1,obj.Count);
            
            if obj.Count>0
                obj.XLim=[inf,0];
                obj.YLim=[inf,0];
                SetLim(obj);
                SetLine(obj);
            end
            
            tcol=lines(obj.Count);
            scol=tcol;
            
            for i=1:obj.Count
                
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
            
            
            for i=1:obj.Count
                uistack(obj.DataSets(i).Centers{1},'top' );
                uistack(obj.DataSets(i).Centers{2},'top' );
            end
            
            
            set(obj.Ax,'XScale','log');
%             set(obj.Ax,'YScale','log');
            
            DrawAnnotation(obj);
            
            
        end
        
        function ShowLegend(obj)
            lgd=legend('location','southoutside','Orientation','horizontal');
            lgd.FontSize=8;
            lgd.NumColumns=2;
            lgd.EdgeColor='none';
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
                obj.XLim=[min([xsmin,xtmin])*0.5,max([xsmax,xtmax])*1.5];
            else
                obj.XLim=[0,obj.MaxXLim];
            end
            
            if obj.MaxYLim==0
                obj.YLim=[0,max([ysmax,ytmax])*1.1];
            else
                obj.YLim=[0,obj.MaxYLim];
            end
%             obj.XLim
        end
        
        
        function DrawAnnotation(obj)
            ax=obj.Ax;
            obj.Red=[0.70 0.80];
            
%             [x,y]=GetLine(obj,obj.XLim(2));
            plot(obj.Ax,obj.XLine,obj.YLine,'-k','HandleVisibility','off');
            
            tx(1)=text(ax,[.05],[.1],'Intermediate damage','Units','normalized','FontName','Palatino linotype');
            tx(2)=text(ax,[.05],[.95],'High damage','Units','normalized','FontName','Palatino linotype');
            tx(3)=text(ax,[.95],[.1],'Low damage','Units','normalized','HorizontalAlignment','right','FontName','Palatino linotype');
            tx(4)=text(ax,[.95],[.95],'Intermediate damage','Units','normalized','HorizontalAlignment','right','FontName','Palatino linotype');
            
%             xlabel('Rise angle [ms/V]');
%             ylabel('Average frequency [Hz]');
            
            idx=find(obj.YLine>(obj.YLim(2)-obj.YLim(1))*2/3,1,'first');
            STR={'\leftarrow Tensile crack','Shear crack \rightarrow'};
            tx(5)=text(ax,obj.XLine(idx)*obj.Red(1),obj.YLine(idx)*obj.Red(2),STR{1},'HorizontalAlignment','right','FontSize',8,...
                'FontName','Palatino linotype','FontWeight','bold');

            tx(6)=text(ax,obj.XLine(idx),obj.YLine(idx)*obj.Red(2),STR{2},'HorizontalAlignment','left',...
                'FontSize',8,...
                'FontName','Palatino linotype','FontWeight','bold');
            
            [x,y]=GetLine(obj);
            ar=area(x,y,'FaceAlpha',0.2,'FaceColor',[0.6 0.6 .6],'HandleVisibility','off','EdgeColor','non');
            uistack(ar,'bottom');
            
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

