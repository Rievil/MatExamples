%nastaveni orezavaciho ramecku dle posledniho nejtmavsiho snimkiu cele sady
disk='D:\Data\Disk Google';
%disk='E:\Google Drive';
%%
%vytvoøení výøezového rámeèku z první fotky celé sestavy
%clear all;
%disk='D:\Data\Disk Google';
%FotkySlozka='H:\MereneData\2019\FCH\Hex v krabici\';
FotkySlozka='H:\MereneData\2019\FCH\Hex v krabici\';
tmp=dir([FotkySlozka '*.jpg']);
datum=datetime([tmp.datenum],'ConvertFrom','datenum');

files = tmp;
vel=size(files);
filename=[files(vel(1)).folder '\' files(vel(1)).name];
RGBImage=imread(filename);
originalImage = imread(filename);
originalImageBW = rgb2gray(originalImage);

%Hodnota prahové hodnoty pod kterou vytvoøí binární obrázek z BW
%negativu,pokud hledám tmavší tak použiju <, pokud svìtlejší tak >
thresholdValue = 121;
binaryImage = originalImageBW < thresholdValue;
binaryImage = imfill(binaryImage, 'holes');
labeledImage = bwlabel(binaryImage, 8);  
blobMeasurements = regionprops(labeledImage, originalImageBW,'all','Perimetr');

allBlobAreas = [blobMeasurements.Area];
%ze všech detekovaných oblastí vyberu jen  ty, jejichž plocha je na 4e+5
%pixelù
keeperIndexes = find(allBlobAreas > 4e+5);  

Ramecek=struct();
snimek=0;
for i=keeperIndexes
    snimek=snimek+1;
    %vyberu tìžištì vybraných obrazcù
    center=blobMeasurements(i).Centroid;
    
    width=310;  %napevno nastavená šíøka rámeèku
    height=1200;    %napevno nastavená výška rámeèku
    %vytvoøím výøezy z každého snímku pro poèet detekovaných tìles
    cropFrame=[center(1)-width/2 center(2)-height/2 width height];   %[xmin ymin width height]
    
    Ramecek(snimek).Obrys=cropFrame;
    % Extract out this coin into it's own image.
    
    subImage = imcrop(RGBImage, cropFrame);

    subplot(1, 4, snimek);

    imshow(subImage);
end

%%
%zobrazeni jediného snímku

n=220;
filename=[files(n).folder '\' files(n).name];
%
RGBImage=imread(filename);

snimek=0;
for i=1:size(Ramecek,2)
    snimek=snimek+1;
    cropFrame=Ramecek(snimek).Obrys;
    subImage = imcrop(RGBImage, cropFrame);
    subplot(1, size(Ramecek,2), snimek);
    imshow(subImage);
end
    %%
    %vytvoøení kalorimetrických dat
figure(1);
hold on;
%disk='E:\Google Drive';
load([disk '\Škola\Doktorské Studium\Mìøení\FCH\Kalor2.mat']);
%start=files(1).datenum;
%Kalor2=struct();
n=0;
%load([disk '\Škola\Doktorské Studium\Mìøení\FCH\Sample_Kalor_v2.mat']);
%load([disk '\Škola\Doktorské Studium\Mìøení\FCH\Promene_kalor_Sample.mat']);

for i=[1 3 5 7]
    n=n+1;
    %cas=KalorimetrTMP(:,i);
    %t=datetime(cas,'ConvertFrom','datenum');
%     Kalor2(n).Name=sprintf('Hex %d',n);
%     Kalor2(n).Time=eval(['TMP' num2str(n) '(:,1)']);
%     Kalor2(n).Value=eval(['TMP' num2str(n) '(:,2)']);
    plot(Kalor2(n).Time,Kalor2(n).Value);
end
    xlim([Kalor2(1).Time(1) Kalor2(1).Time(2800)]);
    %ylim([0 180]);
    datetick('x','dd','keeplimits');
%%
%prùchod všemi snímky a mìøení intenzity zmìny barvy
clear cas Sample;
Sample=struct();
tic;
for i=1:size(files,1)
%     subplot(5,PocetMereni,i);
%     imshow(Mereni(i).Image(snimek).Sub);
    cas=files(i).datenum;
    t2=datetime(cas,'ConvertFrom','datenum');
    
    
    filename=[files(i).folder '\' files(i).name];
    RGBImage=imread(filename);

    for snimek=1:1:4
        cropFrame=Ramecek(snimek).Obrys;
        subImage = imcrop(RGBImage, cropFrame);
        
        r=mean(mean(subImage(:,:,1)));
        g=mean(mean(subImage(:,:,2)));
        b=mean(mean(subImage(:,:,3)));
        
        Sample(snimek).Inz(i).Time=t2;
        Sample(snimek).Inz(i).RGB=[r g b];
        Sample(snimek).Inz(i).RGBSum=r+g+b;  
        
    end
end
elapsedtime=toc
%%
for i=[1]
%     TMP=[Sample(i).Inz(:).Time];
%     Sample(i).Inz=rmfield(Sample(i).Inz,'Time');
%     
%     cas=datenum(TMP);
%     cas=cas-cas(1);
    for j=1:1:1345
        Sample(i).Inz(j).Time=cas(j);
    end
end

%%
%citace
citaceStr=sprintf(['FELDMAN, R. a P. SEREDA. A model for hydrated Portland cement paste as ' ...
                   'deduced from sorption-length change \nand mechanical properties. Matériaux et Constructions.' ...
                   'vol. 1. 1968, 1(6), 509-520. DOI: 10.1007/BF02473639. ISSN 0025-5432. \nDostupné také z:' ...
                   'http://link.springer.com/10.1007/BF02473639']);
%
%animovaný graf
fig=figure(1);
%disk='E:\Google Drive';
load([disk '\Škola\Doktorské Studium\Mìøení\FCH\Sample_Kalor_v2.mat']);
%grid on;
set(gcf,'Position',[200 200 1200 800]);
export=struct();
brig=0.02;   %úprava jasu zluté køivky a osy
barva={[0/255 103/255 188/255],[255/255-brig 198/255-brig 30/255-brig]};
popis={'Hex-0','Hex-0.5','Hex-1.0','Hex-2.0'};
for n=[1 2 3 4]
    yyaxis left;
    hold on;
    ax(1)=gca;
    
    time=Kalor2(n).Time;
    time2=time-Kalor2(n).Time(1);
    %time3Dat=datetime(time3,'InputFormat','HH:mm:ss');
    
    %kalVal2=cumtrapz(Kalor(n).Value);
    kalVal2=Kalor2(n).Value;
    
    time2=datenum(time2);
    
    plKal(n)=plot(time2,kalVal2,'LineWidth',2.3,'DisplayName',['Cal. ' popis{n}],'Color',barva{1});
    
    export(1).name='Kalorimetr';
    export(1).mereni(n).x=time2;
    export(1).mereni(n).y=kalVal2;
    
    %ylim([0 2]);
    ylim([0 330]);    
    ylabel('Cummulative Heat (J/g of slag) ');
    xlabel('Time (days)');
    set(ax(1),'Ycolor',barva{1});
    
    xticks([0:2:16]);
    yticks(0:50:400);
    
    yyaxis right;
    hold on;

    time=[Sample(n).Inz.Time];
    values=[Sample(n).Inz.RGBSum];
    
    time3=(time-time(1));
    %time2Dat=datetime(time2,'InputFormat','HH:mm:ss');
    %polyfit datove øady___________________
    xtmp=time3;
    ytmp=(255*3-values)';
    ytmp2=smooth(ytmp,25,'sgolay');
    
    %Sample(n).Inz.RGBSumSmoothed=ytmp2;
    %Sample(n).Inz.TimeFin=time3;
    
    time3=datenum(time3);
    plBit(n)=plot(time3,ytmp2,'LineWidth',2.3,'DisplayName',['Sum of bits ' popis{n}],'Color',barva{2});
    
    export(2).name='Kalorimetr';
    export(2).mereni(n).x=time3;
    export(2).mereni(n).y=ytmp2;
    
    ylim([190 1000]);
    ylabel('Paste darkness (\Sigma bit^{-1})');
    xlim([time3(1) time3(end)]);
    ax(2)=gca;
    set(ax(2),'Ycolor',barva{2},'YMinorTick','on');
    %ax.XAxis.TickLabelFormat='d';
    xlim([time3(1) time3(700)]);
    yticks(0:100:1000);
    set(ax,'YMinorTick','on');
    %gca.YAxis.MinorTickValues = 0:25:400;
    %gca.YAxis.MinorTickValues = 0:100:1000;
end
yyaxis left;

%set(ax,'YMinorTick','on','FontSize');
%
%vykresleni obrazku a cary________________________________________
%prvotni vykresleni objektù
hold on;
nSample=300;    %èíslo snímku
xq=[time3(nSample) time3(nSample)];
plCus(9)=plot(xq,[0 175],':','LineWidth',1.8,'Color','k');
off=[0.24 -0.24];    %offset pro pøedsazení popisku pohyblivých bodù
popStrSize=18;
for i=1:1:4
    %kal
    yyaxis left;
    hold on;
    x2=get(plKal(i),'Xdata') ;
    y2=get(plKal(i),'Ydata') ;
    col=get(plKal(i),'Color');
    vq1 = interp1(x2,y2,xq(1));
    plCus(i)=plot(xq(1),vq1,'o','Color',col,'MarkerFaceColor',col,'MarkerSize',10,'MarkerEdgeColor','k');
    set(gca,'Layer','top');
    tx(i)=text(xq(1)+off(1),vq1,['Heat ' popis{i}],'Units','data','FontSize',popStrSize);
    %bit
    yyaxis right;
    hold on;
    x3=get(plBit(i),'Xdata') ;
    y3=get(plBit(i),'Ydata') ;
    col=get(plBit(i),'Color');
    vq2 = interp1(x3,y3,xq(1));
    plCus(4+i)=plot(xq(1),vq2,'o','Color',col,'MarkerFaceColor',col,'MarkerSize',10,'MarkerEdgeColor','k');
    set(gca,'Layer','top');
    tx(i+4)=text(xq(1)+off(2),vq2,['Bits. ' popis{i}],'Units','data','FontSize',popStrSize,'HorizontalAlignment','right');
end



%set(plCus(9),'Layer','bottom');

%
str=sprintf('%.2f',round(datenum(xq(1)),2));
tx(9)=text(xq(1),640,str,'FontSize',18,'HorizontalAlignment','center');

han=horzcat(plKal,plBit);
% lgd=legend(han,'Location','northeast');
% lgd.NumColumns=2;
% lgd.FontSize=12;

set(ax,'LineWidth',3,'XMinorTick','on','YMinorTick','on','FontSize',19,'FontName','Arial');

filename=[files(nSample).folder '\' files(nSample).name];
RGBImage=imread(filename);
snimek=0;
pozObrazku=[0.10 0.18 0.35 0.48];
for i=1:4

    snimek=snimek+1;

    cropFrame=Ramecek(snimek).Obrys;
    subImage = imcrop(RGBImage, cropFrame);

    %subplot(1, 4, snimek);
    axes('pos',[pozObrazku(i) .58 .14 .3]);
    imHan(i)=imshow(subImage);
    tit(i)=title(popis{i});
    tit(i).FontName='Arial';
    tit(i).FontSize=18;
end


%h1 = get(ax(1),'Children');
%set(ax(1),'Children',[h1(3)]);


% h1 = get(ax(2),'Children');
% set(ax(2),'Children',[h1(1) h1(2) h1(3) h1(6) h1(7) h1(8) h1(9) h1(10) h1(11) h1(12) h1(13) h1(14) h1(1) h1(2)]);
%h = get(ax(2),'Children');
%uistack(plCus(9),'down',2);
%text(0.1,0.1,citaceStr);
annotation('textbox', [0.12, 0.91, 0.1, 0.1],'String', ...
    citaceStr,'Color',[0.4 0.4 0.4],'EdgeColor','none','FontSize',12)
%
%animacni cast celeho grafu________________________________________________
%aktualizace souradnic jednotlivých objektù
tic;

video = VideoWriter([disk '\Škola\Doktorské Studium\Mìøení\FCH\VideaFCHHex\Alkal_48fps_Q90_v4.mp4']); %create the video object
video.FrameRate=48;
video.Quality=90;
open(video); %open the file for writing
%set(gca,'XMinorTick','off');
%files=dir(['E:\TMP\Hex v krabici\' '*.jpg']);

set(fig,'CurrentAxes',ax(1))

PocetSouboru=size(files,1);
%1:1:692
for i=[1 2 3 4]
    delete(tx(i));
    delete(tx(i+4));
end
bool1=0;
bool2=0;
bool3=0;
for nSample=1:1:692
    xq=[time3(nSample) time3(nSample)];
    %xqnum=datenum(xq);
    for i=1:1:4
        %kal
        yyaxis left;
        hold on;
        set(fig,'CurrentAxes',ax(1))
        x2=get(plKal(i),'Xdata') ;
        y2=get(plKal(i),'Ydata') ;
        vq1 = interp1(x2,y2,xq(1));

        set(plCus(i),'Xdata',xq(1));
        set(plCus(i),'Ydata',vq1);
        
        if nSample==99
            tx(i)=text(xq(1)+off(2),vq1,['Heat ' popis{i}],'Units','data','FontSize',popStrSize,'HorizontalAlignment','right');
        end
        
        if nSample>100
            delete(tx(i));
            tx(i)=text(xq(1)+off(2),vq1,['Heat ' popis{i}],'Units','data','FontSize',popStrSize,'HorizontalAlignment','right');
        else
            delete(tx(i));
        end
        set(ax,'YMinorTick','on','XminorTick','on');
        %bit
        yyaxis right;
        hold on;
        set(fig,'CurrentAxes',ax(2));
        x3=get(plBit(i),'Xdata') ;
        y3=get(plBit(i),'Ydata') ;
        vq2 = interp1(x3,y3,xq(1));
        set(plCus(4+i),'Xdata',xq(1));
        set(plCus(4+i),'Ydata',vq2);
        
        
        if nSample==1
            tx(i+4)=text(xq(1)+off(1),vq2,['Bits ' popis{i}],'Units','data','FontSize',popStrSize,'HorizontalAlignment','left');
        end
        
        if nSample<599
            delete(tx(i+4));
            tx(i+4)=text(xq(1)+off(1),vq2,['Bits ' popis{i}],'Units','data','FontSize',popStrSize,'HorizontalAlignment','left');
        else
            delete(tx(i+4));
        end
    end
    set(plCus(9),'Xdata',xq);
    str=sprintf('%.2f',round(datenum(xq(1)),2));
    delete(tx(9));
    tx(9)=text(xq(1),640,str,'FontSize',18,'HorizontalAlignment','center');



    %_________aktualizace snimkù
    filename=[files(nSample).folder '\' files(nSample).name];
    RGBImage=imread(filename);
    snimek=0;
    for i=1:4
        snimek=snimek+1;
        cropFrame=Ramecek(snimek).Obrys;
        subImage = imcrop(RGBImage, cropFrame);
        set(imHan(i),'CData',subImage);
    end
    
    set(ax,'YMinorTick','on','XminorTick','on');
    ax(2).XAxis.MinorTickValues = 1:0.5:15;
   % ax(2).YAxis.MinorTickValues = 0:25:400;
    frame = getframe(gcf);
    writeVideo(video,frame);
end
close(video); %close the file
ans={'Elapsed time: %.f2',toc}


%saveas(1,[disk '\Škola\Doktorské Studium\Mìøení\FCH\Export_v2.png']);
%%
tic;
filename=[disk '\Škola\Doktorské Studium\Mìøení\FCH\Export_Kalormietr_sumaBitu.xlsx'];
clear x1 y1 x2 y2 x3 y3 x4 y4;
x1=export(1).mereni(1).x;
y1=export(1).mereni(1).y;
x2=export(1).mereni(2).x;
y2=export(1).mereni(2).y;
x3=export(1).mereni(3).x;
y3=export(1).mereni(3).y;
x4=export(1).mereni(4).x;
y4=export(1).mereni(4).y;

T=table(x1,y1,x2,y2,x3,y3,x4,y4);
writetable(T,filename,'Sheet',1,'WriteVariableNames',true);
clear x1 y1 x2 y2 x3 y3 x4 y4;
x1=export(2).mereni(1).x';
y1=export(2).mereni(1).y;
x2=export(2).mereni(2).x';
y2=export(2).mereni(2).y;
x3=export(2).mereni(3).x';
y3=export(2).mereni(3).y;
x4=export(2).mereni(4).x';
y4=export(2).mereni(4).y;

T2=table(x1,y1,x2,y2,x3,y3,x4,y4);
writetable(T2,filename,'Sheet',2,'WriteVariableNames',true);
elapsedtime=toc
%%
subplot(5,PocetMereni,1);
ylabel('Teleso 1');
subplot(5,PocetMereni,PocetMereni+1);
ylabel('Teleso 2');
subplot(5,PocetMereni,PocetMereni*2+1);
ylabel('Teleso 3');
subplot(5,PocetMereni,PocetMereni*3+1);
ylabel('Teleso 4');

subplot(5,PocetMereni,PocetMereni*4+1:PocetMereni*5);
hold on;
grid on;
plot(Casy,Vystup(:,1),'-o','DisplayName','Teleso 1.');
plot(Casy,Vystup(:,2),'-d','DisplayName','Teleso 2.');
plot(Casy,Vystup(:,3),'-x','DisplayName','Teleso 3.');
plot(Casy,Vystup(:,4),'-+','DisplayName','Teleso 4.');
xlabel('Èas');
ylabel('Suma bitù kanálù \it r g b \rm');
legend('location','southeast');
set( gca, 'YDir', 'reverse' )
set(gcf, 'Units','Normalized','OuterPosition',[0 0 1 1]);
saveas(1,['E:\Google Drive\Škola\Doktorské Studium\Mìøení\FCH\VystupZMereni.png']);
n=0;


%%
figure(1);
hold on;
box on;
Casy2=datetime(Casy,'InputFormat','dd.MMM.yyyy hh:mm:ss','Format','dd.mm');

p(1)=plot(rozdilDen,(3*255-Vystup(:,1)),'-k','DisplayName','Teleso 1.');
p(2)=plot(rozdilDen,(3*255-Vystup(:,2)),'--k','DisplayName','Teleso 2.');
p(3)=plot(rozdilDen,(3*255-Vystup(:,3)),'-.k','DisplayName','Teleso 3.');
p(4)=plot(rozdilDen,(3*255-Vystup(:,4)),':k','DisplayName','Teleso 4.');

plot([rozdilDen(3) rozdilDen(3)],[0 630],'-r','LineWidth',1.5);
xlabel('Èas (dny)');
ylim([140 1100]);
xlim([0 14]);
ylabel('Suma bitù kanálù \it rgb \rm (bit)');
legend(p,'location','northeast');
set( gca,'LineWidth',1.5,'XMinorTick','on','YMinorTick','on','FontSize',15,'FontName','Arial');
%set(gca,'Format','dd.mm');
%datetick('x','dd','keepticks');
%
set(gcf,'Position',[20 20 800 600]);
sour={[.05 .6 .3 .3],[.1 .6 .32 .3],[.15 .6 .34 .3],[.2 .6 .37 .3]};
axes('pos',sour{1})
imshow(Mereni(15).Image(1).SubIn);
axes('pos',sour{2})
imshow(Mereni(15).Image(2).SubIn);
axes('pos',sour{3})
imshow(Mereni(15).Image(3).SubIn);
axes('pos',sour{4})
imshow(Mereni(15).Image(4).SubIn);
annotation('textbox',[.178 .3 .3 .3],'String','T1','EdgeColor','none','FontSize',15);
annotation('textbox',[.240 .3 .3 .3],'String','T2','EdgeColor','none','FontSize',15);
annotation('textbox',[.302 .3 .3 .3],'String','T3','EdgeColor','none','FontSize',15);
annotation('textbox',[.364 .3 .3 .3],'String','T4','EdgeColor','none','FontSize',15);

saveas(1,['E:\Google Drive\Škola\Doktorské Studium\Mìøení\FCH\UkazkaHotovGraf.emf']);

%%
PocetMereni=size(Mereni,2);
figure(1);
Casy={Mereni(:).DateTime};
Teleso1={Mereni(:).Image(1).RGB(1)};
%%
n=n+1;
figure(n);
subplot(1,2,1);
greenchannel = subImageUvnitr(:, :, :);
[pixelCount, grayLevels] = imhist(subImageUvnitr);
bar(pixelCount);
subplot(1,2,2);
imshow(greenchannel);
%%

    Filename=[files(i).folder '\' files(i).name]; 

    baseFileName=Filename;

    % If we get here, we should have found the image file.
    RGBImage=imread(baseFileName);
    originalImage = imread(baseFileName);
    % Check to make sure that it is grayscale, just in case the user substituted their own image.
    [rows, columns, numberOfColorChannels] = size(originalImage);
    if numberOfColorChannels > 1
        originalImage = rgb2gray(originalImage);
    end

    thresholdValue = 121;
    binaryImage = originalImage < thresholdValue; % Bright objects will be chosen if you use >.
    % ========== IMPORTANT OPTION ============================================================
    % Use < if you want to find dark objects instead of bright objects.
    %   binaryImage = originalImage < thresholdValue; % Dark objects will be chosen if you use <.
    % Do a "hole fill" to get rid of any background pixels or "holes" inside the blobs.
    binaryImage = imfill(binaryImage, 'holes');
    % Show the threshold as a vertical red bar on the histogram.
    labeledImage = bwlabel(binaryImage, 8);
    
    blobMeasurements = regionprops(labeledImage, originalImage,'all','Perimetr');
    NumberOfBlobs=size(blobMeasurements,1);
    
    figure(1);
    snimek=0;
    for k = 1 : NumberOfBlobs           % Loop through all blobs.
        if blobMeasurements(k).Area > 400e+3
            snimek=snimek+1;
            % Find the bounding box of each blob.
            thisBlobsBoundingBox = blobMeasurements(k).BoundingBox;  % Get list of pixels in current blob.
            eqi=100;
            thisBlobsBoundingBox(1)=thisBlobsBoundingBox(1)-eqi;
            thisBlobsBoundingBox(2)=thisBlobsBoundingBox(2)-eqi;
            thisBlobsBoundingBox(3)=thisBlobsBoundingBox(3)+eqi*2;
            thisBlobsBoundingBox(4)=thisBlobsBoundingBox(4)+eqi*2;
            % Extract out this coin into it's own image.
            subImage = imcrop(RGBImage, thisBlobsBoundingBox);
            % Determine if it's a dime (small) or a nickel (large coin).

            % Display the image with informative caption.
            subplot(3, 4, snimek);
            imshow(subImage);
            caption = sprintf(files(i).date,' - vzorek: ',k);
            title(caption);


        end
    end

