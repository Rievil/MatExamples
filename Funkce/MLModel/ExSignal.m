classdef ExSignal < handle
    properties
        Signal;
        SamplingFreq;
        Period;
        NSamples;
        FNSamples;
        Spectrum;
        Features;
    end

    properties (Dependent)
        Time;
        Frequency;
    end

    properties (SetAccess=private)
        SignalAtt=false;
        Scale='lin';
        NoiseMultiplier=5;
        FFTSource='full';
        PartSignal;
        HasSignal=true;
        HasSpectrum=false;
        FreqWindow;
        HasFreqWindow=false;
        SignalFeatures struct;
        SpectrumFeatures struct;
        FreqPeaks=1;
        Option struct;
<<<<<<< HEAD
        SigAx;
        SpecAx;
        Fig;
    end

    properties (Hidden)
        FigSet=false;
        PlotSignals=true;
        PlotSpectrum=false;
        SigAxSet=false;
        SpecAxSet=false;
        SetAnnotate=false;
=======
        AttSuccess=false;
>>>>>>> 97a34d14597af3e6a0f9d6c622217e6b162e2c8b
    end

    methods
        function obj=ExSignal(signal,freq,varargin)
            
            obj.Signal=signal;
            obj.SamplingFreq=freq;
            obj.Period=1/freq;
            obj.NSamples=numel(obj.Signal);


            while numel(varargin)>0
                switch lower(varargin{1})
                    case 'scale'
                        obj.SetScale(char(varargin{2}));
                    case 'noise'
                        if varargin{2}>0 && varargin{2}<100
                            obj.NoiseMultiplier=varargin{2};
                        end
                    case 'fftsource'
                        obj.SetFFTSource(varargin{2});
                    case 'signal'
                        obj.HasSignal=varargin{2};
                    case 'spectrum'
                        obj.SetSpectrum(varargin{2})
                        obj.HasSpectrum=true;
                    case 'signalnorm'
                        if varargin{2}==true
                            obj.Signal=ExSignal.NormalizeSignal(obj.Signal);
                        else
                        end
                    case 'freqwindow'
                        obj.FreqWindow=varargin{2};
                        obj.HasFreqWindow=true;
                    case 'freqpeaks'
                        if varargin{2}>0 && varargin{2}<50
                            obj.FreqPeaks=varargin{2};
                        end
                    case 'ignore'
                    case 'signalatt'
                        if varargin{2}==true
                            obj.SignalAtt=true;
                        else
                            obj.SignalAtt=false;
                        end
                end
                varargin(1:2)=[];
            end
            
            if obj.HasSignal
                SignalExtraction(obj);
                
                switch obj.FFTSource
                    case 'full'
                        GetFFT(obj,obj.Signal);
                    case 'part'
                        GetFFT(obj,obj.PartSignal);
                end
            end

            if obj.HasSpectrum
                SpectrumExtraction(obj);
            end

            ReturnFeatures(obj);
        end

        function time=get.Time(obj)
            time=linspace(0,obj.Period*numel(obj.Signal),numel(obj.Signal))';
        end

        function freq=get.Frequency(obj)
            freq=zeros(obj.FNSamples,1);
            freq(:,1)=linspace(0,obj.SamplingFreq/2,obj.FNSamples)';
        end

        function plot(obj,varargin)
            
            while numel(varargin)>0
                switch lower(varargin{1})
                    case 'plotsignal'
                        switch varargin{2}
                            case true
                                obj.PlotSignals=varargin{2};
                            case false
                                obj.PlotSignals=varargin{2};
                        end
                    case 'plotspectrum'
                        switch varargin{2}
                            case true
                                obj.PlotSpectrum=varargin{2};
                            case false
                                obj.PlotSpectrum=varargin{2};
                        end
                    case 'figure'
                        obj.Fig=varargin{2};
                        obj.FigSet=true;
                        clrf(obj.Fig);
                    case 'signalax'
                        obj.SigAx=varargin{2};
                        obj.SigAxSet=true;
                        obj.PlotSignals=true;
                        cla(obj.SigAx);
                    case 'spectrumax'
                        obj.SpecAx=varargin{2};
                        obj.PlotSpectrum=true;
                        obj.SpecAxSet=true;
                        cla(obj.SpecAx);
                    case 'annotate'
