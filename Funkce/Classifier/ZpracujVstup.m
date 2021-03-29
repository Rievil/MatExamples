%%
function [data]=ZpracujVstup(time,signal,hustota,img,rychlost)

%     X=dataFFT_F(:,1);
%     Y=dataFFT_F(:,i);

    %findpeaks(Y,X,'MinPeakProminence',1e-4,'Annotate','extents','MinPeakHeight',maxY*0.2,'NPeaks',4,'MinPeakWidth',10,...
    %    'MinPeakDistance',300);
    
    [t,smer,energie]=AnalyzeSignal(time,signal);
    [f,y]=MyFFT(signal,1/(time(2)-time(1)));
    
    idx=f<5.5e+3;
    X2=f(idx);
    Y2=y(idx);
    %plot(X,Y);
    maxY=max(Y2(X2>100));
    [pks,locs,w,p]=findpeaks(Y2,X2,'MinPeakProminence',1e-4,'Annotate','extents','MinPeakHeight',maxY*0.4,'NPeaks',5,'MinPeakWidth',20,'MinPeakDistance',100);
    
    subImg=img;
    if size(img,3)==3
        subImgGrey = rgb2gray(subImg);
    else
        subImgGrey=subImg;
    end

    subImgBin=imbinarize(subImgGrey,'adaptive','ForegroundPolarity','dark','Sensitivity',0.4);
    [counts,binLocations] = imhist(subImgBin);
    %BWRatio=counts;
    BWPixelRatio=counts(1)/counts(2);
        
    Frequnecy=locs(1);
    Amplitude=pks(1);
    Width=w(1);
    Prominence=p(1);
    TotalEnergy=trapz(f,y);

    CasSignalu=t;
    Utlum=smer;
    Energie=energie;
    Class="Unknow";
    Hustota=hustota;
    Rychlost=rychlost;
    
    data=table(Frequnecy,Amplitude,Width,Prominence,TotalEnergy,CasSignalu,Utlum,Energie,Rychlost,Hustota,BWPixelRatio,Class);
end