% function [t]=TimeOfSignals(time1,amp1,time2,amp2)
% 
% end
disk='E:\Google Drive'; % skolni disk
predSTR=[disk '\Škola\Doktorské Studium\Mìøení\Deska\IE\IE_pred vypalem\'];
poSTR=[disk '\Škola\Doktorské Studium\Mìøení\Deska\IE\IE_po vypalu\'];
%%
rada='A';
sloupec='1';

filename=[poSTR rada '_' sloupec '_Signal.csv'];
data=dlmread(filename,';',10,0);
%
clear x y prumer rozdil;
tic;
time1=data(:,1);
amp1=data(:,2);
time2=data(:,1);
amp2=data(:,3);

figure(1);
subplot(1,2,1);
hold on;
plot(time1,amp1);
plot(time2,amp2);
axis([-0.001 0.00003 -1 +1]);

subplot(1,2,2);



for i=1:2
    y=eval(['amp' num2str(i) ';']);
    x=eval(['time' num2str(i) ';']);
    
    arr=y;
    arr=arr.^2;

    normA = arr - min(arr(:));
    normA = normA ./ max(normA(:)); % *
    normA=cumtrapz(normA);
    amptmp(:,i)=normA;
    
    pocetzaznamu(i)=size(x,1);
    
    xtmp=x(1:1:pocetzaznamu*0.03);
    ytmp=normA(1:1:pocetzaznamu*0.03);

    [p,S] = polyfit(xtmp,ytmp,1); 
    [y_fit,delta] = polyval(p,x,S);
    
    poly{i,1}=x;
    poly{i,2}=y_fit;
    
    %prumer(i)=mean(normA);
    s(i)=std(normA);
    clear nvzd prumvzd;
    for k=1:1:pocetzaznamu(i)*0.1
        y=amptmp(k,i);
        yfit=poly{i,2}(k,1);
        
        rozdil(k,i)=abs(y-yfit);
        
        if k==1
           prumer=rozdil(k,i); 
        end
        
        
        
        if k>1 && k<10
            X=[poly{i,1}(k,1),poly{i,2}(k,1);poly{i,1}(k+1,1),poly{i,2}(k+1,1)];
            vzdalenost=pdist(X,'euclidean');
            nvzd(k)=vzdalenost;
        end
        
        if k>10
            prumvzd=sum(nvzd,2)/size(nvzd,2);
        else
            prumvzd=10;
        end 
        
        if rozdil(k,i)>(prumer+S.normr*.06) | vzdalenost>prumvzd*1.15
        %tmpprumvzd=prumvzd*2;
        %if vzdalenost>tmpprumvzd
        
            index(i)=k;
            break;
        end

        
        prumer=sum(rozdil(:,i),2)/size(rozdil(:,i),2);
        tmp=vzdalenost;
    end
end

hold on;


plot(time1,amptmp(:,1),'--x');
plot(time2,amptmp(:,2),'--o');

plot(poly{1,1},poly{1,2},'-r');
plot(poly{2,1},poly{2,2},'-b');

sor=[x(index(1)),amp1(index(1));x(index(2)),amp2(index(2))];

plot(time1(index(1)),amptmp(index(1),1),'or','MarkerFaceColor','r');
plot(time2(index(2)),amptmp(index(2),2),'or','MarkerFaceColor','k');
%axis([-0.0003 0.00001 0 +0.2]);



cas1=x(index(1));
cas2=x(index(2));

rozdilcasu=abs(cas2-cas1);
rychlost=0.07/rozdilcasu;

evaltime=toc;

subplot(1,2,1);
plot(sor(:,1),sor(:,2),'ro','MarkerFaceColor','r');
%%
%%
rada='A';
sloupec='5';

filename=[poSTR rada '_' sloupec '_Signal.csv'];
data=dlmread(filename,';',10,0);


x=data(:,1);
y=data(:,3);


velikost=size(y,1)*0.2;

figure(1);

hold on;
x2=x(1:1:velikost,1);
y2=y(1:1:velikost,1);
%plot(x2,y2);
nbod=20;
xsmernice=x(1:1:velikost-nbod/2);
%
clear smernice mmr xsmernice;
n=0;
trsh=1000;
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
    
    title(['Smernice je' num2str(smernice)]);
    
    if i>1000 && i<1000+nbod*2
        prumer=mean([mmr]);
        S2=std([mmr]);
        trsh=(S2+prumer)*10;   
    end
    
    %plot(x2,smernice);
    if smernice>trsh
        break
    end
    
    
    
    
end
start=i;

    plot(x,y,'-');
    plot(x(i),y(i),'+','MarkerSize',20);
    
    %axis([x(i-30) x(i+30) y(i-30) y(i+30)]);
