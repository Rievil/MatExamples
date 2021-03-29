%% Correct displacements influenced by the rotations
% it is considered that the specimen surface is located in xy-plane and 
% z-plane is perpendicular

newProjectName = 'HPC-4_aligned_2';

correct_z_rotation = false;
correct_y_rotation = false;
correct_strains = true;

correct_x_rotation = false;

% --- CALCULATIONS BEGIN HERE --- %
handles_mainGui = getappdata(0,'handles_mainGui');
plottingData = getappdata(handles_mainGui, 'plottingData');

plottingData(1).projectName = newProjectName;

heightOfSpec = size(plottingData(1).displacements_x_scaled,1);
widthOfSpec = size(plottingData(1).displacements_x_scaled,2);

if correct_z_rotation
    waitfor(msgbox('Choose a point on the left first, the second one must be on the right from the first one.'))
    newFigure = figure;
    imshow(plottingData(1).originalImage)
    axis image; %axis off;
    xlabel({'Choose 2 points defining a certain distance by right-button';...
        'clicking your mouse, while zooming in by left-button clicking.'})
    [position_x position_y] = ginput2(2);
    close(newFigure)
    P1 = [position_x(1), position_y(1)];
    P2 = [position_x(2), position_y(2)];

    % find a position on the reduced colormap of displacements
    selectedDisplacementPosition_1 = ceil([P1(2), P1(1)]/(plottingData(1).subsetSpacing+1));
    selectedDisplacementPosition_2 = ceil([P2(2), P2(1)]/(plottingData(1).subsetSpacing+1));
    
    xDistance = abs(selectedDisplacementPosition_2(2)-selectedDisplacementPosition_1(2));
end

for i = 1:plottingData(1).nFiles
    
    nonClearedDisplacements = plottingData(i).displacements_x_scaled(round(heightOfSpec/2),:);
    startOfSpecimen = find(nonClearedDisplacements~=0, 1,'first');
    endOfSpecimen = find(nonClearedDisplacements~=0, 1,'last');
    lengthOfSpecimen = endOfSpecimen-startOfSpecimen+1;
    
    nonClearedDisplacementsVertical = plottingData(i).displacements_y_scaled(:,round(widthOfSpec/2));
    startOfSpecimenVertical = find(nonClearedDisplacementsVertical~=0, 1,'first');
    endOfSpecimenVertical = find(nonClearedDisplacementsVertical~=0, 1,'last');
    lengthOfSpecimenVertical = endOfSpecimenVertical-startOfSpecimenVertical+1;
    halfHeightOfSpecimen = round((startOfSpecimenVertical+endOfSpecimenVertical)/2);

    %% correct fake displacements due to rotation around z-axis (in plane rotation) - expected two points to move together at the same y-level
    
    if correct_z_rotation
        avgValues_y1 = zeros(2*plottingData(1).avgRadius+1);
        avgValues_y2 = zeros(2*plottingData(1).avgRadius+1);
        
        a_counter = 0;
        for a = -plottingData(1).avgRadius:plottingData(1).avgRadius
            a_counter = a_counter+1;
            b_counter = 0;
            for b = -plottingData(1).avgRadius:plottingData(1).avgRadius
                b_counter = b_counter+1;
                avgValues_y1(a_counter,b_counter) = plottingData(i).displacements_y_scaled(max(1,selectedDisplacementPosition_1(1)+a),max(1,selectedDisplacementPosition_1(2)+b));
                avgValues_y2(a_counter,b_counter) = plottingData(i).displacements_y_scaled(max(1,selectedDisplacementPosition_2(1)+a),max(1,selectedDisplacementPosition_2(2)+b));
            end
        end
        y1 = mean(mean(avgValues_y1));
        y2 = mean(mean(avgValues_y2));
        
        if i == 200;
            justStop = 'just to stop for debugging';
        end
        
        rM = (y2-y1)/xDistance; % rotation multiplier (from similarity of triangles
        
        % correct both, x- and y-displacement of each point
        for k = startOfSpecimen:endOfSpecimen
            dist_x = k-endOfSpecimen;
            plottingData(i).displacements_y_scaled(:,k) = plottingData(i).displacements_y_scaled(:,k)-dist_x*rM;
        end
    end
    
    %% correct fake displacements due to rotation around y-axis - expected zero x-displacement at the specimen center
    
    if correct_y_rotation
        for k = startOfSpecimen:endOfSpecimen
            plottingData(i).displacements_x_scaled(:,k) =...
                plottingData(i).displacements_x_scaled(:,k)-plottingData(i).displacements_x_scaled(halfHeightOfSpecimen,k); % recalculate displacements
        end
    end
    
    %% correct fake displacements due to rotation around x-axis (expected zero displacement at one end of the specimen
    
    if correct_x_rotation
        for l = startOfSpecimenVertical:endOfSpecimenVertical
            plottingData(i).displacements_y_scaled(l,:) =...
                plottingData(i).displacements_y_scaled(l,:)-plottingData(i).displacements_y_scaled(l,endOfSpecimenVertical); % recalculate displacements
        end
    end
    
    %% correct strains with respect to zero-strain areas
    
    if correct_strains
        fakeStrainXX = plottingData(i).strains_xx(startOfSpecimen+5:startOfSpecimen+25,endOfSpecimenVertical-25:endOfSpecimenVertical-5);
        fakeStrainXX = mean(mean(fakeStrainXX));
        fakeStrainYY = plottingData(i).strains_yy(startOfSpecimen+5:startOfSpecimen+25,endOfSpecimenVertical-25:endOfSpecimenVertical-5);
        fakeStrainYY = mean(mean(fakeStrainYY));
        fakeStrainXY = plottingData(i).strains_xy(startOfSpecimen+5:startOfSpecimen+25,endOfSpecimenVertical-25:endOfSpecimenVertical-5);
        fakeStrainXY = mean(mean(fakeStrainXY));
        
        for k = startOfSpecimen:endOfSpecimen
            for l = startOfSpecimenVertical:endOfSpecimenVertical
                plottingData(i).strains_xx(l,k) = plottingData(i).strains_xx(l,k)-fakeStrainXX;
                plottingData(i).strains_yy(l,k) = plottingData(i).strains_yy(l,k)-fakeStrainYY;
                plottingData(i).strains_xy(l,k) = plottingData(i).strains_xy(l,k)-fakeStrainXY;
            end
        end
    end
end

run calculateOtherQuantities

setappdata(handles_mainGui, 'plottingData', plottingData);