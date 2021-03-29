%%
%disk='E:\Google Drive'; % školní disk
disk='D:\Data\Disk Google'; %bytový disk
cd ([disk '\Škola\Doktorské Studium\Dokumenty\Matlab\Matlab_funkce']);
cestagrafu=[disk '\Škola\Doktorské Studium\Mìøení\Hela_ŽBPanely\Grafy\'];
cestadat='H:\RD_modal\Panely\';
panel={'Panel I','Panel II'};
rada={'Rada 1','Rada 2','Rada 3','Rada 4','Rada 5'};
snimac={'Horni snimac','Ohyb','Podel'};
%%
%vytvoreni predpisu pro orientaci po bodech
%z hotove analýzy ulozeni výstupu
p=2;

ColCount=Mereni(p).Description.XPCount;
RowCount=Mereni(p).Description.YPCount;

pocetModu=length(Mereni(p).Rada(r).Sloupec(s).Snimac.Fn);

for mode=1:pocetModu
    bod=0;
    for r=1:1:RowCount
        for s=1:1:ColCount
            bod=bod+1;
            Mereni(p).NaturalFreq(bod,mode)=Mereni(p).Rada(r).Sloupec(s).Snimac.Fn(mode);
            Mereni(p).Damping(bod,mode)=Mereni(p).Rada(r).Sloupec(s).Snimac.Dr(mode);
            Mereni(p).ModeShapes(bod,mode)=Mereni(p).Rada(r).Sloupec(s).Snimac.Ms(mode);
        end
    end
end
%%
%zpracování grafù dle jednotlivých módù
mode=9;
for p=[1 2]
    Matrix=Mereni(p).EXTab.Matrix;
    ColCount=Mereni(p).Description.XPCount;
    RowCount=Mereni(p).Description.YPCount;
    Vystup=struct();
    for s=1:1:ColCount
       for r=1:1:RowCount
           nPoint=Matrix(s,r);
           Frekvence{p,mode}(r,s)=Mereni(p).NaturalFreq(nPoint,mode);
           Utlum{p,mode}(r,s)=Mereni(p).Damping(nPoint,mode);
           Deformace{p,mode}(r,s)=Mereni(p).ModeShapes(nPoint,mode);
       end
    end
end
sourx=[0 .7 .14 .21 .28 .35 .42 .49 .56];
soury=[0 .6 .12 .18 .24 .30 .36 .42 .48];

%frekvence__________________
figure(1);
subplot(1,2,1);
hold on;
grid on;
box on;
colormap([1 0 0;0 0 1])
surf(Frekvence{1,mode},'FaceColor','b', 'FaceAlpha',0.5, 'EdgeColor','none');
surf(Frekvence{2,mode},'FaceColor','r', 'FaceAlpha',0.5, 'EdgeColor','none');

zlabel('Frekvence');
legend('Pred vypalem','Po vypalu');
zlim([0 4000]);
view(33,4);
%utlum_____________________
subplot(1,2,2);
hold on;
grid on;
box on;

surf(Utlum{1,mode},'FaceColor','b', 'FaceAlpha',0.5, 'EdgeColor','none');
surf(Utlum{2,mode},'FaceColor','r', 'FaceAlpha',0.5, 'EdgeColor','none');
zlabel('Frekvence');
legend('Pred vypalem','Po vypalu');
zlim([0 1]);
view(33,4);


%%
figure(1);
hold on;
clear x y;
box on;
grid on;

mode=3;
p=1;

zBUnit=Mereni(p).Predpis(1,5);
%x=Panel(p).Predpis(:,3);
x=sourx;
y=soury;
%y=Panel(p).Predpis(:,4);
z0=ones(length(y),length(x))*zBUnit;

Xcal=(max(x)-min(x))/2;
Ycal=(max(y)-min(y))/2;

fn=mean(Mereni(p).NaturalFreq,1);
PickedFn=fn(mode);
dr=Mereni(p).Utlum;
ms=Mereni(p).ModeShapes; %modeshape

%nastaveni period_________________________________________
wn = PickedFn*2*pi;  % Mode frequency in rad/sec
T = 1/PickedFn;      % Period of modal oscillation
Np  = 2.25;             % Number of periods to simulate
tmax = Np*T;            % Simulate Np periods
Nt = 100;               % Number of time steps for animation
t = linspace(0,tmax,Nt);
%_________________________________________________________

ThisMode = ms(:,mode)/max(abs(ms(:,mode))); %znormalizovany tvar pro vsechny mody
z=ThisMode;


%nyní musím otoèit a rozdìlit pole do surface plochy
z2(1:length(z)+1)=0;
z2(2:end)=z;
for r2=1:1:5
    tmp3=z2((r2-1)*15+r2:r2*16);
    if mod(r2,2)==0
        tmp3=rot90(tmp3,-2);
    end
    z3(r2,:)=tmp3;
end

A=z3(:,1:3);
B=z3(:,5:12);
C=z3(:,14:16);
z4=horzcat(A,B);
z4=horzcat(z4,C);

%
surf(x-Xcal,y-Ycal,z0,'LineStyle','--','FaceColor','none');  %puvodni tvar

axis([-Xcal*1.2 Xcal*1.2 -Xcal*1.2 Xcal*1.2 0.6 0.8]);
set(gcf,'Position',[200 200 700 450]);
title(sprintf('Panel è. %d, Mod è. %d, frekvence=%0.1f Hz',p,mode,PickedFn));
xlabel('Rozmer site bodu x [m]');
ylabel('Rozmer site bodu y [m]');
zlabel('Amplituda');
view(28,24);
sor=[-0.7535,-0.14,0.7];
bod=plot3(sor(1),sor(2),sor(3),'dr','MarkerFaceColor','r');
text(sor(1)-0.2,sor(2),sor(3)-0.02,'Pozice snimaèù');

writerObj = VideoWriter([disk '\Škola\Doktorské Studium\Dizertaèní práce\Dizertaèní práce\ModalAnalysis\Mereni_' num2str(p) '_Mod_' num2str(mode) '.avi']);
writerObj.FrameRate = 10;
open(writerObj);
for k=1:Nt
    Rot1 = cos(wn*t(k));
    Rot2 = sin(wn*t(k));
    z_t = (real(z4)*Rot1 - imag(z4)*Rot2)*0.1;
    
    if k==1
        graf=surf(x-Xcal,y-Ycal,z_t,'LineStyle','-');
        ann=text(0.8,0.1,0.9,sprintf('Cas an.= %d',k));
    end
    
    set(graf,'ZData',z_t+0.7)
    set(ann,'String',sprintf('Cas an.= %d',k));
    pause(0.1);
    %F(k)=getframe(gcf);
    F=getframe(gcf);
    writeVideo(writerObj, F);
end

close(writerObj);