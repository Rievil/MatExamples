classdef ExSignal < handle
    properties
        Signal;
        AbsSignal;
        SamplingFreq;
        Period;
        NSamples;
        FNSamples;
        Spectrum;
        Features;
        Frequency;
        StartingTime=0;
        EmptyFeatures=false;
    end

    properties (Dependent)
        Time;
        
    end

    properties (SetAccess=private)
        SignalAtt=false;
        Scale='lin';
        NoiseTrsh=5;
        NoiseMultiplier=5;
        FFTSource='full';
        DomSig=false;
        SpecAtt=false;
        SpectrumType='fft'
        PartSignal;
        HasSignal=true;
        HasSpectrum=false;
        FreqWindow;
        HasFreqWindow=false;
        SignalFeatures struct;
        SpectrumFeatures struct;
        DeadTimeSeparator=5;
        FreqPeaks=1;
        Option struct;
        Window;
        UseWindow=false;
        SigAx;
        SpecAx;
        Fig;
        ExciterHitCount=1;
        ExDist=0.08;
        StartMethod='trsh';
        SpectrumRange;
        GetFreqRange=false;
        Interpreter;
    end

    properties (Hidden)
        FigSet=false;
        PlotSignals=true;
        PlotSpectrum=true;
        SigAxSet=false;
        SpecAxSet=false;
        SetAnnotate=false;
        
        AttSuccess=false;

    end

    methods
        function obj=ExSignal(signal,freq,varargin)
            
            switch class(signal)
                case 'table'
                    signal=table2array(signal);
                case 'cell'
                    signal=double(signal);
                case 'double'
            end

            ssz=size(signal);
            if ssz(1)<ssz(2)
                signal=signal';
            end

            

            obj.Signal=signal;
            obj.SamplingFreq=freq;
            obj.Period=1/freq;
            obj.NSamples=numel(obj.Signal);

%             if numel(varargin)>0
            if ~isempty(varargin)
                while numel(varargin)>0
                    
                    switch lower(varargin{1})
                        case 'specatt'
                            obj.SpecAtt=varargin{2};
                        case 'scale'
                            obj.SetScale(char(varargin{2}));
                        case 'trsh'
                            if varargin{2}>0 && varargin{2}<1000
                                obj.NoiseTrsh=varargin{2};
                            end
                        case 'startmethod'
                            obj.StartMethod=lower(varargin{2});
                        case 'noise'
                            if varargin{2}>0 && varargin{2}<100
                                obj.NoiseMultiplier=varargin{2};
                            end
                        case 'fftsource'
                            obj.SetFFTSource(varargin{2});
                        case 'startingtime'
                            obj.StartingTime=varargin{2};
                        case 'signal'
                            obj.HasSignal=varargin{2};
                        case 'spectrum'
                            obj.SetSpectrum(varargin{2})
                            obj.HasSpectrum=true;
                        case 'getfreqrange'
                            obj.GetFreqRange=true;
                        case 'window'
                            switch lower(varargin{2})
                                case 'hamming' 
                                    obj.Window='hamming';
                                case 'hanning'
                                    obj.Window=varargin{2};
                                otherwise
                            end
                            obj.UseWindow=true;
                        case 'signalnorm'
                            if varargin{2}==true
                                obj.Signal=ExSignal.NormalizeSignal(obj.Signal);
                            else
                            end
                        case 'domsig'
                            if logical(varargin{2})
                                obj.DomSig=varargin{2};
                            end
                        case 'exciterhitcount'
                            obj.ExciterHitCount=int32(varargin{2});
                        case 'freqwindow'
                            obj.FreqWindow=varargin{2};
                            obj.HasFreqWindow=true;
                        case 'freqpeaks'
                            if varargin{2}>0 && varargin{2}<50
                                obj.FreqPeaks=varargin{2};
                            end
                        case 'deadtimeseparator'
                            obj.DeadTimeSeparator=varargin{2};
                        case 'ignore'
                        case 'signalatt'
                            if varargin{2}==true
                                obj.SignalAtt=true;
                            else
                                obj.SignalAtt=false;
                            end
                        case 'spectrumtype'
                            switch lower(char(varargin{2}))
                                case 'fft'
                                    obj.SpectrumType='fft';
                                case 'power'
                                    obj.SpectrumType='power';
                            end
                    end
                    varargin(1:2)=[];
                end
            end
            
            if obj.HasSignal
                SignalExtraction(obj);
                switch obj.SpectrumType
                    case 'fft'
                        fun=@GetFFT;
                    case 'power'
                        fun=@GetPowerSpectrum;
                end

                switch obj.FFTSource
                    case 'full'
                       fun(obj);
                    case 'part'
                       fun(obj);
                end
            end

            if obj.HasSpectrum
                SpectrumExtraction(obj);
                if obj.GetFreqRange
                    GetSpectrumRange(obj);
                end
            end

            ReturnFeatures(obj);
        end

        function time=get.Time(obj)
            time=linspace(0,obj.Period*numel(obj.Signal),numel(obj.Signal))';
            time=time+obj.StartingTime;
        end


        function plot(obj,varargin)
            if obj.EmptyFeatures
                return;
            end

            while numel(varargin)>0
                switch lower(varargin{1})
                    case 'plotall'
                        obj.PlotSignals=true;
                        obj.PlotSpectrum=true;
                        obj.SetAnnotate=true;
                        varargin(1)=[];
                    case 'plotsignal'
                        switch varargin{2}
                            case true
                                obj.PlotSignals=varargin{2};
                            case false
                                obj.PlotSignals=varargin{2};
                        end
                        varargin(1:2)=[];
                    case 'plotspectrum'
                        switch varargin{2}
                            case true
                                obj.PlotSpectrum=varargin{2};
                            case false
                                obj.PlotSpectrum=varargin{2};
                        end
                        varargin(1:2)=[];
                    case 'figure'
                        obj.Fig=varargin{2};
                        obj.FigSet=true;
