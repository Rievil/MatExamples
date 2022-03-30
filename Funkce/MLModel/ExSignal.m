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
        FreqWindow (1,2);
        HasFreqWindow=false;
        SignalFeatures struct;
        SpectrumFeatures struct;
        FreqPeaks=1;
        Option struct;

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
        AttSuccess=false;

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
                        clr(obj.Fig);
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
                            obj.SigAx=gca;
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
                if obj.PlotSpectrum
                    if ~obj.SpecAxSet
                        obj.SpecAx=subplot(1,2,2);
                    end
                    hold(obj.SpecAx,'on');
                    PlotSpectrumFeatures(obj,obj.SpecAx);
                end
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
                newx=linspace(min(obj.Option.Peaks.Time),max(obj.Option.Peaks.Time),100)';
                newy=obj.Option.Atten.Fitobj(newx);
                plot(ax,newx,newy,'--','LineWidth',2,'Color','green');
                
            end
            
            if obj.SetAnnotate
                lgd=legend('location','southeast','FontSize',8);
                lgd.EdgeColor='none';
            end
            
            xlim(ax,[min(obj.Option.Peaks.Time)*0.8,max(obj.Option.Peaks.Time)*1.2]);
            ylim(ax,[min(obj.Signal)*1.2,max(obj.Signal)*1.2]);
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
            totaldur=time(end)-time(1);
            
            
            means=mean(obj.Signal(int32(obj.NSamples*0.5):1:end));
            stds=std(obj.Signal(int32(obj.NSamples*0.5):1:end));
            maxs=max(obj.Signal);

            height=means+(means+stds*obj.NoiseMultiplier);
            
            pulseSNR = snr(time,obj.Signal);
        
            [pks,locs]=findpeaks(obj.Signal,time,'MinPeakHeight',height,...
                'MinPeakDistance',((time(end)-time(1))*0.0001));
            
            TS=table(pks,locs,'VariableNames',{'Amp','Time'});

            hitdist=abs(diff(TS.Time));
            B=find(hitdist>totaldur*.2,1,'first');
            TS(B:end,:)=[];

            
            maxampidx=find(TS.Amp==max(TS.Amp),1);
            if obj.SignalAtt
                TS2=TS(TS.Time>=TS.Time(maxampidx),:);

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
            
            idown=find(obj.Signal>TS.Amp(end),1,'last');
            
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
        
            maxpks=TS.Amp==max(TS.Amp);
            xrise=linspace(time(iup),mean(TS.Time(maxpks)),2)';
            yrise=linspace(obj.Signal(iup),mean(TS.Amp(maxpks)),2)';
            
            obj.Option(1).XRise=xrise;
            obj.Option(1).YRise=yrise;

            obj.Option(1).XDown=linspace(mean(TS.Time(maxpks)),time(idown),2)';
            obj.Option(1).YDown=linspace(mean(TS.Amp(maxpks)),obj.Signal(idown),2)';


            asmup=(obj.Signal(iup)-obj.Signal(maxampidx))/(time(iup)-time(maxampidx));
            asmdown=(obj.Signal(maxampidx)-obj.Signal(idown))/(time(maxampidx)-time(idown));
            
            if isempty(asmup)
                asmup=NaN;
            end
            
            if isempty(asmdown)
                asmdown=NaN;
            end
            
            out.NHits=numel(TS.Amp);
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
            
            
            if obj.HasFreqWindow
                idx=fr>=obj.FreqWindow(1) & fr<=obj.FreqWindow(2) & fr>100;
%                 obj.Spectrum=obj.Spectrum(fr>100 & idx);
%                 fr=fr(fr>100 & idx);
            end
            ftrsh=max(obj.Spectrum(idx))*0.1;

            [fpks,flocs,w,p]=findpeaks(obj.Spectrum(idx),fr(idx),'MinPeakHeight',ftrsh,'MinPeakDistance',(obj.SamplingFreq/2*0.001),'NPeaks',20);
            
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