%% script to load the data from Ncorr software
% it is needed to run the Ncorr DIC tool by calling it from the Command 
% Window using "handles_ncorr = ncorr"

plottingData(1).justInitialized = true;
plottingData(1).autoscaleBounds = false;
plottingData(1).showOutOfRoi = true;
plottingData(1).monitoringPoints = zeros(4,1);
plottingData(1).nVirtualExtensometers = 0;
plottingData(1).actualExtensometer = 0;
plottingData(1).plotExtensometers = false;
plottingData(1).plotArrows = false;
plottingData(1).zoomed = false;
plottingData(1).isScaled = false;

%% get the Ncorr output structure from the workspace
handles_ncorr = evalin('base','handles_ncorr');

%% obtain the project name and udate GUI
plottingData(1).projectName = inputdlg('Enter name of the project:', 'Project name');
handles_title = findobj('Style','text','Tag','text11'); % find handle of static text
set(handles_title,'String', plottingData(1).projectName) % update the static text field

%% original image processing

plottingData(1).originalImage = handles_ncorr.reference.image;
plottingData(1).roi = handles_ncorr.roi.mask;
outRoiColor = [1 1 1];
plottingData(1).roiOriginalImage = imoverlay(plottingData(1).originalImage,plottingData(1).roi,outRoiColor);
plottingData(1).outOfRoiImage = imoverlay_inverse(plottingData(1).originalImage,plottingData(1).roi,outRoiColor);

% get subset spacing
plottingData(1).subsetSpacing =  handles_ncorr.data_dic.dispinfo.spacing;

% get the size of the original image
plottingData(1).plot_x = 1:1:size(plottingData(1).roiOriginalImage,2); 
plottingData(1).plot_y = 1:1:size(plottingData(1).roiOriginalImage,1);

%% extract the calculated data fields from Ncorr

plottingData(1).nFiles = size(handles_ncorr.current,2);

for i = 1:plottingData(1).nFiles
    % name
    plottingData(i).names = handles_ncorr.current(i).name;
    
    % strains in components
    plottingData(i).strains_xx = handles_ncorr.data_dic.strains(i).plot_exxstrain_ref;
    plottingData(i).strains_yy = handles_ncorr.data_dic.strains(i).plot_eyystrain_ref;
    plottingData(i).strains_xy = handles_ncorr.data_dic.strains(i).plot_exystrain_ref;
    
    % displacements
    plottingData(i).displacements_x = handles_ncorr.data_dic.displacements(i).plot_udisp_ref_formated;
    plottingData(i).displacements_y = handles_ncorr.data_dic.displacements(i).plot_vdisp_ref_formated;
    
    % initiate arrays for scaled displacements
    plottingData(i).displacements_x_scaled = plottingData(i).displacements_x;
    plottingData(i).displacements_y_scaled = plottingData(i).displacements_y;
    
    % principal strains
    [plottingData(i).strain_xx_princ,...
       plottingData(i).strain_yy_princ,... 
       plottingData(i).principalAngle] = principalValues(plottingData(i).strains_xx,...
                                                   plottingData(i).strains_yy,...
                                                   plottingData(i).strains_xy);
                                               
    plottingData(i).principalStrain_max = max(plottingData(i).strain_xx_princ, plottingData(i).strain_yy_princ);
    plottingData(i).principalStrain_min = min(plottingData(i).strain_xx_princ, plottingData(i).strain_yy_princ);
    
end

plottingData(1).quantitiesToDisplay = {'strain xx';'strain yy';'strain xy';
    'x-displacement (pixels)'; 'y-displacement (pixels)';
    'x-displacement (meters)'; 'y-displacement (meters)'
    'max principal strain (tension)'; 'min principal strain (compression)'}; 

plottingData(1).plotString = {'plottingData(plottingData(1).currentImage).strains_xx';
              'plottingData(plottingData(1).currentImage).strains_yy';
              'plottingData(plottingData(1).currentImage).strains_xy';
              'plottingData(plottingData(1).currentImage).displacements_x';
              'plottingData(plottingData(1).currentImage).displacements_y';
              'plottingData(plottingData(1).currentImage).displacements_x_scaled';
              'plottingData(plottingData(1).currentImage).displacements_y_scaled';
              'plottingData(plottingData(1).currentImage).principalStrain_max';
              'plottingData(plottingData(1).currentImage).principalStrain_min'}; % append new quantities to the end only

plottingData(1).shortNotation = {'strain-xx'; 'strain-yy';'strain-xy';
              'displacements-x-pixels';'displacements-y-pixels';
              'displacements-x-meters';'displacements-y-meters';
              'principalStrain-max';'principalStrain-min'}; % append new quantities to the end only
          
          
plottingData(1).extensometerColor = {'black';'red';'blue';'white'};
plottingData(1).extensometerRGB = [0,0,0; 1,0,0; 0,0,1; 0.99,0.99,0.99];
plottingData(1).currentExtColor = 1;



