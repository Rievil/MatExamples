function [indexLeft,indexRight]=IterujProlozeni(X,Y,indexFirst,indexLast,maxIndex)

    if maxIndex>0
    else
       maxIndex=length(X); 
    end
    R=1;
    i=0;
    currR=0;
    maxIter=round((length(X)-length(X(indexFirst:1:indexLast)))/2,0);
    %
    while R>currR && i<maxIter
        i=i+1;
        partX=X(indexFirst:1:indexLast);
        partY=Y(indexFirst:1:indexLast);

        %artX=[partY(1):(partY(end)-partY(1))/(length(partY)-1):partY(end)]';
        artY=[partY(1):(partY(end)-partY(1))/(length(partY)-1):partY(end)]';
        RTMP=corrcoef([partX partY artY]);
        R=RTMP(3,2);
        
        if R>0.94 && (length(partX)/length(X))>0.6
            break;
        end
        
        if i==1
            currR=R*0.9;
        end
        
        

        if indexFirst>1
            indexFirst=indexFirst-1;
        end

        if indexLast<length(X) && indexLast<maxIndex
            indexLast=indexLast+1;
        end
    end
    indexLeft=indexFirst;
    indexRight=indexLast;
end