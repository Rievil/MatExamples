classdef ShearTensileGui < Handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Ax;
        AxSet=false;
        Fig;
        FigSet=false;
        CloseCallBackSet=false;
    end

    methods
        function obj = ShearTensileGui(~)
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

        function SetFig(obj)
            fig=figure('CloseRequestFcn',@obj.CloseFigure);
            obj.CloseCallBackSet=true;
            obj.Fig=fig;
            
            obj.FigSet=true;
            ax=gca;
            hold(ax,'on');
            obj.SetAx(ax);
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