%                         obj.SetAnnotate=true;
                        switch varargin{2}
                            case true
                                obj.SetAnnotate=varargin{2};
                            case false
                                obj.SetAnnotate=varargin{2};
                        end
                end
                varargin(1:2)=[];
            end
            
            if ~obj.FigSet
                if obj.SigAxSet || obj.SpecAxSet
                    if obj.SigAxSet
                        obj.Fig=obj.SigAx.Parent;
                    else
                        obj.Fig=obj.SpecAx.Parent;
                    end
                else
                    obj.Fig=figure;
                end
            end
            

            if obj.HasSignal==true
                if obj.PlotSignals && obj.PlotSpectrum
                    if ~obj.SigAxSet
                        obj.SigAx=subplot(1,2,1);
                    end
                    hold(obj.SigAx,'on');
                    
                    
                    if ~obj.SpecAxSet
                        obj.SpecAx=subplot(1,2,2);
                    end
                    hold(obj.SpecAx,'on');
                    
                    PlotSignalFeatures(obj,obj.SigAx);
                    PlotSpectrumFeatures(obj,obj.SpecAx);
                else
                    if obj.PlotSignals
                        if ~obj.SigAxSet
                            obj.SigAx=axis(obj.Fig);
                        end
                        hold(obj.SigAx,'on');
                        PlotSignalFeatures(obj,obj.SigAx);
                    end
                    
                    if obj.PlotSpectrum
                        if ~obj.SpecAxSet
                            obj.SpecAx=subplot(1,2,2);
                        end
                        hold(obj.SpecAx,'on');
                        PlotSpectrumFeatures(obj,obj.SpecAx);
                    end
                end

            else
<<<<<<< Updated upstream
                if obj.PlotSpectrum
                    if ~obj.SpecAxSet
                        obj.SpecAx=subplot(1,2,2);
                    end
                    hold(obj.SpecAx,'on');
                    PlotSpectrumFeatures(obj,obj.SpecAx);
                end
=======
                hold on;
                ax=gca;
                PlotSpectrumFeatures(obj,ax);
>>>>>>> Stashed changes
            end
        end

    end


    methods (Access=private)

        function PlotSignalFeatures(obj,ax)
            time=obj.Time;
            
            pidx=obj.Option.PartSignalIDX{1}:1:obj.Option.PartSignalIDX{2};
            plot(ax,time,obj.Signal,'DisplayName','Signal');

            plot(ax,time(pidx),obj.Signal(pidx),'-','LineWidth',1.1,'DisplayName','Signal above treashold');
            plot(ax,[time(1) time(end)],[obj.SignalFeatures.Trsh, obj.SignalFeatures.Trsh],...
                '-','Color',[.6 .6 .6],'DisplayName',sprintf("Treashold %0.0f%% of noise",obj.NoiseMultiplier*100));
            
            plot(ax,obj.Option.XRise,obj.Option.YRise,'--r','DisplayName','RiseTime');
            plot(ax,obj.Option.XDown,obj.Option.YDown,'--r','HandleVisibility','off');
            scatter(ax,obj.Option.Peaks.Time,obj.Option.Peaks.Amp,'^k','filled','DisplayName','AE Hits');
            
            if obj.SignalAtt
                newx=linspace(min(obj.Option.Peaks.Time),max(obj.Option.Peaks.Time),10)';
                newy=obj.Option.Atten.Fitobj(newx);
                plot(ax,newx,newy,'-r');
                
            end
            
            if obj.SetAnnotate
                lgd=legend('location','southeast','FontSize',8);
                lgd.EdgeColor='none';
            end

        end

        function PlotSpectrumFeatures(obj,ax)
            tf=table(obj.Frequency,obj.Spectrum,'VariableNames',{'f','y'});
