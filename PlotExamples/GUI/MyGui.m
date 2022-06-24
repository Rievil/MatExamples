classdef MyGui < handle
    properties
        Num=50;
        UIFig;
        Slider;
        EditField;
    end

    methods
        function obj=MyGui(obj)
            DrawGui(obj);
        end
    end

    methods (Access=private)
        function DrawGui(obj)
            obj.UIFig=uifigure('position',[200,200,500,250]);
            g=uigridlayout(obj.UIFig);
            g.RowHeight = {60};
            g.ColumnWidth = {'1x','2x'};

            obj.Slider = uislider(g,"Limits",[0,100],"Value",obj.Num,"ValueChangingFcn",@obj.SliderChange);
            obj.Slider.Layout.Row=1;
            obj.Slider.Layout.Column=2;

            obj.EditField = uieditfield(g,'numeric','Value',obj.Num,...
                'ValueChangedFcn',@obj.EditFieldChange,...
                'ValueDisplayFormat','%d','RoundFractionalValues','on');
            obj.EditField.Layout.Row=1;
            obj.EditField.Layout.Column=1;
        end
        function SliderChange(obj,src,evnt)
            obj.Num=evnt.Value;
            obj.EditField.Value=obj.Num;
            ReturnResult(obj);
        end

        function EditFieldChange(obj,src,evnt)
            if src.Value>0 && src.Value <=100
                obj.Num=src.Value;
                obj.Slider.Value=obj.Num;
                ReturnResult(obj);
            else
                uialert(obj.UIFig,sprintf("Value %0.2f must be in limits [0,100]!",src.Value),'Out of limits');
            end
        end

        function ReturnResult(obj)
            assignin("base","result",obj.Num);
        end
    end
end