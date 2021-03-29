function [OutputTable]=ComputeOutputTable(PartTab,FileNamesUZ)
    arguments
        PartTab table;
        FileNamesUZ cell;
    end
    warning ('off','all');
    PopisR={'R1_3','R1_4','R1_5','R1_6','R1_3_6','R1_4_6','R2_4_6'};
    PopisS={'S1_3','S1_4','S1_5','S1_6','S1_3_6','S1_4_6','S2_4_6'};
    desky={'Deska 1','Deska 2','Deska 3','Deska 4','Deska 5'};
    numComb={[1:3],[1:4],[1:5],[1:6],[1 3 6],[1 4 6],[2 4 6]};

    OutputTable=table;
    con=[0];
    for f=1:4
        for d=1:5
            for lin=0:5
                for linrep=0:5
                    tab3=PartTab(PartTab.deska==FileNamesUZ{f} & PartTab.Specimen==desky{d}...
                    & PartTab.Line==lin & PartTab.LineRepeat==linrep,:);

                    if size(tab3,1)>0
                        x=tab3.Dist;
                        y=tab3.Time1B;

                        con=con+1;

                        OutputTable.OrigName{con}=tab3.Name{1};
                        OutputTable.OrigResult(con)=tab3.Result(1);
                        OutputTable.Fil{con}=FileNamesUZ{f};
                        OutputTable.Desk{con}=desky{d};
                        OutputTable.Line(con)=lin;
                        OutputTable.LineRepeat(con)=linrep;
                        OutputTable.Date(con)=datetime(tab3.Date_Time(1),'InputFormat','dd.MM.yyyy hh:mm','Format','dd.MM.yyyy hh:mm');

                        for com=1:numel(PopisR)

                            CIdx=numComb{com};
                            if length(x)==5
                                CIdx(CIdx==6)=5;
                            end
                            x2=x(CIdx);
                            y2=y(CIdx);


                            [p, S] = polyfit(x2,y2,1);
                            y1 = polyval(p,x2);

                            smernice=(x2(end)-x2(1))/(y1(end)-y1(1))*1e+6;
                            OutputTable{con,8+(com-1)*2}=smernice;
                            OutputTable{con,9+(com-1)*2}=abs(tab3.Result(1)-smernice);

                        end
                        %title(sprintf('Pùvodní result: %.0f ms^{-1}; Nová smìrnice: %.0f ms^{-1}',tab3.Result(1),smernice));
                    end
                end
            end
        end
    end
    %ColNames=OutputTable.Properties.VariableNames;
    for i=1:numel(PopisR)
        OutputTable.Properties.VariableNames{8+(i-1)*2}=PopisR{i};
        OutputTable.Properties.VariableNames{9+(i-1)*2}=PopisS{i};
    end
    warning ('on','all');
end