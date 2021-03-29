function [threshold_RGB] = Perform_RGB_threshold(image_RGB, thrper)
% Code for Perform_RGB_threshold() goes below here.
% Extract the individual red, green, and blue color channels.
% (Note: rgbImage might be after you've taken the log of it.)
redChannel = image_RGB(:, :, 1);
greenChannel = image_RGB(:, :, 2);
blueChannel = image_RGB(:, :, 3);
maxGrayLevelR = max(redChannel(:));
minGrayLevelR=min(redChannel(:));
% Convert percentage threshold into an actual number.
thresholdLevel = minGrayLevelR + thrper*(maxGrayLevelR  - minGrayLevelR);
binaryImageR = redChannel  > thresholdLevel;
end