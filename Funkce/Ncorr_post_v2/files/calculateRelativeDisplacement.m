% script to calculate a relative displacement of two points from the map of displacements

% find a position on the reduced colormap of displacements
selectedDisplacementPosition_1 = ceil([P1(2), P1(1)]/(plottingData(1).subsetSpacing+1));
selectedDisplacementPosition_2 = ceil([P2(2), P2(1)]/(plottingData(1).subsetSpacing+1));

temp_P1 = [];
temp_P2 = [];

% read the displacements at the selected locations and save them for all images
for i = 1:plottingData(1).nFiles
    
    avgValues_x1 = zeros(2*plottingData(1).avgRadius+1);
    avgValues_x2 = zeros(2*plottingData(1).avgRadius+1);
    avgValues_y1 = zeros(2*plottingData(1).avgRadius+1);
    avgValues_y2 = zeros(2*plottingData(1).avgRadius+1);
    
    a_counter = 0;
    for a = -plottingData(1).avgRadius:plottingData(1).avgRadius
        a_counter = a_counter+1;
        b_counter = 0;
        for b = -plottingData(1).avgRadius:plottingData(1).avgRadius
            b_counter = b_counter+1;
            avgValues_x1(a_counter,b_counter) = plottingData(i).displacements_x_scaled(max(1,selectedDisplacementPosition_1(1)+a),max(1,selectedDisplacementPosition_1(2)+b));
            avgValues_x2(a_counter,b_counter) = plottingData(i).displacements_x_scaled(max(1,selectedDisplacementPosition_2(1)+a),max(1,selectedDisplacementPosition_2(2)+b));
            avgValues_y1(a_counter,b_counter) = plottingData(i).displacements_y_scaled(max(1,selectedDisplacementPosition_1(1)+a),max(1,selectedDisplacementPosition_1(2)+b));
            avgValues_y2(a_counter,b_counter) = plottingData(i).displacements_y_scaled(max(1,selectedDisplacementPosition_2(1)+a),max(1,selectedDisplacementPosition_2(2)+b));
        end
    end
    
    x1 = mean(mean(avgValues_x1));
    x2 = mean(mean(avgValues_x2));
    y1 = mean(mean(avgValues_y1));
    y2 = mean(mean(avgValues_y2));
    
    temp_P1 = [temp_P1; x1, y1];
    temp_P2 = [temp_P2; x2, y2];
    
    plottingData(i).deltaX(plottingData(1).actualExtensometer) = x2-x1;
    plottingData(i).deltaY(plottingData(1).actualExtensometer) = y2-y1;
    
    deltaOriginal = plottingData(1).pxDistance*sqrt((P2(1)-P1(1))^2+(P2(2)-P1(2))^2);
    deltaAfterDeformation = sqrt((P2(1)*plottingData(1).pxDistance+x2-x1-P1(1)*plottingData(1).pxDistance)^2+(P2(2)*plottingData(1).pxDistance+y2-y1-P1(2)*plottingData(1).pxDistance)^2);
    plottingData(i).deltaTot(plottingData(1).actualExtensometer) = deltaAfterDeformation-deltaOriginal;
end

dX = (P2(1)-P1(1))*plottingData(1).pxDistance;
dY = (P2(2)-P1(2))*plottingData(1).pxDistance;
dTot = sqrt(dX^2+dY^2);
if dX < 0
    angle = 180+atand(dY/dX);
else
    angle = atand(dY/dX);
end
angle = round(angle*10)/10;

handles_textBox = findobj('Style','text','Tag','text36'); % find handle of static text
set(handles_textBox,'String', sprintf('%f mm',dX*1000)) % update the static text field

handles_textBox = findobj('Style','text','Tag','text38'); % find handle of static text
set(handles_textBox,'String', sprintf('%f mm',dY*1000)) % update the static text field

handles_textBox = findobj('Style','text','Tag','text40'); % find handle of static text
set(handles_textBox,'String', sprintf('%f mm',dTot*1000)) % update the static text field

handles_textBox = findobj('Style','text','Tag','text42'); % find handle of static text
set(handles_textBox,'String', sprintf('%.1f °',angle)) % update the static text field

set(handles.pushbutton27,'FontSize', 10.67)
set(handles.pushbutton27,'ForegroundColor', [0,0,0])
set(handles.pushbutton27,'Enable', 'off')

%% plot the figures 

deltas_X = zeros(plottingData(1).nFiles,1);
deltas_Y = zeros(plottingData(1).nFiles,1);
deltas_tot = zeros(plottingData(1).nFiles,1);

