function [f,y]=MyPower(y,freq,freq_width)
    arguments
        y (:,1) double;
        freq (1,1) double;
        freq_width (1,1) double = 4.5;
    end
    tuReal = "seconds";
    samples=numel(y);
    period=1/freq;
    time=linspace(0,samples*period,samples)';

    signal=y;
    Fs=freq;
    % Compute effective sampling rate.
    tNumeric = time2num(time,tuReal);
    [Fs,irregular] = effectivefs(tNumeric);
    Ts = 1/Fs;

    % Resample non-uniform signals.
    x = signal;
    if irregular
        x = resample(x,tNumeric,Fs,'linear');
    end

    % Set Welch spectrum parameters.
    L = fix(length(x)/freq_width);
    noverlap = fix(L*50/100);
    win = window(@hamming,L);

    % Compute the power spectrum.
    [ps,f] = pwelch(x,win,noverlap,[],Fs);
    w = 2*pi*f;

    % Convert frequency unit.
    factor = funitconv('rad/TimeUnit', 'Hz', 'seconds');
    w = factor*w;
    Fs = 2*pi*factor*Fs;

    % Remove frequencies above Nyquist frequency.
    I = w<=(Fs/2+1e4*eps);
    w = w(I);
    ps = ps(I);

    % Configure the computed spectrum.
    ps = table(w, ps, 'VariableNames', ["Frequency", "SpectrumData"]);
    ps.Properties.VariableUnits = ["Hz", ""];
    ps = addprop(ps, {'SampleFrequency'}, {'table'});
    ps.Properties.CustomProperties.SampleFrequency = Fs;
    f=ps.Frequency;
    y=ps.SpectrumData;
end