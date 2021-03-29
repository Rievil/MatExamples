function [ax]=MatrixSepNatFreq(Hits,Sen,SizeOrg,MaxFreq)
    %Hits=MODR(1).Date(1).Mea(1).Hits;
    %Sen=1;
    
    ax(1)=axes('Position',[0 0.3 0.9 0.6]);
    hold on;
    box on;
    grid on;
    %ax=gca;
    %Hits=je struktura uderu
    %Sen=je èislo snímaèe, který chceme vykreslit
    
    %napred zjisti maximalni a minimalni hodnoty vsech hitu
    n=0;
    count=double(0);
    for i=1:length(Hits)
        for fr=1:length(Hits(i).Snimac(Sen).Fn)
           n=n+1;
           count=vertcat(count,Hits(i).Snimac(Sen).FnCount);
        end
    end
    count=sort(count,'ascend');
    minCount=min(count);
    maxCount=max(count);
    
    if minCount==0
        minCount=0.5;
    end
    
    X=[Hits.Sourx]; 
    Y=[Hits.SourY];   

    
    for i=1:length(Hits)
              clear RGB;
        %colormap
        % Example plot with colormap
        %h = surf(peaks);
        Cdata=Hits(i).Snimac(Sen).Fn;
        cmap=colormap(jet);
        % make it into a index image.
        cmin = 0;
        cmax = MaxFreq;
        m = length(cmap);
        index = fix((Cdata-cmin)/(cmax-cmin)*m)+1; %A
        % Then to RGB
        RGB = ind2rgb(index,cmap);
       
       
       for fr=1:length(Hits(i).Snimac(Sen).Fn)
           Z=Hits(i).Snimac(Sen).Fn(fr);
           Size=Hits(i).Snimac(Sen).FnCount(fr);
           RGBtmp=[RGB(fr,1,1) RGB(fr,1,2) RGB(fr,1,3)];
           plot3(X(i),Y(i),Z,'d','color',RGBtmp,'MarkerFaceColor',RGBtmp,'MarkerSize',(Size/maxCount+minCount)*SizeOrg); 
           
       end
    end
    
    col=colorbar;
    caxis([0 MaxFreq]);
    daspect ([1 1 8000]);
    col.Position=[0.85 0.3 0.02 0.6];
    col.Direction ='reverse';
    col.Label.String='Frequency \it f \rm [Hz]';
    col.Ruler.Exponent = 3;
    ax(3)=col;
    
    ax(1).ZDir = 'reverse';
    view(-50,14);
    zlabel('Frequency \it f \rm [Hz]');
    xlabel('Length [m]');
    ylabel('Width [m]');
    zlim([0 MaxFreq]);
    
    ax(2)=axes('Position',[0.1 0.08 0.8 0.08]);
    hold on;
   
    %vykresleni legendy velikosti
    bestDiv=(maxCount-minCount)/5;
    x=double(minCount:bestDiv:maxCount);
    y(1:1:length(x))=double(1);
    
    set(get(ax(2),'Yaxis'),'Color','none');
    
    for i=1:length(x)
        plot(round(x(i),0),y(i),'d','MarkerSize',(x(i)/maxCount+minCount)*SizeOrg,'MarkerFaceColor','none','MarkerEdgeColor','k');
    end
    xticks(round(x,0));
    ylim([0.5 1.5]);
    xlabel('Number of frequencies');
end