%                         clrf(obj.Fig);
                        varargin(1:2)=[];
                    case 'signalax'
                        obj.SigAx=varargin{2};
                        obj.SigAxSet=true;
                        obj.PlotSignals=true;
                        obj.Fig=obj.SigAx.Parent;
                        obj.FigSet=true;
%                         cla(obj.SigAx);
                        varargin(1:2)=[];
                    case 'spectrumax'
                        obj.SpecAx=varargin{2};
                        obj.PlotSpectrum=true;
                        obj.SpecAxSet=true;
                        obj.Fig=obj.SigAx.Parent;
                        obj.FigSet=true;
%                         cla(obj.SpecAx);
                        varargin(1:2)=[];
                    case 'latex'
                        obj.Interpreter=varargin{2};
                        varargin(1:2)=[];
                    case 'annotate'
%                         obj.SetAnnotate=true;
                        switch varargin{2}
                            case true
                                obj.SetAnnotate=varargin{2};
                            case false
                                obj.SetAnnotate=varargin{2};
                        end
                        varargin(1:2)=[];
                end
                
            end
            
            if ~obj.FigSet
                if obj.SigAxSet || obj.SpecAxSet
                    if obj.SigAxSet
                        obj.Fig=obj.SigAx.Parent;
                    else
                        obj.Fig=obj.SpecAx.Parent;
                    end
                else
                    obj.Fig=figure('CloseRequestFcn',@obj.CloseFigure);
                    t=tiledlayout('flow','Padding','Tight','TileSpacing','tight');
                    nexttile;
                    hold on;
                    obj.SigAx=gca;
                    obj.SigAxSet=true;
                    nexttile;
                    obj.SpecAx=gca;
                    hold on;
                    obj.SpecAxSet=true;

                end
            end
    
            if obj.Interpreter
                set([obj.SpecAx,obj.SigAx],'TickLabelInterpreter','latex');
            end
            
            
