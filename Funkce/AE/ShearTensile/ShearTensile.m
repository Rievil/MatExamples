classdef ShearTensile < handle
    properties
        HitCount;
        HitDuration;
        HitRiseTime;
        HitAmplitude;
        Weight;
        WSet=false;
        AvgFreq;
        RAVal;
        Loc;
        ValSet=false;
        XLine;
        YLine;
        LineSet=false;
        Idx;
        Parent;
        ParentSet=false;
        RunSet=false;
        Label;
        Ax;
        AxSet=false;
        Cloud;
        Centers;
        AlphaCh=false;
        CloudAlpha=1;
    end
    
    properties
        Param struct;
    end
    
    methods
        function obj=ShearTensile(~)

        end
        
        function SetWeight(obj,w)
            obj.Weight=w;
            obj.WSet=true;
        end
        
        function DataFromVal(obj,raval,avgfreq)
            obj.AvgFreq=avgfreq;
            obj.RAVal=raval;
            if numel(obj.Param)>0
                obj.Param=[];
            end
            obj.ValSet=true;
        end
        
        function SetParent(obj,parent)
            obj.Parent=parent;
            obj.ParentSet=true;
        end
        
        function SetLabel(obj,label)
            obj.Label=label;
        end
        
        function SetLocation(obj,loc)
            obj.Loc=loc;
        end
        
        function [xlim,ylim]=GetLim(obj)
            xlim=[min(obj.RAVal),max(obj.RAVal)];
            ylim=[min(obj.AvgFreq),max(obj.AvgFreq)];
        end
        
        function DataFromParam(obj,hitcount,hitduration,hitrisetime,hitamplitude)
            obj.AvgFreq=[];
            obj.RAVal=[];
            
            obj.HitCount=hitcount;
            obj.HitDuration=hitduration;
            obj.HitRiseTime=hitrisetime;
            obj.HitAmplitude=hitamplitude;
            
            obj.AvgFreq=obj.HitCount./(obj.HitDuration.*1e-9);
            obj.RAVal=obj.HitRiseTime./obj.HitAmplitude.*1e-7;
            
            DataFromVal(obj,obj.RAVal,obj.AvgFreq);
        end
        
        function Calculate(obj)
            obj.Param=struct;
            obj.Param.XSM=median(obj.RAVal(obj.Idx));
            obj.Param.YSM=median(obj.AvgFreq(obj.Idx));
            obj.Param.XTM=median(obj.RAVal(~obj.Idx));
            obj.Param.YTM=median(obj.AvgFreq(~obj.Idx));
        end
        
        function plot(obj,type)
%             if obj.RunSet==false
            obj.Run;
%             end
            
            if obj.ParentSet==true            
                obj.Ax=obj.Parent.Ax;
                obj.AxSet=true;
            end
            
            switch type
                case 'centers'
                    PlotCenters(obj)
                case 'cloud'
                    PlotCloud(obj);
                case 'both'
                    PlotCloud(obj);
                    PlotCenters(obj);
            end
            
        end
        
        function SetColorCenter(obj,tcol,scol)
            obj.Centers{1}.MarkerFaceColor=tcol;
            obj.Centers{2}.MarkerFaceColor=scol;
        end
        
        function SetColorCloud(obj,tcol,scol)
            obj.Cloud{1}.MarkerFaceColor=tcol;
            obj.Cloud{2}.MarkerFaceColor=scol;
        end
        
        function SetColor(obj,tcol,scol)
                SetColorCenter(obj,tcol,scol);
                SetColorCloud(obj,tcol,scol);
        end
        
        function SetGUIParams(obj,varargin)

            while numel(varargin)>0
                switch lower(varargin{1})
                    case 'alpha'
                        obj.AlphaCh=true;
                        obj.CloudAlpha=varargin{2};
                    case 'colortype'
                        
                    otherwise

                end
                varargin(1:2)=[];
            end
        end

        function PlotCloud(obj)
            obj.Cloud{1}=scatter(obj.Ax,obj.RAVal(obj.Idx),obj.AvgFreq(obj.Idx),'o','filled','HandleVisibility','off',...
                'MarkerFaceAlpha',obj.CloudAlpha,'MarkerEdgeAlpha',obj.CloudAlpha);
            obj.Cloud{2}=scatter(obj.Ax,obj.RAVal(~obj.Idx),obj.AvgFreq(~obj.Idx),'o','filled','HandleVisibility','off',...
                'MarkerFaceAlpha',obj.CloudAlpha,'MarkerEdgeAlpha',obj.CloudAlpha);
            
            if obj.WSet
                obj.Cloud{1}.SizeData =obj.Weight(obj.Idx);
                obj.Cloud{2}.SizeData =obj.Weight(~obj.Idx);
            end
            
            if obj.AlphaCh
                obj.Cloud{1}.MarkerFaceAlpha=0.2;
                obj.Cloud{2}.MarkerFaceAlpha=0.2;
            else
                obj.Cloud{1}.MarkerFaceAlpha=1;
                obj.Cloud{2}.MarkerFaceAlpha=1;
            end
        end
        
        function PlotCenters(obj)
            obj.Centers{1}=scatter(obj.Ax,obj.Param.XSM,obj.Param.YSM,80,'^','filled','DisplayName',sprintf('S, %s',obj.Label),...
                'MarkerEdgeColor','k');
            obj.Centers{2}=scatter(obj.Ax,obj.Param.XTM,obj.Param.YTM,80,'v','filled','DisplayName',sprintf('T, %s',obj.Label),...
                'MarkerEdgeColor','k');
        end
        
        
        function Run(obj)
            
%             if obj.LineSet==false && obj.ParentSet==true
%             [x,y]=obj.Parent.GetLine(max(obj.RAVal));
            GenerateLine(obj.Parent);
            SetLine(obj,obj.Parent.XLine,obj.Parent.YLine);
%             end
            
            if obj.LineSet==true && obj.ValSet==true
                CheckDivision(obj);
                Calculate(obj);
            end
            obj.RunSet=true;
        end
        
        
        function SetLine(obj,x,y)
            
            obj.XLine=x;
            obj.YLine=y;
            obj.LineSet=true;
        end
            
        
        function CheckDivision(obj)
            obj.Idx = inpolygon(obj.RAVal,obj.AvgFreq,[0 ; obj.XLine'; max(obj.XLine)],[ 0 ; obj.YLine' ; 0]) ;
        end
    end
end