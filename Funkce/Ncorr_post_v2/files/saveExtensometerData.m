%% script to save data from virtual extensometers

exportFolderName = strcat('export/',plottingData(1).projectName,'/virtualExtensometer_',num2str(plottingData(1).actualExtensometer));
exportFileName_x = strcat(exportFolderName,'/',plottingData(1).projectName,'-virtExt_',num2str(plottingData(1).actualExtensometer),'_extension-x (meters).txt');
exportFileName_y = strcat(exportFolderName,'/',plottingData(1).projectName,'-virtExt_',num2str(plottingData(1).actualExtensometer),'_extension-y (meters).txt');
exportFileName_tot = strcat(exportFolderName,'/',plottingData(1).projectName,'-virtExt_',num2str(plottingData(1).actualExtensometer),'_extension-tot (meters).txt');
exportFileName_strain_x = strcat(exportFolderName,'/',plottingData(1).projectName,'-virtExt_',num2str(plottingData(1).actualExtensometer),'_strain-x.txt');
exportFileName_strain_y = strcat(exportFolderName,'/',plottingData(1).projectName,'-virtExt_',num2str(plottingData(1).actualExtensometer),'_strain-y.txt');
exportFileName_strain_tot = strcat(exportFolderName,'/',plottingData(1).projectName,'-virtExt_',num2str(plottingData(1).actualExtensometer),'_strain-total.txt');
exportFileName_P1_x = strcat(exportFolderName,'/',plottingData(1).projectName,'-virtExt_',num2str(plottingData(1).actualExtensometer),'_P1-xDispl (meters).txt');
exportFileName_P1_y = strcat(exportFolderName,'/',plottingData(1).projectName,'-virtExt_',num2str(plottingData(1).actualExtensometer),'_P1-yDispl (meters).txt');
exportFileName_P2_x = strcat(exportFolderName,'/',plottingData(1).projectName,'-virtExt_',num2str(plottingData(1).actualExtensometer),'_P2-xDispl (meters).txt');
exportFileName_P2_y = strcat(exportFolderName,'/',plottingData(1).projectName,'-virtExt_',num2str(plottingData(1).actualExtensometer),'_P2-yDispl (meters).txt');

if ~isequal(exist(char(strcat('export/',plottingData(1).projectName)), 'dir'),7) % check whether the destination folder exists
    mkdir(strcat(pwd,'/export'),char(plottingData(1).projectName))
end
if ~isequal(exist(char(exportFolderName), 'dir'),7) % check whether the destination folder exists
    mkdir(strcat(pwd,char(strcat('/export/',plottingData(1).projectName))),char(strcat('/virtualExtensometer_',num2str(plottingData(1).actualExtensometer))))
end

dlmwrite(char(exportFileName_x), plottingData(plottingData(1).actualExtensometer).deltas_X)
dlmwrite(char(exportFileName_y), plottingData(plottingData(1).actualExtensometer).deltas_Y)
dlmwrite(char(exportFileName_tot), plottingData(plottingData(1).actualExtensometer).deltas_tot)
dlmwrite(char(exportFileName_strain_x), plottingData(plottingData(1).actualExtensometer).strain_X)
dlmwrite(char(exportFileName_strain_y), plottingData(plottingData(1).actualExtensometer).strain_Y)
dlmwrite(char(exportFileName_strain_tot), plottingData(plottingData(1).actualExtensometer).strain_tot)
dlmwrite(char(exportFileName_P1_x), plottingData(plottingData(1).actualExtensometer).displacementsOfPoint_P1(:,1))
dlmwrite(char(exportFileName_P1_y), plottingData(plottingData(1).actualExtensometer).displacementsOfPoint_P1(:,2))
dlmwrite(char(exportFileName_P2_x), plottingData(plottingData(1).actualExtensometer).displacementsOfPoint_P2(:,1))
dlmwrite(char(exportFileName_P2_y), plottingData(plottingData(1).actualExtensometer).displacementsOfPoint_P2(:,2))

msgbox('All data saved successfuly');