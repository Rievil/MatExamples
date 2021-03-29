function [nS,nT]=ZatridVzorek(strIN,numSady,strTyp)
%strIN=strrep(files(1).name,'.txt','');
    switchChar={' ','-','_'};
    for i=1:3
        %pokud je nejaky znak mezi cislem a stringem
        strInTMP=strrep(strIN,switchChar{i},'');
        if length(strInTMP)<length(strIN)
                newStr = split(strIN,switchChar{i});
            %ano, nasel jsem ten spravny oddelovac
            break;
        end
    end
        if isnumeric(str2num(newStr{1,1}))
            numSadyTMP=str2num(newStr{1,1});
            strTypTMP=newStr{2,1};
        else
            numSadyTMP=str2num(newStr{2,1});
            strTypTMP=newStr{1,1};
        end
        %
        [log,nS]=ismember(numSadyTMP,numSady);
        [log,nT]=ismember(strTypTMP,strTyp);
 end