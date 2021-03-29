%%
%vyexportuje z promene 'Panel' data do excelu
disk='D:\Data\Disk Google'; %bytový disk

p=2;
nazev=Panel(p).Name;
sheetsName={'Overview','Matrix','NaturalFreq','Damping','ModeShapes'};
filename=[disk '\Škola\Doktorské Studium\Mìøení\Hela_ŽBPanely\ExportExcel\' nazev '.xlsx'];

%první list s obecnými informacemi
Parametrs={'Name';'Length [m]';'Height [m]';'Width [m]';'Mode count [-]'};
pocetModu=size(Panel(p).NaturalFreq,2);

Values={nazev;1.627;0.15;0.4;pocetModu};
T = table(Parametrs,Values);
writetable(T,filename,'Sheet',sheetsName{1},'WriteVariableNames',true);

%druhý list se souradnicemi
pocetBodu=size(Panel(p).Predpis(:,1),1)+1;
nBody(1:1:pocetBodu-1)=double(1:1:pocetBodu-1);
nPoints=nBody';
X=Panel(p).Predpis(:,3);
Y=Panel(p).Predpis(:,4);
Z=Panel(p).Predpis(:,5);
T=table(nPoints,X,Y,Z);
writetable(T,filename,'Sheet',sheetsName{2},'WriteVariableNames',true);

%Vlastni frekvence

clear T tmp;
NaturalFrequency=Panel(p).NaturalFreq;
headerName={'nPoints',sprintf('NFmode')};
T=table(nPoints,NaturalFrequency);
T.Properties.VariableNames=headerName;
writetable(T,filename,'Sheet',sheetsName{3});

%
%Utlum
clear T tmp;
DampingRatios=Panel(p).Utlum;
headerName={'nPoints',sprintf('DampingMode')};
T=table(nPoints,DampingRatios);
T.Properties.VariableNames=headerName;
writetable(T,filename,'Sheet',sheetsName{4});


%Vlastni mody
clear T tmp;
ModeShapes=Panel(p).ModeShapes;
T=table(nPoints,ModeShapes);
%T2=join(G,T);

headerName={'nPoints',sprintf('ModeShapesMode')};
T.Properties.VariableNames=headerName;
writetable(T,filename,'Sheet',sheetsName{5});
%%

p=2;

filename=[disk '\Škola\Doktorské Studium\Mìøení\Deska\Modalni analyza\' Mereni(p).Description.Name '.xlsx'];
%popis mereni______________________________________
Parameters=fieldnames(Mereni(p).Description);
Values=struct2cell(Mereni(p).Description);
T=table(Parameters,Values);
writetable(T,filename,'Sheet',1);

%druhý list se souradnicemi
clear T;
nPoints=double(1:1:Mereni(p).EXTab.NPoints)';
X=Mereni(p).EXTab.CorX';
Y=Mereni(p).EXTab.CorY';
Z=Mereni(p).EXTab.CorZ';
T=table(nPoints,X,Y,Z);
writetable(T,filename,'Sheet',2,'WriteVariableNames',true);

%vlastni frekvence
clear T tmp;
Mat=size(Mereni(p).EXTab.Matrix);
bod=0;
for r=1:1:Mat(1)
    for s=1:1:Mat(2)
        bod=bod+1;
        FNMod{bod,1}=Mereni(p).Rada(r).Sloupec(s).Snimac.Fn';
    end
end
T=table(nPoints,FNMod);
writetable(T,filename,'Sheet',3);

%utlum
clear T tmp;
Mat=size(Mereni(p).EXTab.Matrix);
bod=0;
for r=1:1:Mat(1)
    for s=1:1:Mat(2)
        bod=bod+1;
        Damping{bod,1}=Mereni(p).Rada(r).Sloupec(s).Snimac.Dr';
    end
end
T=table(nPoints,Damping);
writetable(T,filename,'Sheet','Damping');

%hmotnostni matice
clear T tmp ModeShape strArr;
Mat=size(Mereni(p).EXTab.Matrix);
bod=0;
ModeShape(1:Mereni(p).EXTab.NPoints,1:Mereni(p).Description.Modes)=string();
%
for r=1:1:Mat(1)
    for s=1:1:Mat(2)
        bod=bod+1;
        %TMP{bod,1}=Mereni(p).Rada(r).Sloupec(s).Snimac.Ms';
        clear tmp;
        tmp(1,1:length(Mereni(p).Description.Modes))=string();
        
        [strArr]=Complex2String(Mereni(p).Rada(r).Sloupec(s).Snimac.Ms);
        
        vel=size(strArr);
        tmp(1,1:vel(2))=strArr;
        
        ModeShape(bod,:)=tmp;
        
    end
end
%tmp=cell2mat(ModeShape);
T=table(nPoints,ModeShape);

writetable(T,filename,'Sheet','ModeShape');
%%
data=Mereni(3).Rada(1).Sloupec(1).Snimac.Ms;
vel=size(Mereni(3).Rada(1).Sloupec(1).Snimac.Ms);
strArr(1:1:vel(1),1)=string();
blank={};
    for j=1:1:vel(2)
        for i=1:1:vel(1)
            if isnan(data(i,j))
                 strArr(i,j)={'NaN'};
            else
                strArr(i,j)=sprintf('%g%+gi', real(data(i,j)), imag(data(i,j)));
            end
        end
    end
%%
NaturalFrequency=Panel(p).NaturalFreq;
headerName={'nPoints',sprintf('NFmode')};
T=table(nPoints,NaturalFrequency);
T.Properties.VariableNames=headerName;
writetable(T,filename,'Sheet',3);