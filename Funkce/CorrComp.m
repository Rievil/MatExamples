function fig=CorrComp(arr,names,class,varargin)
    arguments
        arr table;
        names string;
        class string;
    end

    arguments (Repeating)
        varargin;
    end

    labels=names;
    marksize=30;
    compact=false;
    cmap='parula';
    mdpi=false;

    while numel(varargin)>0
        switch lower(varargin{1})
            case 'labels'
                labels=varargin{2};
                varargin(1:2)=[];
            case 'markersize'
                marksize=varargin{2};
                varargin(1:2)=[];
            case 'compact'
                compact=varargin{2};
                varargin(1:2)=[];
            case 'colormap'
                cmap=varargin{2};
                varargin(1:2)=[];
            case 'mdpi'
                mdpi=varargin{2};
                varargin(1:2)=[];
        end
    end
    

%     names=["Ratio","ImgEnergy","ImgKurtosis","AvgColB"];
%     lab=["BW ratio $I_{R}$","Energy $I_{E}$","Kurtosis $I_{K}$","Blue channel $\overline{I_{B}}$"];
    X=arr{:,names};
    Y=arr{:,class};

    unqy=unique(Y);
    unqynum=1:numel(unqy);

    if isa(unqy,'logical')
       type='logical';
       unqy_lab=unqy;
    end

    if isa(unqy,'string')
        type='string';
        unqy_lab=unique(Y);
        TU=table(unqy,unqynum','VariableNames',["Name","ID"]);
        Y=table(Y,'VariableNames',{'Name'});
        Y=innerjoin(Y,TU,'Keys','Name');
        Y=Y.ID;
        
    end

    if isa(unqy,'double')
        type='double';
        unqy_lab=string(num2str(unique(Y)));
        TU=table(unqy_lab,unqynum','VariableNames',["Name","ID"]);
        yrows=1:1:size(Y,1);

        Y=table(string(num2str(Y)),yrows','VariableNames',{'Name','Rows'});
        Y=innerjoin(Y,TU,'Keys','Name');
        Y=sortrows(Y,'Rows','ascend');
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
    t=tiledlayout(sz(2),sz(2),'TileSpacing','compact','Padding','compact');
    col=eval(sprintf("%s(numel(unqyy))",cmap));
    cbool=false;
    ax=[]
    for i=1:sz(2)
        for j=1:sz(2)
            nexttile;
            hold on;
            axn=gca;
            ax(end+1)=axn;
            y=X(:,i);
            x=X(:,j);
            


            if i==j
                for s=1:numel(unqynum)
                    idx=Y==unqynum(s);
                    histogram(x(idx),'FaceColor',col(s,:),'DisplayName',unqy_lab(s));
                end
            else
                scatter(x,y,marksize,Y,'o','filled');
                if ~cbool
                    cbool=true;
                    axc=gca;
                end
                
                if compact
                    xt=get(gca,'XTick');
                    yt=get(gca,'XTick');
                    xticks([xt(1),xt(end)]);
                    yticks([yt(1),yt(end)]);
                end
            end
            
            if j==1
                ax(end+1)=ylabel(labels(i),'Interpreter','latex');
            end
    
            if i==sz(2)
                ax(end+1)=xlabel(labels(j),'Interpreter','latex');
            end
            set(gca,'TickDir','out');

            if mdpi
                if axn.XAxis.Exponent==0 && max(x)>=1000
                    xtickformat(axn,'%,0.0f');
                end

                if axn.YAxis.Exponent==0 && max(y)>=1000
                    ytickformat(axn,'%,0.0f');
                end
            end
        end
    end
    lgd=legend('location','northoutside','Orientation','horizontal');
    lgd.Layout.Tile='north';
    % colormap(cmap);
    set(ax,'FontName','Palatino linotype','FontSize',8);
    % cbar=colorbar(axc,'TickLabels',unqy,'Ticks',unqynum,'Position',[0 0 1 1],'TickLength',0);
    % cbar.Layout.Tile='east';
    % cbar.Label.String=class;

    % if mdpi
    %     if max(unqy)>999
    %         cbar.YRuler.TickLabelFormat = '%,0.0f';
    %     end
    % end

    colormap(col);
% SaveMyFig(fig,'ImageFeatures');
end