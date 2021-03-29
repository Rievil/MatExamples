% script to scale displacements with respect to a pixel size

% input
[input_filename_in, input_path_in] = uigetfile('*.*','MultiSelect', 'off',...
    'Choose a file with a scale',[currentFolder,'/scaleImages']);

% display the image and define the scale
newFigure = figure;
im = imread([input_path_in,input_filename_in]);
imshow(im)
axis image; axis off;
xlabel({'Choose 2 points defining a certain distance by right-button';...
      'clicking your mouse, while zooming in by left-button clicking.'})
[position_x position_y] = ginput2(2);

distanceTrue = inputdlg('Distance defined [mm]:');
close(newFigure)
distanceTrue = str2double(distanceTrue);
distancePix = sqrt((position_x(1)-position_x(2))^2+(position_y(1)-position_y(2))^2);
pxDistance = distanceTrue/distancePix*1e-3; % distance between two pixels [m]