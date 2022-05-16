classdef Sampler < handle
    %SAMPLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Img;
        T table;
        UIFig;
        UIAx;
        UIT;
        RowSelect=0;
        ID=0;
    end
    
    methods
        function obj = Sampler(imgfile)
            obj.Img=imread(imgfile);
        end

        

        function AddRow(obj)
            obj.ID=obj.ID+1;
            roi = drawpoint(obj.UIAx,'UserData',{obj.ID},'Label',sprintf("%d",obj.ID));
            x=roi.Position(1);
            y=roi.Position(2);
            addlistener(roi,'ROIMoved',@obj.CROIMoved);
            obj.T=[obj.T; table(obj.ID,string(sprintf("%d",obj.ID)),{roi},x,y,'VariableNames',{'ID','Name','ROI','X','Y'})];
        end
        function UpdateUIT(obj)
            obj.UIT.Data=obj.T(:,[1:end-3]);
        end

        function DeleteRow(obj)
            if size(obj.T,1)>0
                if obj.RowSelect>0
                    obj.T.ROI{obj.RowSelect}.delete;
                    obj.T(obj.RowSelect,:)=[];
                    obj.RowSelect=obj.RowSelect-1;
                else
                    obj.T.ROI{end}.delete;
                    obj.T(end,:)=[];
                end
                if size(obj.T,1)==0
                    obj.ID=0;
                end
            end
        end
        
        function DrawGui(obj)
            obj.UIFig=uifigure('KeyPressFcn',@obj.CKeyPress);
            g=uigridlayout(obj.UIFig);
            g.RowHeight = {22,22,'1x'};
            g.ColumnWidth = {150,150,'1x'};

            obj.UIAx=uiaxes(g);
            obj.UIAx.Layout.Row=[1 3];
            obj.UIAx.Layout.Column=3;
            
            disableDefaultInteractivity(obj.UIAx);
            
            imshow(obj.Img,'parent',obj.UIAx);
        
            but1=uibutton(g,'Text','AddPoint',"ButtonPushedFcn",@obj.CAddRow);
            but1.Layout.Row=1;
            but1.Layout.Column=1;

            but2=uibutton(g,'Text','RemovePoint',"ButtonPushedFcn",@obj.CRemovePoint);
            but2.Layout.Row=1;
            but2.Layout.Column=2;
            

            uit=uitable(g,'Data',obj.T(:,[1:end-3]),'CellSelectionCallback',@obj.CRowSelect,...
                'ColumnEditable',[false,true],'ColumnWidth','auto','CellEditCallback',@obj.CChangeLabel);
            uit.Layout.Row=3;
            uit.Layout.Column=[1 2];
            obj.UIT=uit;

            uet=uieditfield(g);
            uet.Layout.Row=2;
            uet.Layout.Column=1;
        end

        function CAddRow(obj,src,evnt)
            AddRow(obj);
            UpdateUIT(obj);
        end

        function CRemovePoint(obj,src,evnt)
            DeleteRow(obj);
            UpdateUIT(obj);
        end

        function CRowSelect(obj,src,evnt)
            if size(evnt.Indices(1),1)==1
                if evnt.Indices(1)>0
                    obj.RowSelect=evnt.Indices(1);
                end
            end
        end

        function CChangeLabel(obj,src,evnt)
            obj.RowSelect=evnt.Indices(1);
            obj.T.Name(obj.RowSelect)=src.Data.Name(obj.RowSelect);
            obj.T.ROI{obj.RowSelect}.Color='r';
            UpdateUIT(obj);
        end

        function CKeyPress(obj,src,evnt)
            switch evnt.Key
                case 'space'
                    AddRow(obj);
                    UpdateUIT(obj);
                case 'delete'
                    DeleteRow(obj);
                    UpdateUIT(obj);
                otherwise
%                     disp('other key hit');
            end
            
        end

        function CROIMoved(obj,src,evnt)
            id=evnt.Source.UserData{1};
            pos=evnt.CurrentPosition;
            row=obj.T.ID==id;
            obj.T.X(row)=pos(1);
            obj.T.Y(row)=pos(2);
            UpdateUIT(obj);
        end

        function stash=Pack(obj)
            stash=struct;
            stash.Points=obj.T(:,["ID","Name","X","Y"]);
            stash.Img=obj.Img;
        end
    end
end

