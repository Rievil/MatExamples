%% Definice cesty a vzorových názvů souborů k nahrávání
clear all;
path=cd;

%Definice názvu souboru
filename=[path '\IOExamples\Data\KanalizacniTrubka.csv'];

%% Načtení pomocí 'dlmread'

data=dlmread(filename,';',10,0);

%% Vykreslení měřených dat

fig=figure;
ax=gca;
hold on;

han=plot(data(:,1),data(:,[2 3 4]));

label={'Hammer','Sensor 1','Sensor 2'};

lgd=legend(han,label,'Location','best');
lgd.NumColumns=2;
lgd.Title.String='Zdroj vibrací';
xlabel('Čas \it t \rm [s]');
ylabel('Amplituda \it U \rm [V]');
ax.YAxis.Exponent=-3;