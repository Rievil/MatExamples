function [fig,ax1]=PlotPipe(TFG2,TA)
    fig=figure('position',[0 80 750 750]);
    t=tiledlayout('flow','TileSpacing','tight','Padding','tight');
    nexttile;
    hold on;
    box on;
    grid on;
    ax1=gca;
    
    unqdepth=unique(TFG2.Depth);
    yvallabel='GuessClass';
    go=[];
    xa=[];
    ya=[];
    za=[];
    fr=[];
    for ln=1:numel(unqdepth)
        Tia=linspace(unqdepth(ln),unqdepth(ln),size(TA,1))';
        Tib=linspace(unqdepth(ln),unqdepth(ln),size(TFG2,1))';
        
        Idxi=TFG2.Depth==unqdepth(ln);
        if ln==1
            go(end+1)=scatter3(ax1,TFG2.X(Idxi),Tib(Idxi),TFG2.Y(Idxi),200,TFG2.(yvallabel)(Idxi),'filled','DisplayName','Měření pomocí IEDevice');
            go(end+1)=plot3(ax1,TA.X,Tia,TA.Y,'-','Color',[0.5 0.5 0.5 0.5],'DisplayName','Počítaný obvod trouby');
        else
            scatter3(ax1,TFG2.X(Idxi),Tib(Idxi),TFG2.Y(Idxi),200,TFG2.(yvallabel)(Idxi),'filled','DisplayName','Měření pomocí IEDevice');
            plot3(ax1,TA.X,Tia,TA.Y,'-','Color',[0.5 0.5 0.5 0.5],'DisplayName','Počítaný obvod trouby');
        end
        xa=[xa; TFG2.X(Idxi)];
        ya=[ya; Tib(Idxi)];
        za=[za; TFG2.Y(Idxi)];
        fr=[fr; TFG2.(yvallabel)(Idxi)];
    
    
    
    end
    colormap(ax1,"jet");
    cbar=colorbar;
    cbar.Label.String=yvallabel;
    % set( cbar, 'YDir', 'reverse' );
    caxis(ax1,[min(TFG2.(yvallabel))*0.8,max(TFG2.(yvallabel))*1.2]);
    xlabel(ax1,'Šířka [m]');
    zlabel(ax1,'Výška [m]');
    ylabel(ax1,'Hloubka [m]');
    legend(ax1,go,'location','southoutside');
    view(ax1,60,45);
    
    
    ax2=axes(fig,'position',[0.15 0.85 0.2 .12]);
    hi=histogram(ax2,TFG2.(yvallabel));
    set(ax2,'Color','none','box','off');
    xlabel(ax2,yvallabel);
    ylabel(ax2,'Počet [-]');
    xt=hi.BinEdges(2:end)-hi.BinWidth/2;
    yt=hi.BinCounts;
    text(ax2,xt',yt'+0.07*max(yt),num2str(yt'),'HorizontalAlignment','Center',...
        'FontSize',8);
    % colormapeditor;
%     print(fig,[cd '\PrstenecTrouba_Slatina_3D.png'],'-r300','-dpng');
end