%             

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
                        if obj.SigAxSet
                            obj.SigAx=obj.Fig.CurrentAxes;
                        else
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

                hold on;
                ax=gca;
                PlotSpectrumFeatures(obj,ax);

            end
        end

        function CloseFigure(obj,src,evnt)
            obj.FigSet=false;
            obj.SigAxSet=false;
            obj.SpecAxSet=false;
            delete(obj.Fig);
        end
        

    end


    methods (Access=private)

        function PlotSignalFeatures(obj,ax)
            if obj.Interpreter
                sigLa='Signal';
                negsigLa='Negative side of signal';
                sigtrshLa='Signal above treashold';
                trshLa=sprintf("Treashold $%0.0f$\\%% of noise",obj.NoiseMultiplier*100);
                rtLa='RiseTime';
                hitsLa='Hits';
                maxaLa='Max. amplitude';
                attLa='Attenuation curve';
                xlabel(ax,'Time $t$ [s]','Interpreter','latex');
                ylabel(ax,'Amplitude $A_{s}$ [V]','Interpreter','latex');
            else
                sigLa='Signal';
                negsigLa='Negative side of signal';
                sigtrshLa='Signal above treashold';
                trshLa=sprintf("Treashold %0.0f%% of noise",obj.NoiseMultiplier*100);
                rtLa='RiseTime';
                hitsLa='Hits';
                maxaLa='Max. amplitude';
                attLa='Attenuation curve';
                xlabel(ax,'Time \it t \rm [s]');
                ylabel(ax,'Amplitude \it A_{s} \rm [V]');
            end
            time=obj.Time;
            
            pidx=obj.Option.PartSignalIDX{1}:1:obj.Option.PartSignalIDX{2};


            go(1)=plot(ax,time,obj.Signal,'DisplayName',sigLa);
            
            IdxTrsh=pidx;

            XTrsh=time(IdxTrsh);
            YTrsh=obj.Signal(IdxTrsh);
            
            BTrshIdx=YTrsh<obj.SignalFeatures.Trsh;

            XTrsh(BTrshIdx)=NaN;
            YTrsh(BTrshIdx)=NaN;
            
            go(end+1)=plot(ax,time(pidx),obj.AbsSignal(pidx),'DisplayName',negsigLa,'Color',[0.6 .6 .6 .8]);
            go(end+1)=plot(ax,XTrsh,YTrsh,'-','LineWidth',1.1,'DisplayName',sigtrshLa);
            go(end+1)=plot(ax,[time(1) time(end)],[obj.SignalFeatures.Trsh, obj.SignalFeatures.Trsh],...
                '-','Color',[.6 .6 .6],'DisplayName',trshLa);
            
            go(end+1)=plot(ax,obj.Option.XRise,abs(obj.Option.YRise),'--r','DisplayName',rtLa);
            plot(ax,obj.Option.XDown,abs(obj.Option.YDown),'--r');
            
            go(end+1)=scatter(ax,obj.Option.Peaks.Time,obj.Option.Peaks.Amp,5,'ok','filled','DisplayName',hitsLa);
            
%             [maxA,I]=max(obj.Option.Peaks.Amp);
            obj.Option(1).SignalMaxAmpIdx
            xr=[obj.Time(obj.Option.SignalMaxAmpIdx),obj.Time(obj.Option.SignalMaxAmpIdx)];
            yr=[0,abs(obj.Signal(obj.Option.SignalMaxAmpIdx))];
            go(end+1)=plot(ax,xr,yr,'LineStyle','-','Color','k','DisplayName',maxaLa,'LineWidth',3);
            if obj.SignalAtt
