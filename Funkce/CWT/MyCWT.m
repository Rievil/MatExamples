function [WT,F,T]=MyCWT(sig,freq,voicesPerOctave,timeBandWidth)% Compute scalogram
    arguments
        sig (:,1) double;
        freq (1,1) double;
        voicesPerOctave (1,1) double {mustBePositive};
        timeBandWidth (1,1) double {mustBePositive};
    end
    % Generated by MATLAB(R) 9.11 and Signal Processing Toolbox 8.7.
    % Generated on: 31-Mar-2022 20:27:41
    
    % Parameters
    timeLimits = [0 numel(sig)*1/freq]; % seconds
    frequencyLimits = [0 freq/2]; % Hz
%     timeBandWidth = 87;
    % voicesPerOctave = 8;
    
    %
    % Index into signal time region of interest
    y1_ROI = sig;
    sampleRate = freq; % Hz
    startTime = 0; % seconds
    timeValues = startTime + (0:length(y1_ROI)-1).'/sampleRate;
    minIdx = timeValues >= timeLimits(1);
    maxIdx = timeValues <= timeLimits(2);
    y1_ROI = y1_ROI(minIdx&maxIdx);
    timeValues = timeValues(minIdx&maxIdx);
    T=timeValues;
    
    
    %
    % Limit the cwt frequency limits
    frequencyLimits(1) = max(frequencyLimits(1),...
        cwtfreqbounds(numel(y1_ROI),sampleRate,...
        'TimeBandWidth',timeBandWidth));
    
    % Compute cwt
    % Run the function call below without output arguments to plot the results
    [WT,F] = cwt(y1_ROI,sampleRate, ...
        'VoicesPerOctave',voicesPerOctave, ...
        'FrequencyLimits',frequencyLimits);
    WT=abs(WT);
end
