function [PartTab]=ETFPT(FileNamesUZ,disk)
    
    arguments 
        FileNamesUZ cell;
        disk char;
    end
    
    warning ('off','all');

    BigTab=table;
    for i=1:length(FileNamesUZ)
        clear tab deska Deska;
        Cesta1=[disk '\Škola\Mìøení\2020\Dalibor_ultrazvuk\Èlánek\' FileNamesUZ{i} '.txt'];
        h = ReadPundit(Cesta1);
        tab=h.SignalProperties;
        deska(1:size(tab,1),1)=categorical(cellstr(FileNamesUZ{i}));
        Deska=table(deska);
        tab=[tab, Deska];
        BigTab=[BigTab; tab];
    end
    % oprava Time
    romanNum={'i','ii','iii','iv','v','vi','vii','viii','ix'};
    tmpTime=BigTab.Time1__s_;
    TimeCol=split(tmpTime,'.');
    clear Time1B TimeB;
    for i=1:size(TimeCol,1)
        A=str2double(TimeCol{i,1});
        smallB=lower(TimeCol{i,2});
        if ismember(smallB,romanNum)
            [idA,idB]=ismember(smallB,romanNum);
            B=idB;
        else
            B=str2double(smallB);
        end

        Time1B(i,1)=A+B/10;
    end
    TimeB=table(Time1B);
    BigTab=[BigTab, TimeB];


    %
    Specimen=categorical;
    Line=[];
    LineRepeat=[];
    ID=[];
    Dist=[];

    Descr=table(ID,Specimen,Line,LineRepeat);
    for f=1:length(FileNamesUZ)

        idxBase=find(BigTab.deska==FileNamesUZ{f});
        tab4=BigTab(idxBase,:);

        unqName=unique(tab4.Name);

        for desk=1:length(unqName)
            idx=find(string(tab4.Name)==unqName(desk));
            tab2=tab4(idx,:);

            TrueIDX=idxBase(idx);
            strName=split(tab2.Name,{' ','-'});
            alpha='abcdefghijklmnopqrstuvwxyz';
            arrDist=cumsum(tab2.DistanceB_m_);
            Dist=[Dist; arrDist];


            ID=linspace(1,size(tab2,1),size(tab2,1));

            for i=1:size(tab2,1)
                for j=1:size(strName,2)
                    strTMP=lower(string(strrep(strName(i,j),' ','')));
                    switch strTMP
                        case 'deska1'
                            Descr.Specimen(TrueIDX(i))="Deska 1";
                        case 'deska2'
                            Descr.Specimen(TrueIDX(i))="Deska 2";
                        case 'deska3'
                            Descr.Specimen(TrueIDX(i))="Deska 3";
                        case 'deska4'
                            Descr.Specimen(TrueIDX(i))="Deska 4";
                        case 'deska5'
                            Descr.Specimen(TrueIDX(i))="Deska 5";
                        otherwise
                            if j==2
                                if ~ismember(char(strTMP), '0123456789')
                                    charIdx = strfind(alpha,char(strTMP));
                                    Descr.Line(TrueIDX(i))=charIdx;
                                else
                                    Descr.Line(TrueIDX(i))=str2double(strTMP);
                                end
                            else
                                Descr.LineRepeat(TrueIDX(i))=str2double(strTMP);
                            end
                    end
                end
                Descr.ID(TrueIDX(i))=ID(i);
            end
        end
    end
    Dist=table(Dist);
    BigTab=[BigTab, Descr, Dist];
    PartTab=BigTab(:,[3 4 5 37 32 31 33 34 35 36]);
    
    warning ('on','all');
end