%                 newx=linspace(obj.Option.Peaks.Time(obj.Option.SignalMaxAmpIdx),max(obj.Option.Peaks.Time),100)';
                newx=linspace(time(pidx(1)),time(pidx(end)),100)';
                newy=obj.Option.Atten.Fitobj(newx);
                go(end+1)=plot(ax,newx,newy,'-r','DisplayName',attLa);
            end
            
            if obj.DomSig
                xlimleft=time(pidx(1))*0.9;
                xlimright=time(pidx(end))*1.5;
                xlim(ax,[xlimleft,xlimright]);
            end

            if obj.SetAnnotate
                if obj.Interpreter
                    lgd=legend(ax,go,'location','eastoutside','FontSize',8,'Interpreter','latex');
                else
                    lgd=legend(ax,go,'location','eastoutside','FontSize',8);
                end
                lgd.EdgeColor='none';
            end
        end

        function PlotSpectrumFeatures(obj,ax)
            if obj.Interpreter
                specLa='Spectrum';
                domfrLa='Main Dominant frequency';
                otdfLa='Other Dominant frequencies';
                if obj.SpecAtt
                    logattLa=sprintf('Logarithmic attenuation decrement\n$\\upsilon=%0.2e$',obj.SpectrumFeatures.DecadAtt);
                end
                promLa='Prominence';
                freqtrendLa='Frequency trend';
                xlabel('Frequency $f$ [Hz]','Interpreter','latex');
                ylabel('Amplitude $A_{f}$ [V]','Interpreter','latex');
            else
                specLa='Spectrum';
                domfrLa='Main Dominant frequency';
                otdfLa='Other Dominant frequencies';
                if obj.SpecAtt
                    logattLa=sprintf('Logarithmic attenuation decrement\n\\upsilon=%0.2e',obj.SpectrumFeatures.DecadAtt);
                end
                promLa='Prominence';
                freqtrendLa='Frequency trend';
                xlabel('Frequency \it f \rm [Hz]');
                ylabel('Amplitude \it A_{f} \rm [V]');
            end
            tf=table(obj.Frequency,obj.Spectrum,'VariableNames',{'f','y'});
            xlimval=[min(tf.f),max(tf.f)];
            go(1)=plot(ax,tf.f,tf.y,'DisplayName',specLa);
            if size(obj.Option.FreqPeaks,1)>0
                go(end+1)=scatter(ax,obj.Option.FreqPeaks.Freq(1),obj.Option.FreqPeaks.Amp(1),'or','filled','DisplayName',domfrLa);
            end


            if size(obj.Option.FreqPeaks,1)<obj.FreqPeaks
                peaksnum=size(obj.Option.FreqPeaks,1);
            else
                peaksnum=obj.FreqPeaks;
            end

            go(end+1)=scatter(ax,obj.Option.FreqPeaks.Freq(2:end),obj.Option.FreqPeaks.Amp(2:end),'^k','filled',...
                'DisplayName',otdfLa);
            

            if obj.SpecAtt
                fa=[obj.Option.SpectrumParams.AttLfreq;
                    obj.Option.SpectrumParams.AttRfreq];
                ya=[obj.Option.SpectrumParams.AttLamp;
                    obj.Option.SpectrumParams.AttRamp];
                go(end+1)=scatter(ax,fa,...
                ya,'ob','filled',...
                'DisplayName',logattLa);
            end



            for i=1:peaksnum
                x=[obj.Option.FreqPeaks.Freq(i),obj.Option.FreqPeaks.Freq(i)];
                y=[obj.Option.FreqPeaks.Amp(i)-obj.Option.FreqPeaks.Prom(i),obj.Option.FreqPeaks.Amp(i)];
                if i==1
                    go(end+1)=plot(ax,x,y,'-k','DisplayName',promLa);
                else