for i = 1:plottingData(1).nFiles
    deltas_X(i) = (plottingData(i).deltaX(plottingData(1).actualExtensometer));
    deltas_Y(i) = (plottingData(i).deltaY(plottingData(1).actualExtensometer));
    deltas_tot(i) = (plottingData(i).deltaTot(plottingData(1).actualExtensometer));
end

plottingData(plottingData(1).actualExtensometer).deltas_X = deltas_X;
plottingData(plottingData(1).actualExtensometer).deltas_Y = deltas_Y;
plottingData(plottingData(1).actualExtensometer).deltas_tot = deltas_tot;
plottingData(plottingData(1).actualExtensometer).strain_X = deltas_X/dX;
plottingData(plottingData(1).actualExtensometer).strain_Y = deltas_Y/dY;
plottingData(plottingData(1).actualExtensometer).strain_tot = deltas_tot/dTot;
plottingData(plottingData(1).actualExtensometer).displacementsOfPoint_P1 = temp_P1;
plottingData(plottingData(1).actualExtensometer).displacementsOfPoint_P2 = temp_P2;

%% plots 

% x-displacement
axes(handles.axes2);
plot(1:plottingData(1).nFiles,deltas_X*1000,'-','Color',[0,0,1],'LineWidth',2)
hold on
set(gca,...
    'XLim',[0, plottingData(1).nFiles],...
    'YLim',[min(deltas_X*1000), max(deltas_X*1000)],...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'YGrid'       , 'on'      , ...
    'XGrid'       , 'on'      );
yLimits = get(gca,'YLim');  % Get the range of the y axis
plot([plottingData(1).currentImage,plottingData(1).currentImage],[yLimits(1),yLimits(2)],'-k','LineWidth',2)
hold off

% y-displacement
axes(handles.axes3);
plot(1:plottingData(1).nFiles,deltas_Y*1000,'-','Color',[1,0.6,0],'LineWidth',2)
hold on
set(gca,...
    'XLim',[0, plottingData(1).nFiles],...
    'YLim',[min(deltas_Y*1000), max(deltas_Y*1000)],...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'YGrid'       , 'on'      , ...
    'XGrid'       , 'on'      );
yLimits = get(gca,'YLim');  % Get the range of the y axis
plot([plottingData(1).currentImage,plottingData(1).currentImage],[yLimits(1),yLimits(2)],'-k','LineWidth',2)
hold off

% total displacement
axes(handles.axes4);
plot(1:plottingData(1).nFiles,deltas_tot*1000,'-','Color',[1,0,0],'LineWidth',2)
hold on
set(gca,...
    'XLim',[0, plottingData(1).nFiles],...
    'YLim',[min(deltas_tot*1000), max(deltas_tot*1000)],...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'YGrid'       , 'on'      , ...
    'XGrid'       , 'on'      );
yLimits = get(gca,'YLim');  % Get the range of the y axis
plot([plottingData(1).currentImage,plottingData(1).currentImage],[yLimits(1),yLimits(2)],'-k','LineWidth',2)
hold off

% displacement of point 1
temp_P1(isnan(temp_P1)) = 0; % eliminate NaN entries
axes(handles.axes5);
plot(temp_P1(:,1)*1000,temp_P1(:,2)*1000,'-','Color',[0,0.8,0.4],'LineWidth',2)
hold on
xLimits = get(gca,'XLim');  % Get the range of the x axis
yLimits = get(gca,'YLim');  % Get the range of the y axis
plot([0,0],yLimits,'-k')
hold on
plot(xLimits,[0,0],'-k')
hold off
set(gca,...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'YGrid'       , 'on'      , ...
    'XGrid'       , 'on'      , ...
    'XGrid'       , 'on'      );
set(gca,'YDir','reverse');

% displacement of point 2
temp_P2(isnan(temp_P2)) = 0; % eliminate NaN entries
axes(handles.axes6);
plot(temp_P2(:,1)*1000,temp_P2(:,2)*1000,'-','Color',[0.8,0,0.4],'LineWidth',2)
hold on
xLimits = get(gca,'XLim');  % Get the range of the x axis
yLimits = get(gca,'YLim');  % Get the range of the y axis
plot([0,0],yLimits,'-k')
hold on
plot(xLimits,[0,0],'-k')
hold off
set(gca,...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'YGrid'       , 'on'      , ...
    'XGrid'       , 'on'      , ...
    'XGrid'       , 'on'      );
set(gca,'YDir','reverse');