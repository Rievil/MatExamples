classdef CadShape <handle
    properties
        IT table;
        Cordinates table;
        SZ;
        Polygon;
        Points table;
        PCount=0;
        Closed=true;
    end
    
    methods
        function obj=CadShape(it)
            obj.IT=it;
            obj.SZ=size(obj.IT);
            idx=1:1:obj.SZ(1);
            idx=idx';
            obj.IT.Index=idx;

            obj.IT.StartCheck(:)=false;
            obj.IT.EndCheck(:)=false;

            LoopShape(obj);
            obj.Polygon = polyshape(obj.Cordinates.x,obj.Cordinates.y);
        end

        function LoopShape(obj)
            idx=1;

            while sum(obj.IT.Check)<obj.SZ(1)
                obj.IT.Check(idx)=true;
%                 Ti=obj.IT(obj.IT.Index==idx,:);
                if idx==1
                    obj.IT.StartCheck(idx)=true;
                    Ti=obj.IT(obj.IT.Index==idx,:);
                    obj.Cordinates=[obj.Cordinates;...
                        table(Ti.("Start X"),Ti.("Start Y"),'VariableNames',{'x','y'})];
                else
                    switch side
                        case 0
                            obj.IT.StartCheck(idx)=true;
                            Ti=obj.IT(obj.IT.Index==idx,:);
                            obj.Cordinates=[obj.Cordinates;...
                                table(Ti.("Start X"),Ti.("Start Y"),'VariableNames',{'x','y'})];
                        case 1
                            obj.IT.EndCheck(idx)=true;
                            Ti=obj.IT(obj.IT.Index==idx,:);
                            obj.Cordinates=[obj.Cordinates;...
                                table(Ti.("End X"),Ti.("End Y"),'VariableNames',{'x','y'})];
                    end
                end
                [idx,side]=FindFriend(obj,Ti);
            end
            if obj.Closed
                obj.Cordinates=[obj.Cordinates; obj.Cordinates(1,:)];
            end
        end

        function [idx,side]=FindFriend(obj,Ti)
            Tt=obj.IT(obj.IT.StartCheck==0 & obj.IT.EndCheck==0,:);
            cond=Tt.("Start X")==Ti.("End X")(1) & Tt.("Start Y")==Ti.("End Y")(1);
            side=0;
            if sum(cond)==0
                Tt=obj.IT(obj.IT.EndCheck==0 & obj.IT.StartCheck==0,:);
                cond=Tt.("End X")==Ti.("End X")(1) & Tt.("End Y")==Ti.("End Y")(1);
                side=1;
            end

            if sum(cond)==0
                Tt=obj.IT(obj.IT.EndCheck==0 & obj.IT.StartCheck==0,:);
                cond=Tt.("Start X")==Ti.("Start X")(1) & Tt.("Start Y")==Ti.("Start Y")(1);
                side=0;
            end

            if sum(cond)==0
                Tt=obj.IT(obj.IT.EndCheck==0 & obj.IT.StartCheck==0,:);
                cond=Tt.("End X")==Ti.("Start X")(1) & Tt.("End Y")==Ti.("Start Y")(1);
                side=1;
            end

            row=find(cond);
            idx=Tt.Index(row);

        end

        function AddPoints(obj,x,y)
            obj.Points=[];
            obj.PCount=0;
            in = inpolygon(x,y,obj.Cordinates.x,obj.Cordinates.y);
            if sum(in)>0
                P=table(x(in),y(in),'VariableNames',{'x','y'});
                obj.Points=P;
                obj.PCount=size(obj.Points,1);
            end
        end

        
    end
end
