function ResizeSignals(lines,ax,type)
%lines je handle jednotlivých signálù, které mají být odskoèeny o unifor
%ax je handle os ve kterých se mají grafy vykreslovat
%funkci je tøeba volat až po vykreslení lajn

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
    %mám limity pro osu x a osu y
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
    
    %vybírání typu y lim
    switch STRtype
        case 'uniform'
            FinMaxY=Rozptyl*(i-.5);
        case 'adaptive'
            FinMaxY=AdInc(i)+NewMax;
        otherwise
    end
    set(ax,'Ylim',[OldMin*0.9 FinMaxY*1.1]);
end