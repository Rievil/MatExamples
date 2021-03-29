function [start]=TimeOf2Signals_2(time,signal)
x=time;
y=power(signal,2);

velikost=size(y,1)*0.2;

x2=x(1:1:velikost,1);
y2=y(1:1:velikost,1);
%plot(x2,y2);
nbod=30;
xsmernice=x(1:1:velikost-nbod/2);
%
clear smernice mmr xsmernice;
n=0;
trsh=200;
    for i=nbod+1:nbod/2:velikost-nbod/2
        n=n+1;
        low=i-nbod;
        high=i+nbod;


        kussig=y(low:1:high,1);
        kusx=x(low:1:high,1);

        [p,S] = polyfit(kusx,kussig,2); 
        [y_fit,delta] = polyval(p,kusx,S);

        smernice=(max(y_fit)-min(y_fit))/(max(kusx)-min(kusx));
        mmr(n)=smernice;
        xsmernice(n)=x(i);
        teziste=[(max(kusx)-min(kusx))/2+min(kusx),(max(y_fit)-min(y_fit))/2+min(y_fit)];

        %title(['Smernice je' num2str(smernice)]);

        if i>trsh && i<trsh+nbod*2
            S3=std(kussig);
            trsh2=mode(kussig)+S3*2;
        
            prumer=mean([mmr]);
            S2=std([mmr]);
            trsh=(S2+prumer)*15;   
        end
        
        if smernice>trsh
            [locMax,locI]=max(kussig);
            kussig=kussig(1:locI);
            kusx=kusx(1:locI);
            y_fit=y_fit(1:locI);
            tmpI=find(kussig<trsh2,1,'last')+low-1;
            break
        end
    end

start=tmpI;

end
