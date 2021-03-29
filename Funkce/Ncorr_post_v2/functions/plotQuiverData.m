function plotQuiverData(displayFactor,gridSize,xx_princ,yy_princ,anglePrinc,...
    imageSize,maxArrowLength,lengthOfTip,originOffset)

% plotQuiverData(displayFactor,gridSize,xx_princ,yy_princ,anglePrinc,...
%    imageSize,maxArrowLength,lengthOfTip,originOffset)
%     
%  A function to plot the vector field of principal values, by Vaclav 2014
%  
%  Inputs: 
%  displayFactor - upscaling of the principal values to the size of arrows
%  gridSize - describes the grid density = how many entries vertically / 
%             horizontally (the smaller value) to display
%  xx_princ, yy_princ, anglePrinc - decribes the magnitude and orientation
%                                   of the principal values to display
%  imageSize - size of the background image
%  maxArrowLength - length of the biggest arrow to plot
%  lengthOfTip - relative size of the arrow head (portion of arrow length)
%  originOffset - offset of the plotted data (if placed in origin then 
%                 originOffset = [0,0]
    
angleOfTip = 30; % angle between the main arrow line and head lines
lineThickness = 1.1; % thickness of all arrow lines

% get image information
currentAxes = gca;
x_size = size(xx_princ,2);
y_size = size(xx_princ,1);

% initiate the progress bar
hold on
progressbar(0);
nSteps = ceil(y_size/gridSize);
step = 0;

% draw arrows step-by-step
for i = 1:gridSize:y_size
    step = step+1;
    for j = 1:gridSize:x_size    
        if xx_princ(i,j) ~= 0 || yy_princ(i,j) ~= 0 % avoid those out of ROI
            
            % center of arrows
            pointCoords = originOffset+[imageSize(2)/x_size*j, imageSize(1)/y_size*i];
            
            % generate arrow lines and rotate them
            Pxx = [xx_princ(i,j)*displayFactor;0];
            Pyy = [0;yy_princ(i,j)*displayFactor];
            
            T = [cos(anglePrinc(i,j)),sin(anglePrinc(i,j));
                -sin(anglePrinc(i,j)),cos(anglePrinc(i,j))];
            
            Pxx_r = T*Pxx;
            Pyy_r = T*Pyy;
            
            % generate arrow heads and rotate them
            ctg = cot(angleOfTip/180*pi);
            tg = tan(angleOfTip/180*pi);
            headLength = maxArrowLength*lengthOfTip*displayFactor;
            
            Axx_1 = [-ctg*headLength;tg*headLength];
            Axx_2 = [-ctg*headLength;-tg*headLength];
            Ayy_1 = [-tg*headLength;-ctg*headLength];
            Ayy_2 = [tg*headLength;-ctg*headLength];
            
            Axx_1_r = T*Axx_1;
            Axx_2_r = T*Axx_2;
            Ayy_1_r = T*Ayy_1;
            Ayy_2_r = T*Ayy_2;
            
            if xx_princ(i,j) > 0
                plot(currentAxes, [pointCoords(1),pointCoords(1)+Pxx_r(1)],[pointCoords(2),pointCoords(2)+Pxx_r(2)],'color',[1 0 0],'lineWidth',lineThickness);
                plot(currentAxes, [pointCoords(1),pointCoords(1)-Pxx_r(1)],[pointCoords(2),pointCoords(2)-Pxx_r(2)],'color',[1 0 0],'lineWidth',lineThickness);
                plot(currentAxes, [pointCoords(1)+Pxx_r(1)+Axx_1_r(1),pointCoords(1)+Pxx_r(1)],[pointCoords(2)+Pxx_r(2)+Axx_1_r(2),pointCoords(2)+Pxx_r(2)],'color',[1 0 0],'lineWidth',lineThickness);
                plot(currentAxes, [pointCoords(1)-Pxx_r(1)-Axx_1_r(1),pointCoords(1)-Pxx_r(1)],[pointCoords(2)-Pxx_r(2)-Axx_1_r(2),pointCoords(2)-Pxx_r(2)],'color',[1 0 0],'lineWidth',lineThickness);
                plot(currentAxes, [pointCoords(1)+Pxx_r(1)+Axx_2_r(1),pointCoords(1)+Pxx_r(1)],[pointCoords(2)+Pxx_r(2)+Axx_2_r(2),pointCoords(2)+Pxx_r(2)],'color',[1 0 0],'lineWidth',lineThickness);
                plot(currentAxes, [pointCoords(1)-Pxx_r(1)-Axx_2_r(1),pointCoords(1)-Pxx_r(1)],[pointCoords(2)-Pxx_r(2)-Axx_2_r(2),pointCoords(2)-Pxx_r(2)],'color',[1 0 0],'lineWidth',lineThickness);
            else
                plot(currentAxes, [pointCoords(1)+Pxx_r(1),pointCoords(1)],[pointCoords(2)+Pxx_r(2),pointCoords(2)],'color',[0 0 1],'lineWidth',lineThickness);
                plot(currentAxes, [pointCoords(1)-Pxx_r(1),pointCoords(1)],[pointCoords(2)-Pxx_r(2),pointCoords(2)],'color',[0 0 1],'lineWidth',lineThickness);
                plot(currentAxes, [pointCoords(1)-Axx_1_r(1),pointCoords(1)],[pointCoords(2)-Axx_1_r(2),pointCoords(2)],'color',[0 0 1],'lineWidth',lineThickness);
                plot(currentAxes, [pointCoords(1)+Axx_1_r(1),pointCoords(1)],[pointCoords(2)+Axx_1_r(2),pointCoords(2)],'color',[0 0 1],'lineWidth',lineThickness);
                plot(currentAxes, [pointCoords(1)-Axx_2_r(1),pointCoords(1)],[pointCoords(2)-Axx_2_r(2),pointCoords(2)],'color',[0 0 1],'lineWidth',lineThickness);
                plot(currentAxes, [pointCoords(1)+Axx_2_r(1),pointCoords(1)],[pointCoords(2)+Axx_2_r(2),pointCoords(2)],'color',[0 0 1],'lineWidth',lineThickness);
            end
            
            if yy_princ(i,j) > 0
                plot(currentAxes, [pointCoords(1),pointCoords(1)+Pyy_r(1)],[pointCoords(2),pointCoords(2)+Pyy_r(2)],'color',[1 0 0],'lineWidth',lineThickness);
                plot(currentAxes, [pointCoords(1),pointCoords(1)-Pyy_r(1)],[pointCoords(2),pointCoords(2)-Pyy_r(2)],'color',[1 0 0],'lineWidth',lineThickness);
                plot(currentAxes, [pointCoords(1)+Pyy_r(1)+Ayy_1_r(1),pointCoords(1)+Pyy_r(1)],[pointCoords(2)+Pyy_r(2)+Ayy_1_r(2),pointCoords(2)+Pyy_r(2)],'color',[1 0 0],'lineWidth',lineThickness);
                plot(currentAxes, [pointCoords(1)-Pyy_r(1)-Ayy_1_r(1),pointCoords(1)-Pyy_r(1)],[pointCoords(2)-Pyy_r(2)-Ayy_1_r(2),pointCoords(2)-Pyy_r(2)],'color',[1 0 0],'lineWidth',lineThickness);
                plot(currentAxes, [pointCoords(1)+Pyy_r(1)+Ayy_2_r(1),pointCoords(1)+Pyy_r(1)],[pointCoords(2)+Pyy_r(2)+Ayy_2_r(2),pointCoords(2)+Pyy_r(2)],'color',[1 0 0],'lineWidth',lineThickness);
                plot(currentAxes, [pointCoords(1)-Pyy_r(1)-Ayy_2_r(1),pointCoords(1)-Pyy_r(1)],[pointCoords(2)-Pyy_r(2)-Ayy_2_r(2),pointCoords(2)-Pyy_r(2)],'color',[1 0 0],'lineWidth',lineThickness);
            else
                plot(currentAxes, [pointCoords(1)+Pyy_r(1),pointCoords(1)],[pointCoords(2)+Pyy_r(2),pointCoords(2)],'color',[0 0 1],'lineWidth',lineThickness);
                plot(currentAxes, [pointCoords(1)-Pyy_r(1),pointCoords(1)],[pointCoords(2)-Pyy_r(2),pointCoords(2)],'color',[0 0 1],'lineWidth',lineThickness);
                plot(currentAxes, [pointCoords(1)-Ayy_1_r(1),pointCoords(1)],[pointCoords(2)-Ayy_1_r(2),pointCoords(2)],'color',[0 0 1],'lineWidth',lineThickness);
                plot(currentAxes, [pointCoords(1)+Ayy_1_r(1),pointCoords(1)],[pointCoords(2)+Ayy_1_r(2),pointCoords(2)],'color',[0 0 1],'lineWidth',lineThickness);
                plot(currentAxes, [pointCoords(1)-Ayy_2_r(1),pointCoords(1)],[pointCoords(2)-Ayy_2_r(2),pointCoords(2)],'color',[0 0 1],'lineWidth',lineThickness);
                plot(currentAxes, [pointCoords(1)+Ayy_2_r(1),pointCoords(1)],[pointCoords(2)+Ayy_2_r(2),pointCoords(2)],'color',[0 0 1],'lineWidth',lineThickness);
            end
        end
    end
    progressbar(step/nSteps);
end

end