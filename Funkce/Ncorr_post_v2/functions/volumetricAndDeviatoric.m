function [volumetric, deviatoric] = volumetricAndDeviatoric(xx, yy, xy)

volumetric = 0.5*(xx+yy);
deviatoric = sqrt(2/3*((xx-volumetric).^2+(yy-volumetric).^2+(xy).^2+(xy).^2));


end

