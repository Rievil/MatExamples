function ResizeSignals(lines,ax,type)
%lines je handle jednotliv�ch sign�l�, kter� maj� b�t odsko�eny o unifor
%ax je handle os ve kter�ch se maj� grafy vykreslovat
%funkci je t�eba volat a� po vykreslen� lajn

lCount=length(lines);
OldMax=0;
OldMin=0;
AdInc(1)=0;
STRtype=lower(type);
    for i=1:lCount
        YOrig=lines(i).YData; 
        
        NewMin=min(YOrig);

        if i>1
            AdInc(i)=AdInc(i-1)+abs(NewMin)+NewMax;            
        end
        
        NewMax=max(YOrig);
        
        if NewMin<OldMin
            OldMin=NewMin;
        end
        

        
        if NewMax>OldMax
            OldMax=NewMax;
        end
        
        
        
    end
    %m�m limity pro osu x a osu y
    Rozptyl=OldMax+abs(OldMin);
    
    %
    for i=1:lCount
        YTMP=lines(i).YData;
        switch STRtype
            case 'uniform'
                lines(i).YData=YTMP+(i-1)*Rozptyl;
            case 'adaptive'
                lines(i).YData=YTMP+AdInc(i);
            otherwise
        end
    end
    
    %vyb�r�n� typu y lim
    switch STRtype
        case 'uniform'
            FinMaxY=Rozptyl*(i-.5);
        case 'adaptive'
            FinMaxY=AdInc(i)+NewMax;
        otherwise
    end
    set(ax,'Ylim',[OldMin*0.9 FinMaxY*1.1]);
end