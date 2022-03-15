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
        SignalFeatures struct;
        SpectrumFeatures struct;
        FreqPeaks=1;
        Option struct;
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
                    case 'spectrum'
                        obj.SetSpectrum(varargin{2})
                    case 'signalnorm'
                        if varargin{2}==true
                            obj.Signal=ExSignal.NormalizeSignal(obj.Signal);
                        else
                        end
                    case 'freqwindow'
                        obj.FreqWindow=varargin{2};
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

        function plot(obj)
            figure;
            if obj.HasSignal==true
                ax1=subplot(1,2,1);
                hold on;

                PlotSignalFeatures(obj,ax1);
                
                ax2=subplot(1,2,2);
                hold on;

                PlotSpectrumFeatures(obj,ax2);

            else
                ax=gca;
                PlotSpectrumFeatures(obj,ax);
            end
        end

    end


    methods (Access=private)

        function PlotSignalFeatures(obj,ax)
            time=obj.Time;
            
            pidx=obj.Option.PartSignalIDX{1}:1:obj.Option.PartSignalIDX{2};
            plot(ax,time,obj.Signal);
            plot(ax,time(pidx),obj.Signal(pidx),':r');
            plot(ax,[time(1) time(end)],[obj.SignalFeatures.Trsh, obj.SignalFeatures.Trsh],...
                '-','Color',[.6 .6 .6]);
            
            plot(ax,obj.Option.XRise,obj.Option.YRise,'-r');
            plot(ax,obj.Option.XDown,obj.Option.YDown,'-y');
            scatter(ax,obj.Option.Peaks.Time,obj.Option.Peaks.Amp,'^k','filled');
            
            if obj.SignalAtt
                newx=linspace(min(obj.Option.Peaks.Time),max(obj.Option.Peaks.Time),10)';
                newy=obj.Option.Atten.Fitobj(newx);
                plot(ax,newx,newy,'-r');
                
            end
        end

        function PlotSpectrumFeatures(obj,ax)
            plot(ax,obj.Frequency,obj.Spectrum);

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
                out.SignalAttAlpha=obj.Option.Atten.Fitobj.a;
                out.SignalAttBeta=obj.Option.Atten.Fitobj.b;
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
            
            
            
            out.NHits=numel(pks);
            out.Trsh=Trsh;
            out.SNR=pulseSNR;
            out.Duration=Dur;
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
%             out=signal-mean(signal);
        end

        function out=SigAttenuation(time,amp)
            out=struct;
            [fitobj,gof]=fit(time,amp,'exp1');
            out.Fitobj=fitobj;
            out.Gof=gof;
        end
    end
end