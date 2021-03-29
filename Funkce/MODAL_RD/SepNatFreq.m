function [AvgMem]=SepNatFreq(data)
    %separuje unik�tn� frekvence z fn matice z funkce modalsd, na z�klad�
    %minim�ln� diference mezi hodnotami a nutn�mu minim�ln�mu po�tu hodnot,
    %ze kter�ch vytvo�� pr�m�r
    
    %data=NFScat{2,9};
    data(isnan(data)) = [];   %odstran� nan hodnoty
    data = sort(data,'ascend');
    
    zac=false;
    nAvg=0;
    AvgMem=double(0);
    for i=1:1:length(data)

        if zac==true
            EndTMP=i; %za��tek �ady

            if data(EndTMP)-data(i-1)<20 && data(i-1)>70
                %rozdil mezi posledn�m a dal��m je do 10 Hz m��e� pokra�ovat d�l
                inAvg=inAvg+1;

            else
                %rozd�l mezi posledn�m a dal��m je nad 10 Hz, spo�ti pr�m�r a
                %vyresetuj vyhled�v�n�
                if inAvg<4
                    %prumer je tvoren 3 a m�n� hodnot a tedy nebudu jej
                    %zapo��t�vat
                    nAvg=nAvg-1;
                else
                    %pr�m�r je z v�ce jak 3 hodnot a budu jej tedy zapo��t�vat
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