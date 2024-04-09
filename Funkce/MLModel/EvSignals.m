classdef EvSignals < handle
    properties
        Data;
        ClassCol;
        VarCols;
        Response;
        Classes;
        Aov;
        ColNames;
        TScore;
        Idx;
        Score;
    end

    methods
        function obj=EvSignals(t,classcol,varcols)
            obj.Data=t;
            obj.ClassCol=classcol;
            obj.VarCols=varcols;
        end

        function process(obj)
            %% Anova
            obj.Classes=unique(obj.Data.(obj.ClassCol));
            if ~strcmp(obj.Classes,'string')
                obj.Classes=string(obj.Classes);
            end
            ids=string(1:1:numel(obj.Classes));
            obj.Response=categorical(obj.Data.(obj.ClassCol),obj.Classes,ids);
            obj.Response=double(string(obj.Response));

            obj.Aov = anova(obj.Data(:,obj.VarCols),obj.Response,CategoricalFactors = []);
            
            obj.ColNames=obj.Data.Properties.VariableNames(obj.VarCols)';
            %%
            v = varianceComponent(obj.Aov);
            
            [~,ems] = stats(obj.Aov);
            coef=obj.Aov.Coefficients;
            % coef=coef-min(coef);
            
            obj.TScore=table(obj.ColNames,coef(1:numel(obj.VarCols)),'VariableNames',["Name","Coef"]);
            obj.TScore=sortrows(obj.TScore,'Coef','descend');
            
            bar(obj.TScore.Coef);

            % cols=[6,27,2,7];
            C=obj.Data(:,obj.VarCols);

            D=table2array(C);

            C=[obj.Data, table(obj.Aov.Residuals.Pearson','VariableNames',["Pearson"])];
            obj.Score=C;
            obj.Score.Representant(:)=false;
            C=sortrows(C,'Pearson','descend');
            
            unqclass=unique(C.(obj.ClassCol));
            res=abs(C.Pearson);
            idx=zeros(numel(obj.Classes),1);
            for i=1:numel(unqclass)
                D=C(C.(obj.ClassCol)==unqclass(i),["ID",obj.ClassCol,"Pearson"]);
                D.Pearson=abs(D.Pearson);
                [m,I]=min(D.Pearson);
                idx(i,1)=D.ID(I);
                obj.Score.Representant(D.ID(I))=true;
            end
            obj.Idx=idx;
        end
    end
end