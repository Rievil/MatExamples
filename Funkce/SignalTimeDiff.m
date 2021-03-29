function [x,y]=SignalTimeDiff(time,source)
% count = pocet pocatecnik znaku pro zjisteni tiche pocatecni faze
% source = zdrojovy signal v napeti
% time = casova rada
x=zeros(1,1);
y=zeros(1,1);

% smooth=filloutliers(source,'nearest','mean');
% source=smooth;

stred=zeros(length(source),1);
R=zeros(length(source),1);
smernice=zeros(length(source),1);
delka=11;
zacatek=delka+1;

for i=zacatek:8000
    cil=i;
    low=cil-delka;
    high=cil+delka;

    Middle=low+(high-low)/2;

    p = polyfit(time(low:high),source(low:high),1);
    f = polyval(p,time); 
    %plot(x,y,'-o',x(low:high),f(low:high),'-d') ;
    %legend('data','linear fit') ;
    stred(i,1)=f(Middle);
    smernice(i,1)=abs((f(high,1)-f(low,1))/(time(high,1)-time(low,1)));
    %R(i,1) = corrcoef(source(low:high),f(low:high));
end    
    
Max=max(smernice(:,1));
Hladina=Max/80;
    
for i=6:8000
    
    if (smernice(i,1)-stred(i,1))>Hladina
        
        x=time(i,1);
        y=source(i,1);
        break
    end
end

end