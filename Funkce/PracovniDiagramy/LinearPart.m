function [index,data]=LinearPart(X,Y)

    %X=Mereni(sada).Typ(typ).Vzdalenost/1000;
    %Y=Mereni(sada).Typ(typ).Sila;
    Y2=diff(Y);
    Y3=smooth(Y2,0.05,'loess');

    [Y4,indexMax]=OrezZuby(1:1:length(Y3),Y3);

    trshFirst=max(Y4)*0.80;
    trshLast=max(Y4)*0.90;

    indexFirst=find(trshFirst<Y4,1,'first');
    indexLast=find(trshLast<Y4,1,'last');

    if length(X(indexFirst:indexLast))/length(X)<0.3
        [indexFirst,indexLast]=IterujProlozeni(X,Y,indexFirst,indexLast,indexMax);
    end

    index=[indexFirst indexLast];
    data={X(indexFirst:1:indexLast),Y(indexFirst:1:indexLast)};
end