function [Y,index]=OrezZuby(X2,Y2)
    mi=min(Y2);
    ma=max(Y2);
    
    rozptyl=(abs(mi)+abs(ma))/7;
    [pks,locs,w,p]=findpeaks(Y2*-1,X2,'MinPeakProminence',rozptyl,'Annotate','extents');
    if length(pks)>0
        Xorez=locs(1)-w(1)*2;
        index=find(Xorez>X2,1,'last');
        Y=Y2;
        Y(index:end)=0;
    else
        Y=Y2;
        index=0;
    end
end