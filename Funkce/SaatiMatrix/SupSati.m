classdef SupSati < handle
    properties
        Version=0;
        VerTable;
    end
    
    methods
        %Superclass constructor--------------------------------------------
        function obj=SupSati(~)

        end
        
        %Save of object----------------------------------------------------
        function save(obj)
            tmp=obj;
            filename=[obj.Path '\SatiMatrixVar.mat'];
            save(filename,'tmp');
        end
        
        function ChangeVersion(obj)
            obj.Version=obj.Version+1;
            obj.VerTable=[obj.VerTable; table(obj.Version,{obj.InTable},{obj.WTable},...
                'VairableNames',{'ID','InTable','WTable'})];
        end

        %Load of object----------------------------------------------------
        function load(obj)
           filename=[obj.Path '\SatiMatrixVar.mat'];
           load(filename);
           if ~isempty(obj.WUITable)
               if isvalid(obj.WUITable)
                    obj.WUITable.Data=tmp.WTable;
               end
           end
           
           obj.WTable=tmp.WTable;
        end
        
        %export wttable----------------------------------------------------
        function export(obj)
            filename=[obj.Path '\WTable.xlsx'];
            exTable=[table(obj.Names,'VariableNames',"Names"), obj.WTable,...
                table(obj.Si,'VariableNames',"Si"),...
                table(obj.Ri,'VariableNames',"Ri"),...
                table(obj.Fi,'VariableNames',"Fi")];
            
            writetable(exTable,filename);
        end
        
        %programitcally insert wtable_______________________________________
        function push(obj,wta)
            obj.WTable=wta;
%             ChangeVersion(obj);
        end
        
        %programitcally export wtable_______________________________________
        function wta=pull(obj)
            wta=obj.WTable;
        end
    end
end