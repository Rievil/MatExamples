function [t,smer,energie]=AnalyzeSignal(X,Y)
    %clear X Y;
    %figure(1);
    %hold on;
    %j=250;
    %X=dataSignal(:,1);
    Yexp=Y.^2;
    %plot(X,Yexp);
    maxY=max(Yexp(X>X*0.1))*2;
    zac=find(Yexp>maxY,1,'first');
    kon=find(Yexp>maxY,1,'last');
    %plot([X(zac) X(kon)],[maxY maxY]);
    [up,lo] = envelope(Yexp(zac:kon),150,'peak');
    Xenv=X(zac:kon);
    %plot(Xenv,up);
    %plot([min(Xenv) max(Xenv)],[max(up) min(up)],'-ok');
    %ylim([0 0.085]);
    t=X(kon)-X(zac);
    smer=(max(up)-min(up))/(max(Xenv)-min(Xenv));
    energie=trapz(Xenv,up);
end
%set(gca,'Yscale','log');