%             y=obj.Spectrum;

            xlimval=[min(tf.f),max(tf.f)];
            if obj.HasFreqWindow
                tf=tf(tf.f>=obj.FreqWindow(1) & tf.f<=obj.FreqWindow(2),:);
                xlimval=obj.FreqWindow;
            end
            plot(ax,tf.f,tf.y);

            scatter(ax,obj.Option.FreqPeaks.Freq(1),obj.Option.FreqPeaks.Amp(1),'or','filled');


            if size(obj.Option.FreqPeaks,1)<obj.FreqPeaks
                peaksnum=size(obj.Option.FreqPeaks,1);
            else
                peaksnum=obj.FreqPeaks;
            end

            scatter(ax,obj.Option.FreqPeaks.Freq(2:peaksnum),obj.Option.FreqPeaks.Amp(2:peaksnum),'^k','filled');

            for i=1:peaksnum
                x=[obj.Option.FreqPeaks.Freq(i),obj.Option.FreqPeaks.Freq(i)];
                y=[obj.Option.FreqPeaks.Amp(i)-obj.Option.FreqPeaks.Prom(i),obj.Option.FreqPeaks.Amp(i)];

                plot(x,y,'-k');
            end
            xlim(ax,xlimval);
        end

        function ReturnFeatures(obj)
            TS=table;
            if obj.HasSignal
                TS=struct2table(obj.SignalFeatures,'AsArray',true);
            end
            TF=table;
            if obj.HasSpectrum
                TF=struct2table(obj.SpectrumFeatures,'AsArray',true);
            end
            obj.Features=[TS, TF];
        end

        function SignalExtraction(obj)
            out=struct;

            time=obj.Time;
            
            height=mean(obj.Signal(int32(obj.NSamples*0.5):1:end))+...
                std(obj.Signal(int32(obj.NSamples*0.5):1:end))*obj.NoiseMultiplier;
            
            pulseSNR = snr(time,obj.Signal);
        
            [pks,locs]=findpeaks(obj.Signal,time,'MinPeakHeight',height,...
                'MinPeakDistance',((time(end)-time(1))*0.001));
            TS=table(pks,locs,'VariableNames',{'Amp','Time'});
            maxampidx=find(pks==max(pks),1);
            if obj.SignalAtt
                TS2=TS(TS.Time>=locs(maxampidx),:);

                obj.Option(1).Atten=ExSignal.SigAttenuation(TS2{:,2},TS2{:,1});
                if obj.Option(1).Atten.AttSuccess
                    out.SignalAttAlpha=log(obj.Option.Atten.Fitobj.a);
%                     out.SignalAttBeta=log(obj.Option.Atten.Fitobj.b);
                else
                    out.SignalAttAlpha=NaN;
