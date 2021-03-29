plottingData(1).quantitiesToDisplay = {'strain xx';'strain yy';'strain xy';
    'x-displacement (pixels)'; 'y-displacement (pixels)';
    'x-displacement (meters)'; 'y-displacement (meters)'
    'max principal strain (tension)'; 'min principal strain (compression)';
    'hydrostatic strain'; 'deviatoric strain norm (J2-like)';
    'principal angle (tension)';
    'principal angle (compression)'}; 

plottingData(1).plotString = {'plottingData(plottingData(1).currentImage).strains_xx';
              'plottingData(plottingData(1).currentImage).strains_yy';
              'plottingData(plottingData(1).currentImage).strains_xy';
              'plottingData(plottingData(1).currentImage).displacements_x';
              'plottingData(plottingData(1).currentImage).displacements_y';
              'plottingData(plottingData(1).currentImage).displacements_x_scaled';
              'plottingData(plottingData(1).currentImage).displacements_y_scaled';
              'plottingData(plottingData(1).currentImage).principalStrain_max';
              'plottingData(plottingData(1).currentImage).principalStrain_min';
              'plottingData(plottingData(1).currentImage).hydrostaticStrain';
              'plottingData(plottingData(1).currentImage).deviatoricStrain';
              'plottingData(plottingData(1).currentImage).principalAngle_t';
              'plottingData(plottingData(1).currentImage).principalAngle_c'}; % append new quantities to the end only

plottingData(1).shortNotation = {'strain-xx'; 'strain-yy';'strain-xy';
              'displacements-x-pixels';'displacements-y-pixels';
              'displacements-x-meters';'displacements-y-meters';
              'principalStrain-max';'principalStrain-min';
              'hydrostaticStrain';'deviatoricStrain';
              'principalAngle-tension';'principalAngle-compression'}; % append new quantities to the end only