tic;
figure(1);
hold on;
grid on;
disk='E:\Google Drive'; % skolni disk
stav{1}=[disk '\�kola\Doktorsk� Studium\M��en�\Deska\IE\IE_pred vypalem\'];
stav{2}=[disk '\�kola\Doktorsk� Studium\M��en�\Deska\IE\IE_po vypalu\'];
rady=['ABCDEFGHI'];

Deska=struct();
deg=1;
R=5;

S=5;
    rada=rady(R);
    sloupec=num2str(S);
    filename=[stav{deg} rada '_' sloupec '_Signal.csv'];
    if isfile(filename)
        data=dlmread(filename,';',10,0);
        time=data(:,1);
        budic=data(:,3);
        odezva=data(:,2);

        plot(time,budic);
        plot(time,odezva);
        xlim([-0.005 0.02]);
        ax(1)=gca;
        ylabel('Nap�t� \it U \rm [V]');  
        xlabel('�as \it t \rm [s]');
        legend('Sign�l budi�e','Sign�l sn�ma�e');
        
        axes('Position',[.45 .33 .4 .35]);
        hold on;
        grid on;
        box on;
        plot(time,budic);
        plot(time,odezva);
        axis([-0.0005 0.00022 -0.05 0.05]);
        ax(2)=gca;

    end

set(ax,'LineWidth',1.2,'FontSize',10,'FontName','Palatino linotype');
set(gcf,'Position',[200 200 600 300]);
%ReduceWhiteFrame(-0.01,0,0,0);

time=toc;
saveas(1,['E:\Google Drive\�kola\Doktorsk� Studium\Dizerta�n� pr�ce\Dizerta�n� pr�ce\Obr�zky\CasZeSignalu.png']);

ans=time;
%%

%%
DataPred=Deska(1).Data;
DataPo=Deska(2).Data;
radky=[1 2 3 4 5 6 7 8 9];
sloupce=[1 2 3 4 5 6 7 8 9];
strTitle='Zm�na �asu pro p�estup vlny z klad�vka do sn�ma�e';
ang1=-40;
ang2=30;

figure(1);
%1
ax1=subplot(1,2,1);
hold on;
grid on;
%______________

[Xq,Yq] = meshgrid(0:0.25:9);
Vq = interp2(sloupce,radky,DataPred,Xq,Yq,'cubic');
surf(Xq,Yq,Vq);
%title('Cubic Interpolation Over Finer Grid');
colormap (ax1,'winter');
%________________
%surf(F5Pred);


view(ang1,ang2);
set (gca,'Zdir','reverse');
%axis([0 9 0 8 0 0.3e-3]);
xlabel('Sloupec');
ylabel('Rada');
zlabel('Doba t [s]');
title('P�ed v�palem');

%2
ax2=subplot(1,2,2);

%_____________
[Xq,Yq] = meshgrid(0:0.25:9);
Vq = interp2(sloupce,radky,DataPo,Xq,Yq,'cubic');
surf(Xq,Yq,Vq);
%_____________
colormap (ax2,'spring');
%surf(F5Po);
set (gca,'Zdir','reverse');
view(ang1,ang2);
xlabel('Rada');
ylabel('Sloupec');
zlabel('Doba t [s]');
title('Po v�palu');
%axis([0 9 0 8 0 0.3e-3]);
set(gcf,'position',[40,40,1200,600]);
suptitle(strTitle);
%saveas(1,['D:\Data\Disk Google\�kola\Doktorsk� Studium\Dokumenty\�l�nky\2019 29 05 - NDT Semin��\Grafy\IE_casy_z_signalu.png']);