%                     out.SignalAttBeta=NaN;
                end
            end

            obj.Option(1).Peaks=TS;
            

            
            Trsh=height;
            
            iup=0;
            idown=0;
        
            iup=find(obj.Signal>Trsh,1,'first');
            
            idown=find(obj.Signal>Trsh,1,'last');
            
            if iup>0
            else
                iup=1;
            end
        
            if idown>0
            else
                idown=numel(obj.Signal);
            end

            obj.PartSignal=obj.Signal(iup:1:idown,1);
            
            CrestFactor=peak2rms(obj.PartSignal);
            TotalHarmonicDistortion= thd(obj.Signal);
            obj.Option(1).PartSignalIDX={iup,idown};
            obj.Option(1).SignalMaxAmpIdx=maxampidx;

            Dur=time(idown)-time(iup);
            
            RMS=rms(obj.PartSignal);
            Energy=Dur/sum(abs(obj.PartSignal));
            k = kurtosis(obj.PartSignal);
            skew = skewness(obj.PartSignal,0);
        
            maxpks=pks==max(pks);
            xrise=linspace(time(iup),mean(locs(maxpks)),2)';
            yrise=linspace(obj.Signal(iup),mean(pks(maxpks)),2)';
            
            obj.Option(1).XRise=xrise;
            obj.Option(1).YRise=yrise;

            obj.Option(1).XDown=linspace(mean(locs(maxpks)),time(idown),2)';
            obj.Option(1).YDown=linspace(mean(pks(maxpks)),obj.Signal(idown),2)';


            asmup=(obj.Signal(iup)-obj.Signal(maxampidx))/(time(iup)-time(maxampidx));
            asmdown=(obj.Signal(maxampidx)-obj.Signal(idown))/(time(maxampidx)-time(idown));
            
            if isempty(asmup)
                asmup=NaN;
            end
            
            if isempty(asmdown)
                asmdown=NaN;
            end
            
            out.NHits=numel(pks);
            out.Trsh=Trsh;
            out.SNR=pulseSNR;
            out.Duration=Dur;
            out.CrestFactor=CrestFactor;
            out.TotalHarmonicDistortion=TotalHarmonicDistortion;
            out.Kurt=k;
            out.Skew=skew;
            out.RMS=RMS;
            out.AsmpUp=asmup;
            out.MaxAmp=max(obj.Signal);
            out.AsmpDown=asmdown;
            out.RiseTime=diff(xrise);
            out.RiseEnergy=diff(yrise);
            out.Energy=Energy;
            out.AvgFreq=out.NHits/out.Duration;
            out.Raval=out.MaxAmp/out.RiseTime;
            obj.SignalFeatures=out;
        end

        function SpectrumExtraction(obj)
            out=struct;
            fr=obj.Frequency;
            ftrsh=max(obj.Spectrum(fr>100))*0.1;
            

            [fpks,flocs,w,p]=findpeaks(obj.Spectrum(fr>100),fr(fr>100),'MinPeakHeight',ftrsh,'MinPeakDistance',(obj.SamplingFreq/2*0.001),'NPeaks',20);
            
            Tf=table(fpks,flocs,w,p,'VariableNames',{'Amp','Freq','Width','Prom'});
            Tf=Tf(Tf.Prom>max(Tf.Prom)*0.1,:);

            if size(Tf,1)<obj.FreqPeaks
                warning(sprintf("Property 'FreqPeaks' was set to %d, but only %d meanigful peaks were extracted",obj.FreqPeaks,size(Tf,1)));
            end
                
            Tf=sortrows(Tf,'Amp','Descend');
            obj.Option(1).FreqPeaks=Tf;
            
            Tff=sortrows(Tf,'Freq','Ascend');
            Tff=Tff(Tff.Freq>=Tf.Freq(1),:);
            if obj.FreqPeaks==1
                out.Freq=Tf.Freq(1);
                out.FreqAmp=Tf.Amp(1);
                out.FreqWidth=Tf.Width(1);
            else
                for i=1:obj.FreqPeaks
                    if i<=size(Tf,1)
                        out.(sprintf("Freq%d",i))=Tf.Freq(i);
                        out.(sprintf("FreqAmp%d",i))=Tf.Amp(i);
                        out.(sprintf("FreqWidth%d",i))=Tf.Width(i);


                    else
                        out.(sprintf("Freq%d",i))=NaN;
                        out.(sprintf("FreqAmp%d",i))=NaN;
                        out.(sprintf("FreqWidth%d",i))=NaN;
                    end
                    
                    out.HarmRat=0;
                    
                    if i<=size(Tff,1)
                        if i>1
                            out.HarmRat=out.HarmRat+Tff.Amp(i-1)/Tff.Amp(i);
                        end
                    end
                    
                end
            end

            out.FreqPeaks=size(Tf,1);
            out.FreqSumAmp=sum(Tf.Amp);
            out.FreqMean=sum(Tf.Freq.*Tf.Amp)/sum(Tf.Amp);
            obj.SpectrumFeatures=out;
        end

        function SetSpectrum(obj,val)
            obj.HasSignal=false;
            obj.HasSpectrum=true;
            sz=size(val);
            if sz(1)>sz(2) 
                obj.Spectrum=val;
            else
                obj.Spectrum=val';
            end
            obj.FNSamples=numel(obj.Spectrum);
        end

        function SetScale(obj,val)

            switch val
                case 'lin'
                    obj.Scale=val;
                case 'log'
                    obj.Scale=val;
                otherwise
                    error("Possibe scales are 'lin' or 'log'");
            end
        end
        
        function SetFFTSource(obj,val)
            switch lower(val)
                case 'full'
                    obj.FFTSource=val;
                case 'part'
                    obj.FFTSource=val;
                otherwise
                    error("FFT can be computet from full signal 'full' or only from main part 'part'")
            end
        end
    
        function GetFFT(obj,signal) 
            obj.HasSpectrum=true;
            obj.NSamples=numel(signal);
            Y = fft(signal);
            P2 = abs(Y/obj.NSamples(1));
            P1 = P2(1:obj.NSamples/2+1);
            P1(2:end-1) = 2*P1(2:end-1);
            obj.Spectrum=P1;
            obj.FNSamples=numel(P1);
        end
        

    end

    methods (Static)
        function out=NormalizeSignal(signal)
            signal=signal-mean(signal);
            out=signal/max(signal);
        end

        function out=SigAttenuation(time,amp)
            out=struct;
            if numel(time)>1
                [fitobj,gof]=fit(time,amp,'exp1');
                out.Fitobj=fitobj;
                out.Gof=gof;
                out.AttSuccess=true;
            else
                out.AttSuccess=false;
            end
        end
    end
end