function [AvgMem]=SepNatFreq(data)
    %separuje unikátní frekvence z fn matice z funkce modalsd, na základì
    %minimální diference mezi hodnotami a nutnému minimálnímu poètu hodnot,
    %ze kterých vytvoøí prùmìr
    
    %data=NFScat{2,9};
    data(isnan(data)) = [];   %odstraní nan hodnoty
    data = sort(data,'ascend');
    
    zac=false;
    nAvg=0;
    AvgMem=double(0);
    for i=1:1:length(data)

        if zac==true
            EndTMP=i; %zaèátek øady

            if data(EndTMP)-data(i-1)<20 && data(i-1)>70
                %rozdil mezi posledním a dalším je do 10 Hz mùžeš pokraèovat dál
                inAvg=inAvg+1;

            else
                %rozdíl mezi posledním a dalším je nad 10 Hz, spoèti prùmìr a
                %vyresetuj vyhledávání
                if inAvg<4
                    %prumer je tvoren 3 a ménì hodnot a tedy nebudu jej
                    %zapoèítávat
                    nAvg=nAvg-1;
                else
                    %prùmìr je z více jak 3 hodnot a budu jej tedy zapoèítávat
                    EndTMP=EndTMP-1;
                    prum=mean(data(StartTMP:1:EndTMP));
                    pocet=length(data(StartTMP:1:EndTMP));
                    AvgMem(nAvg,1)=prum;    %frekvence
                    AvgMem(nAvg,2)=(EndTMP-StartTMP)/2+StartTMP;
                    AvgMem(nAvg,3)=pocet;
                end

                zac=false;
            end
        else
            StartTMP=i;
            zac=true;
            nAvg=nAvg+1;
            inAvg=0;
        end
    end
end