%                     plot(ax,x,y,'-k');
                end
            end

            if obj.Option.HasSpectrumFitObj
                xnew=obj.Option.FreqPeaks.Freq(1:end);
                ynew=obj.Option.SpectrumFitObj(xnew);
                go(end+1)=plot(ax,xnew,ynew,'--','Color',[0.6 .6 .6 .7],'DisplayName',freqtrendLa);
            end

            xlim(ax,xlimval);
            ylim(ax,[0,obj.Option.FreqPeaks.Amp(1)*1.2]);
            if obj.SetAnnotate
                if obj.Interpreter
                    lgd=legend(ax,go,'location','eastoutside','FontSize',8,'Interpreter','latex');
                else
                    lgd=legend(ax,go,'location','eastoutside','FontSize',8);
                end
                lgd.EdgeColor='none';
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

            if obj.GetFreqRange
                specRange=array2table(obj.SpectrumRange.Amp');
                
                specRange.Properties.VariableNames=string(obj.SpectrumRange.Range);

                obj.Features=[obj.Features, specRange];
            end
            
        end

        function SignalExtraction(obj)

            out=struct;

            time=obj.Time;
            

            obj.AbsSignal=obj.Signal;

            Trsh=0;
            iup=0;
            idown=0;

            switch obj.StartMethod
                case 'fix'
                    Trsh=obj.NoiseTrsh;
                    noiseLevel=Trsh+mean(obj.Signal);
                    iup=find(obj.Signal>Trsh,1,'first');
                case 'trsh'
                    relativeLength=0.3;
                    height=mean(obj.AbsSignal(int32(obj.NSamples*relativeLength):1:end))+...
                        std(obj.AbsSignal(int32(obj.NSamples*relativeLength):1:end))*obj.NoiseTrsh;
        
                    noiseLevel=mean(obj.AbsSignal(int32(obj.NSamples*relativeLength):1:end))+...
                        std(obj.AbsSignal(int32(obj.NSamples*relativeLength):1:end))*obj.NoiseMultiplier;
                    
                    endheight=mean(obj.AbsSignal(int32(obj.NSamples*relativeLength):1:end))+...
                        2/3*std(obj.AbsSignal(int32(obj.NSamples*relativeLength):1:end))...
                        /power(numel(obj.AbsSignal(int32(obj.NSamples*relativeLength):1:end))-1,1/2)*800;
                    
                    Trsh=height;
                    

                
                    iup=find(obj.AbsSignal>Trsh,1,'first');
                    

                    
                case 'adaptive'
                    [cumsig2,idx]=ExSignal.FindHits(obj.Signal,obj.SamplingFreq,obj.Period*10);

                    sT=table(idx,time(idx),cumsig2(idx),'VariableNames',{'Idx','Time','CSig'});
                    sT=sortrows(sT,'CSig','descend');
                    Trsh=obj.AbsSignal(sT.Idx(1));

                    idfind=sT.Idx(1)-int32(sT.Idx(1)-obj.NSamples*0.01);
                    signan=obj.AbsSignal;
                    

                    iup=sT.Idx(1);
                    signan(1:iup,:)=[];
                    noiseLevel=mean(signan)+std(signan)*obj.NoiseMultiplier;
                    out.HitReceived=numel(idx);
            end
            
            sig=obj.Signal;
            idown=find(sig>noiseLevel,1,'last');
%             cond=numel(sig)*0.5;
%             while (idown-iup)<cond
%                 sig(1:idown)=0;
%                 idown=find(sig>noiseLevel,1,'last');
%                 cond=numel(sig)*0.5;
%             end

            farr=logical(zeros(numel(obj.Signal),1));
            farr(time>time(iup) & obj.AbsSignal>Trsh & time<time(idown),1)=true;
%             farr=farr & obj.AbsSignal>Trsh;
%             vals=linspace(1,numel(obj.AbsSignal),numel(obj.AbsSignal))';
            timediff=diff(time(farr));
            deadtimeIdx=find(timediff>obj.Period*obj.DeadTimeSeparator,1,'first');
            if deadtimeIdx>0
%                 idown=deadtimeIdx;
            else
            end



            if iup>0
            else
                iup=1;
            end
        
            if idown>0
            else
                idown=numel(obj.AbsSignal);
            end

            obj.PartSignal=obj.Signal(iup:1:idown,1);

            pulseSNR = snr(obj.Time,obj.Signal);

            minPeakDist=(obj.Time(end)-obj.Time(1))*0.0001;
            [pks,locs]=findpeaks(obj.Signal,obj.Time,'MinPeakHeight',Trsh,...
                'MinPeakDistance',minPeakDist);
            TS=table(pks,locs,'VariableNames',{'Amp','Time'});
            TS=TS(TS.Time>=time(iup) & TS.Time<=time(idown),:);
            TSs=sortrows(TS,'Amp','descend');
            
            if size(TSs,1)>0
                maxampidx=find(obj.Time==TSs.Time(1),1);
            else
                [~,maxampidx] = max(obj.Signal,[],'all');
            end
            
%             switch obj.SignalCenterType
%                 case 'maxamp'
%                     maxampidx=find(obj.Time==TSs.Time(1),1);
%                 case 'mean'
%                     maxampidx=find(obj.Time>=mean(TSs.Time(:)),1);
%                 otherwise
%                     maxampidx=find(obj.Time==TSs.Time(1),1);
%             end
            

            obj.Option(1).Peaks=TS;

            obj.Option(1).PartSignalIDX={iup,idown};
            obj.Option(1).SignalMaxAmpIdx=maxampidx;

            Dur=time(idown)-time(iup);
        
            maxpks=TSs.Amp(1);

            xrise=linspace(time(iup),time(maxampidx),2)';
            yrise=linspace(obj.Signal(iup),obj.Signal(maxampidx),2)';
            
            obj.Option(1).XRise=xrise;
            obj.Option(1).YRise=yrise;

            obj.Option(1).XDown=linspace(time(maxampidx),time(idown),2)';
            obj.Option(1).YDown=linspace(obj.Signal(maxampidx),obj.Signal(idown),2)';


            asmup=(obj.Signal(iup)-obj.Signal(maxampidx))/(time(iup)-time(maxampidx));
            asmdown=(obj.Signal(maxampidx)-obj.Signal(idown))/(time(maxampidx)-time(idown));
            
            if isempty(asmup)
                asmup=NaN;
            end
            
            if isempty(asmdown)
                asmdown=NaN;
            end

            if obj.SignalAtt
                TS2=TS(TS.Time>=TSs.Time(1),:);

                obj.Option(1).Atten=ExSignal.SigAttenuation(TS2{:,2},TS2{:,1});
                if obj.Option(1).Atten.AttSuccess
                    out.SignalAttAlpha=log(obj.Option.Atten.Fitobj.a);
                    out.AttSSE=obj.Option.Atten.Gof.sse;
                    out.AttR2=obj.Option.Atten.Gof.rsquare;
                else
                    out.SignalAttAlpha=NaN;
                    out.AttSSE=NaN;
                    out.AttR2=NaN;
                end
            end
            artx=[obj.Option.XRise(1),obj.Option.Peaks.Time(1)];
            arty=[obj.Option.YRise(1),obj.Option.Peaks.Amp(1)];
            out.SignalStart=obj.Time(iup);
            out.RiseAngle=diff(arty)/diff(artx);
            out.SignalCenterTime=mean(TSs.Time(:));
            out.SignalCenterAmp=mean(TSs.Amp(:));
            out.ImpulseFactor=max(abs(obj.Signal))/mean(abs(obj.Signal));
            out.NHits=numel(pks);
            out.Trsh=Trsh;
            out.SNR=pulseSNR;
            out.Duration=time(idown)-time(iup);
            out.SwingValue=abs(min(obj.Signal))+max(obj.Signal);
            out.CrestFactor=peak2rms(obj.Signal);
            out.TotalHarmonicDistortion=thd(obj.Signal);
            out.Kurt=kurtosis(obj.Signal);
            out.Skew=skewness(obj.Signal,0);
            out.RMS=rms(obj.Signal,'omitnan');
            out.AsmpUp=asmup;
            out.MaxAmp=obj.Signal(maxampidx);
            out.MaxAmpTime=obj.Time(maxampidx);
            out.AsmpDown=asmdown;
            out.RiseTime=diff(xrise);
            out.RiseEnergy=trapz(obj.Time(iup:1:maxampidx),abs(obj.Signal(iup:1:maxampidx)));
            out.SignalEnergy=trapz(obj.Time(iup:1:idown),abs(obj.Signal(iup:1:idown)));
            out.AvgFreq=out.NHits/out.Duration;
            out.Raval=out.MaxAmp/out.RiseTime;
            out.EnergyRatio=abs(log(out.RiseEnergy./out.SignalEnergy));
            obj.SignalFeatures=out;
        end
        
        function GetSpectrumRange(obj)

            fr=obj.Frequency;
            tf=table(obj.Spectrum,obj.Frequency,'VariableNames',{'y','f'});
            tfo=tf;
            if obj.HasFreqWindow
                tf=tf(tf.f>=obj.FreqWindow(1) & tf.f<=obj.FreqWindow(2),:);
            end

            rangeWidth=250;
            ranges=[0 3000];

            res=table;
            for i=1:count
                range=[(i-1)*rangeWidth,i*rangeWidth];
                tfi=tf(tf.f>=range(1) & tf.f<range(2),:);
                res=[res; table(sprintf("Range%d_%d",range(1),range(2)),max(tfi.y),'VariableNames',{'Range','Amp'})];


            end
            res.Amp=res.Amp-min(res.Amp);
            res.Amp=res.Amp/max(res.Amp);
            obj.SpectrumRange=res;
        end

        function SpectrumExtraction(obj)
            out=struct;
            fr=obj.Frequency;
            
            tf=table(obj.Spectrum,obj.Frequency,'VariableNames',{'y','f'});
            tfo=tf;
            if obj.HasFreqWindow
                tf=tf(tf.f>=obj.FreqWindow(1) & tf.f<=obj.FreqWindow(2),:);
            end
            
            
            minStep=(obj.SamplingFreq/2000);
            [fpks,flocs,w,p]=findpeaks(tf.y,tf.f,'MinPeakHeight',max(tf.y)*0.001,'MinPeakDistance',minStep,'NPeaks',100,...
                'MinPeakProminence',max(tf.y)*0.01,'MinPeakWidth',minStep*0.25);
            
            Tf=table(fpks,flocs,w,p,'VariableNames',{'Amp','Freq','Width','Prom'});
            Tf=Tf(Tf.Prom>max(Tf.Prom)*0.001,:);

            if size(Tf,1)<obj.FreqPeaks
                warning(sprintf("Property 'FreqPeaks' was set to %d, but only %d meanigful peaks were extracted",obj.FreqPeaks,size(Tf,1)));
            end

            
            Tf=sortrows(Tf,'Prom','Descend');
            obj.Option(1).FreqPeaks=Tf;
            out.AmpRatio=log(Tf.Amp(1)/obj.SignalFeatures.RiseTime);

            idxspec=find(obj.Spectrum==Tf.Amp(1));

            idx=find(tf.f==Tf.Freq(1));
            
            SpectrumParams=struct;
            SpectrumParams.DomAmpIdx=idx;
            SpectrumParams.DomAmpVal=tf.f(idx);

            if obj.SpecAtt
                [decadatt,param]=ExSignal.GetDecadAtt(tfo.f,tfo.y,idxspec);
                if ~strcmp(class(decadatt),'double')
                    out.DecadAtt=NaN;
                else
                    if decadatt>0
                        out.DecadAtt=decadatt;
                    else
                        out.DecadAtt=NaN;
                    end
                end

                SpectrumParams.AttLamp=param.Lamp;
                SpectrumParams.AttRamp=param.Ramp;
                SpectrumParams.AttLfreq=param.Lfreq;
                SpectrumParams.AttRfreq=param.Rfreq;
            end

            obj.Option(1).SpectrumParams=SpectrumParams;
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
                end
            end

            
            if size(Tf,1)>1
                fitobj=fit(Tf.Freq,Tf.Amp,'poly1','Weight',Tf.Prom);
                p1=coeffvalues(fitobj);
                obj.Option.HasSpectrumFitObj=true;
                obj.Option.SpectrumFitObj=fitobj;
                out.P1Directive=p1(1);
                out.P2Beta=p1(2);
            else
                out.P1Directive=1;
                out.P2Beta=0;
                obj.Option.HasSpectrumFitObj=false;
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
    
        function GetFFT(obj) 
            signal=obj.Signal;
            obj.HasSpectrum=true;
            obj.NSamples=numel(signal);
            
            if obj.UseWindow
                switch obj.Window
                    case 'hamming'
                        signal=signal.*hamming(length(signal),'periodic');
                    case 'hanning'
                        signal=signal.*hann(length(signal),'periodic');
                    otherwise
                end
            end

            Y = fft(signal);
            P2 = abs(Y/obj.NSamples(1));
            P1 = P2(1:obj.NSamples/2+1);
            P1(2:end-1) = 2*P1(2:end-1);

            
            
            obj.Spectrum=P1;
            obj.FNSamples=numel(P1);
            freq=zeros(obj.FNSamples,1);
            freq(:,1)=linspace(0,obj.SamplingFreq/2,obj.FNSamples)';
            obj.HasSpectrum=true;
            obj.Frequency=freq;
        end

        function GetPowerSpectrum(obj)
            tuReal = "seconds";
            time=obj.Time;
            signal=obj.Signal;
            Fs=obj.SamplingFreq;
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
            L = fix(length(x)/4.5);
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
            obj.HasSpectrum=true;
            obj.Frequency=ps.Frequency;
            obj.Spectrum=ps.SpectrumData;
            obj.FNSamples=numel(obj.Spectrum);
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

        function [decadatt,param]=GetDecadAtt(x,y,idx)
            trsh=y(idx)/power(2,0.5);
            ymax=y(idx);
            y(y>trsh)=0;
            lidx=idx;
            ridx=idx;
            
            lval=0;
            rval=0;
            while lval==0
                lidx=lidx-1;
                lval=y(lidx);
            end

            while rval==0
                ridx=ridx+1;
                rval=y(ridx);
            end
            jmen=x(ridx)-x(lidx);
            cit=ymax;
            decadatt=pi()*jmen/cit;
            param=struct;
            param.Lamp=lval;
            param.Ramp=rval;
            param.Lfreq=x(lidx);
            param.Rfreq=x(ridx);
        end
        
        function [fig]=EasyPlot(filename)
            signal=readtable(filename,'NumHeaderLines',9,'Delimiter',';','DecimalSeparator',',');
            signal.Properties.VariableNames={'Time','Amp'};
            dur=[signal.Time(end)-signal.Time(1)];
            samples=size(signal,1);
            freq=samples/dur;
            tic;
            exobj=ExSignal(signal.Amp,freq,'freqwindow',[100 20e+3],'signalatt',true,'noise',40,...
                'DeadTimeSeparator',1200,'fftsource','full','window','hamming');
            disp(toc);
            %
            fig=figure;
            t=tiledlayout(2,1,'Padding','tight','TileSpacing','tight');
        
            nexttile;
            ax1=gca;
            xlabel(ax1,'Čas [s]');
            ylabel(ax1,'Amplituda [V]');
            
            nexttile;
            ax2=gca;
            xlabel(ax2,'Frekvence [Hz]');
            ylabel(ax2,'Amplituda [V]');
            
            plot(exobj,'signalax',ax1,'spectrumax',ax2,'annotate',true);
            delete(exobj);
        end

        function [cumsig2,idx]=FindHits(signal,freq,dist)
            period=1/freq;
            samples=numel(signal);
            duration=samples*period;
            time=linspace(0,duration,samples);
        
            cumsig=cumsum(abs(signal));
        %     delta=linspace(cumsig(1),cumsig(end)*2,numel(cumsig))';
            delta=linspace(cumsig(1),cumsig(end),numel(cumsig))';
            cumsig2=cumsig-delta;
            cumsig2=cumsig2*(-1);
            cumsig2=cumsig2-min(cumsig2);
        
            [pks,locs,~,~]=findpeaks(cumsig2,time,'MinPeakProminence',max(cumsig2)*0.01,'MinPeakDistance',dist);
            idx=zeros(numel(pks),1);
            for i=1:numel(pks)
                idx(i,:)=find(time==locs(i),1);
            end
        end
        
    end
end