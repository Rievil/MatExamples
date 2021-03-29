
disk='E:\Google Drive';
cd ([disk '\Škola\Doktorské Studium\Dokumenty\Matlab\Matlab_funkce']);

%%
soubory=dir('D:\Modálka_test\Podlaha\*.csv');
nsoubory=size(soubory,1);
clear Modalka;
Modalka=struct();

for i=1:nsoubory
    filename=[soubory(i).folder '\' soubory(i).name];
    data=dlmread(filename,';',10,0);
    Modalka.Uder(:,i)=data(:,3);
    Modalka.Odezva(:,i)=data(:,2);
    if i==1
        Modalka.Freq=1/(data(2,1)-data(1,1));
        Modalka.Samples=size(data(:,1),1);
        Modalka.Length=data(end,1)-data(1,1);
        Modalka.Time=data(:,1);
    end
end
%%
%signaly spojene za sebou
%bode diagram se stabilizaci

clear x xtmp y ytmp;

xtmp=double(0);
ytmp=double(0);
r=5;
s=2;
%pocetuderu=size(Modalka.Uder,2);

for i=1:1:3
    %x=Modalka.Uder(:,i);
    clear x y;
    x=MAData(1).Rada(r).Sloupec(s).Uder(:,i);
    xtmp=vertcat(xtmp,x);

    y=MAData(1).Rada(r).Sloupec(s).Odezva(:,i);
    ytmp=vertcat(ytmp,y);
end

freq=193e+3;
delka=size(xtmp,1);
perioda=1/freq;
maxcas=perioda*delka;
time=double(perioda:perioda:maxcas);


%figure(2);
%subplot(1,2,1);

%plot(time,xtmp);

ylabel('Force (N)');

%subplot(1,2,2);
%plot(time,ytmp);
%ylabel('Displacement (m)');
%xlabel('Time (s)');

%figure(3);
maxfreq=4000;

winlen = size(xtmp,1);
%modalfrf(xtmp,ytmp,freq,winlen,'Sensor','acc','Measurement','rovinginput','Estimator','subspace');
%modalfrf(xtmp,ytmp,freq,winlen,'Sensor','acc','Measurement','rovinginput');
[frf,f]=modalfrf(xtmp,ytmp,freq,winlen,'Sensor','acc','Measurement','rovinginput');
%xlim([0 maxfreq/1000]);
%
figure('units','normalized','outerposition',[0 0 1 1]);
clear x xco y yco h;

%modalsd(frf,f,freq,'MaxModes',30,'FreqRange',[0 .5e+4],'SCriteria',[0.5e-3 0.003]);
%modalsd(frf,f,freq,'MaxModes',30,'FreqRange',[0 .5e+4],'FitMethod','lsce');
modalsd(frf,f,freq,'MaxModes',30,'FreqRange',[0 maxfreq],'FitMethod','lsce');
xlim([0 maxfreq/1000]);
%%
yyaxis right;
hold on;
h = findobj(gca,'Type','line');

x=get(h,'Xdata');


xco=x{1,1};

%MAData(stav).Rada(rada).Sloupec(sloupec).ModeX=xco;

y=get(h,'Ydata');
yco=y{1,1};

figure(5);
plot(xco,yco);
set(gca,'YScale','log');
xlim([0 maxfreq/1000]);
%MAData(stav).Rada(rada).Sloupec(sloupec).ModeY=yco;
%%
figure(1);
[fn,dr] = modalfit(frf,f,freq,1,'FitMethod','PP');
modalfit(frf,f,freq,1,'FitMethod','PP');

%%
figure(10);
[f,y]=MyFFT(Modalka.Odezva(:,1),Modalka.Freq);
plot(f,y);
set(gca,'YScale','log');
xlim([0 2000]);
%%
%%
%signaly spojene za sebou
%bode diagram se stabilizaci

clear x xtmp y ytmp;

xtmp=double(0);
ytmp=double(0);
r=5;
s=3;
%pocetuderu=size(Modalka.Uder,2);
stavStr={'Ref','Po výpalu'};
figure(1);
for stav=[1 2]
    for i=1:1:3
        %x=Modalka.Uder(:,i);
        clear x y;
        x=MAData(stav).Rada(r).Sloupec(s).Uder(:,i);
        xtmp=vertcat(xtmp,x);

        y=MAData(stav).Rada(r).Sloupec(s).Odezva(:,i);
        ytmp=vertcat(ytmp,y);
    end
    
    subplot(2,1,stav);
    hold on;
    freq=193e+3;
    delka=size(xtmp,1);
    perioda=1/freq;
    maxcas=perioda*delka;
    time=double(perioda:perioda:maxcas);


    %figure(2);
    %subplot(1,2,1);

    %plot(time,xtmp);

    %ylabel('Force (N)');

    %subplot(1,2,2);
    %plot(time,ytmp);
    %ylabel('Displacement (m)');
    %xlabel('Time (s)');

    %figure(3);
    maxfreq=4000;

    winlen = size(xtmp,1);
    %modalfrf(xtmp,ytmp,freq,winlen,'Sensor','acc','Measurement','rovinginput','Estimator','subspace');
    %modalfrf(xtmp,ytmp,freq,winlen,'Sensor','acc','Measurement','rovinginput');
    [frf,f]=modalfrf(xtmp,ytmp,freq,winlen,'Sensor','acc','Measurement','rovinginput');
    %xlim([0 maxfreq/1000]);
    %
    
    clear x xco y yco h;

    %modalsd(frf,f,freq,'MaxModes',30,'FreqRange',[0 .5e+4],'SCriteria',[0.5e-3 0.003]);
    %modalsd(frf,f,freq,'MaxModes',30,'FreqRange',[0 .5e+4],'FitMethod','lsce');
    modalsd(frf,f,freq,'MaxModes',30,'FreqRange',[0 maxfreq],'FitMethod','lsce');
    xlim([0 maxfreq/1000]);
    title(stavStr{stav});
end
set(gcf,'units','normalized','outerposition',[0 0 0.5 1]);