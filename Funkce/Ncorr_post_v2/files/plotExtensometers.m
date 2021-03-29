%% Script to plot data obtained  by virtual extensometers

% initialize the figure
f = figure('Units', 'pixels', 'Position', [50 150 1060 460]);

% handles to individual axes and their description
ax(1) = subplot(1,3,1);
ax(2) = subplot(1,3,2);
ax(3) = subplot(1,3,3);

% create a major title over all axes
titleName = sprintf('Data measured by the virtual extensometer no. %d', plottingData(1).actualExtensometer);
mtit(titleName,'fontsize',14,'FontWeight','bold');

%% plotting
deltas_X = zeros(plottingData(1).nFiles,1);
deltas_Y = zeros(plottingData(1).nFiles,1);
deltas_tot = zeros(plottingData(1).nFiles,1);

for i = 1:plottingData(1).nFiles
    deltas_X(i) = (plottingData(i).deltaX(plottingData(1).actualExtensometer))*1e3;
    deltas_Y(i) = (plottingData(i).deltaY(plottingData(1).actualExtensometer))*1e3;
    deltas_tot(i) = (plottingData(i).deltaTot(plottingData(1).actualExtensometer))*1e3;
end

plot(ax(1),1:plottingData(1).nFiles,deltas_X,'-b','LineWidth',2)
plot(ax(2),1:plottingData(1).nFiles,deltas_Y,'-b','LineWidth',2)
plot(ax(3),1:plottingData(1).nFiles,deltas_tot,'-r','LineWidth',2)

%% adjust fonts and graphics
set(gca,'FontName','Helvetica');

set(ax(1), ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'YGrid'       , 'on'      , ...
    'XGrid'       , 'on'      , ...
    'LineWidth'   , 1         );

set(ax(2), ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'YGrid'       , 'on'      , ...
    'XGrid'       , 'on'      , ...
    'LineWidth'   , 1         );

set(ax(3), ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'YGrid'       , 'on'      , ...
    'XGrid'       , 'on'      , ...
    'LineWidth'   , 1         );

%% titles of axes
title(ax(1),'x-direction')
title(ax(2),'y-direction')
title(ax(3),'total')

%% axes description
XLabel_1 = xlabel(ax(1),'image number [-]','Interpreter','LaTex','FontSize',12);
YLabel_1 = ylabel(ax(1),'extension [mm]','Interpreter','LaTex','FontSize',12);
XLabel_2 = xlabel(ax(2),'image number [-]','Interpreter','LaTex','FontSize',12);
YLabel_2 = ylabel(ax(2),'extension [mm]','Interpreter','LaTex','FontSize',12);
XLabel_3 = xlabel(ax(3),'image number [-]','Interpreter','LaTex','FontSize',12);
YLabel_3 = ylabel(ax(3),'extension [mm]','Interpreter','LaTex','FontSize',12);

%% adjust axes: sizes and position
origPosition1 = get(ax(1),'Position');
origPosition1(1) = origPosition1(1)-0.03; 
origPosition1(3) = 0.2;
origPosition1(4) = 0.75;
set(ax(1),'Position',origPosition1) 

origPosition2 = get(ax(2),'Position');
origPosition2(3) = 0.2;
origPosition2(4) = 0.75;
set(ax(2),'Position',origPosition2) 

origPosition3 = get(ax(3),'Position');
origPosition3(1) = origPosition3(1)+0.03; 
origPosition3(3) = 0.2;
origPosition3(4) = 0.75;
set(ax(3),'Position',origPosition3) 
