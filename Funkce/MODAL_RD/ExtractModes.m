function [NaturalFreq]=ExtractModes(matrix)
%matrix=mody{2};
velikost=size(matrix);    
poc=0;
    for i=1:velikost(1)
        clear mem vystup tmp NaturalFreq;
        mem=double(0);
       for j=1:1:i
          %jsem v øádku
          freq=matrix(i,j);
          
          if isnan(freq)
            %pokud se dostanu na radek kde je uz nan, ukoncim hledani
              break;
          end
          
          mem(j)=freq;
          poc=poc+1;
       end
       VelikostMem=size(mem,2);
       outMem{i}=mem;
       outPocet(i)=VelikostMem;
    end
    %nyni musim rozhodnout ktera cell ma nejvice frekvenci
    %je treba doplnit podminku kdy je pouze jedna rada s max poctem
    %frekvenci a pak kdy je vice frekvenci, v takovem pripade je potreba
    %slozit pole a srovnat podle velikosti
    MaxMem=max(outPocet);
    
    %zjisti pozici max poctu
    PoziceMem=find(outPocet==MaxMem);
    %vystup=double(0);
    if size(PoziceMem,2)>1
        %naslo se vice stejnych poctu
        for i=1:1:size(PoziceMem,2)
            vystup(:,i)=outMem{PoziceMem(i)}';
        end
        NaturalFreq=mean(vystup,2);
        
    else
        %nasel se pouze jeden pocet
        clear NaturalFreq;
        NaturalFreq=outMem{PoziceMem}';
    end
    
    NaturalFreq=sort(NaturalFreq,1,'ascend');
end