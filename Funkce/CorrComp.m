function fig=CorrComp(arr,names,class)
    arguments
        arr table;
        names string;
        class string;
    end
%     names=["Ratio","ImgEnergy","ImgKurtosis","AvgColB"];
%     lab=["BW ratio $I_{R}$","Energy $I_{E}$","Kurtosis $I_{K}$","Blue channel $\overline{I_{B}}$"];
    X=arr{:,names};
    Y=arr{:,class};
    unqy=unique(Y);
    unqynum=1:numel(unqy);
    if isa(unqy,'logical')
       type='logical';
    end

    if isa(unqy,'string')
        type='string';
        arr=1:numel(unqy);
        TU=table(unqy,arr','VariableNames',["Name","ID"]);
        Y=table(Y,'VariableNames',{'Name'});
        Y=innerjoin(Y,TU,'Keys','Name');
        Y=Y.ID;
    end

    switch type
        case 'double'
            unqyy=double(unqy);
        case 'logical'
            unqyy=double(unqy);
        case 'char'
            unqyy=linspace(1,numel(unqy),numel(unqy))';
        case 'string'
            unqyy=linspace(1,numel(unqy),numel(unqy))';
        case 'cell'
            unqyy=linspace(1,numel(unqy),numel(unqy))';
    end
    sz=size(X);
    fig=figure('position',[0 80 460 500]);
    t=tiledlayout(sz(2),sz(2),'TileSpacing','tight','Padding','tight');
    col=parula(numel(unqyy));
    cbool=false;
    ax=[]
    for i=1:sz(2)
        for j=1:sz(2)
            nexttile;
            hold on;
            ax(end+1)=gca;
            y=X(:,i);
            x=X(:,j);
            
            if i==j
                for s=1:numel(unqynum)
                    idx=Y==unqynum(s);
                    histogram(x(idx),'FaceColor',col(s,:));
                end
            else
                scatter(x,y,30,Y,'o','filled');
                if ~cbool
                    cbool=true;
                    axc=gca;
                end
            end
            
            if j==1
                ax(end+1)=ylabel(names(i),'Interpreter','latex');
            end
    
            if i==sz(2)
                ax(end+1)=xlabel(names(j),'Interpreter','latex');
            end
            set(gca,'TickDir','out');
        end
    end
    
    set(ax,'FontName','Palatino linotype','FontSize',8);
    cbar=colorbar(axc,'TickLabels',unqy,'Ticks',unqynum,'Position',[0 0 1 1],'TickLength',0);
    cbar.Layout.Tile='east';
    cbar.Label.String=class;
    colormap(col);
% SaveMyFig(fig,'ImageFeatures');
end