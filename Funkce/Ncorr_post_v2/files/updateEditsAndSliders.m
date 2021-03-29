%% update edits and sliders, apply limits and save the positions of extensometers

% apply limits to the positions
P1(1) = min([P1(1),plottingData(1).imgSize(2)]);
P1(2) = min([P1(2),plottingData(1).imgSize(1)]);
P2(1) = min([P2(1),plottingData(1).imgSize(2)]);
P2(2) = min([P2(2),plottingData(1).imgSize(1)]);


% save the position to handles
plottingData(plottingData(1).actualExtensometer).monitoringPoints = [P1(1),P2(1),P1(2),P2(2)];


% update edits and sliders
set(handles.edit6,'String', sprintf('%f', P1(1)*plottingData(1).pxDistance*1000))
set(handles.slider6, 'Value', P1(1)*plottingData(1).pxDistance*1000);

set(handles.edit7,'String', sprintf('%f', P1(2)*plottingData(1).pxDistance*1000))
set(handles.slider7, 'Value', P1(2)*plottingData(1).pxDistance*1000);

set(handles.edit8,'String', sprintf('%f', P2(1)*plottingData(1).pxDistance*1000))
set(handles.slider8, 'Value', P2(1)*plottingData(1).pxDistance*1000);

set(handles.edit9,'String', sprintf('%f', P2(2)*plottingData(1).pxDistance*1000))
set(handles.slider9, 'Value', P2(2)*plottingData(1).pxDistance*1000);