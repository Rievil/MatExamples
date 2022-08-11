classdef Gyro <  handle
    %GYRO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Filename;
        WinLen=2;
        Parent;
        TS table; %signal table
        TD table; %description table
        TG table; %gyroskope table
        TJ table; %joined and repaired table
        TA table; %angle table
        TF table; %features from signals
        CoordUnit='m';
        DepthCol='Depth';
        SpecCol=[];
        Varnames;
        PipeDim=0.3;
        PipeType='Circle';
    end

    properties (Hidden)
        IsRead=false;
    end
    
    methods
        function obj = Gyro(invar)
            switch class(invar)
                case 'class'
                    obj.Parent=parent;
                otherwise
                    if ischar(invar) || strcmp(class(invar),'string')
                        obj.Filename=invar;
                        ReadFile(obj);
                    else
                        error("Wrong input type: '%s'. Input var can be either 'obj', 'char' or 'sting'\n",class(invar))
                    end
            end
        end
        
        function [Fig]=PlotAcc(obj)
            Fig=Gyro.PlotGyro(obj.TG,false);
        end

        function [fig,ax1,cbar,ax2]=plot(obj,zval)
            GenerateShape(obj);

            Tj=obj.TJ;
            names=string(Tj.Properties.VariableNames);
            A=find(names==obj.DepthCol);
            Tj.Properties.VariableNames{A}='Depth';
            TFG2=[Tj, obj.TF];
            [fig,ax1,cbar,ax2]=Gyro.PlotPipe(TFG2,obj.TA,zval);
        end

        function Run(obj,varargin)
            while numel(varargin)>0
                switch varargin{1}
                    case 'DepthCol'
                        obj.DepthCol=varargin{2};
                    case 'SpecCol'
                        obj.SpecCol=varargin{2};
                    case 'Units'
                        switch varargin{2}
                            case 'mm'
                                obj.CoordUnit=varargin{2};
                            case 'cm'
                                obj.CoordUnit=varargin{2};
                            case 'm'
                                obj.CoordUnit=varargin{2};
                        end
                    case 'Pipe'
                        switch varargin{2}
                            case 'Egg'
                                obj.PipeType=varargin{2};
                            case 'Circle'
                                obj.PipeType=varargin{2};
                        end
                    case 'PipeDim'
                        obj.PipeDim=varargin{2};

                end
                varargin(1:2)=[];
            end
            
            if obj.IsRead
                JoinRecords(obj);
                obj.Varnames=string(obj.TJ.Properties.VariableNames);
                GenerateShape(obj);
                AssignCoor(obj);
                ExtractFeatures(obj);
            else

            end
        end

        function ExtractFeatures(obj)
            f=waitbar(0,'Loading');
            TF=table;
            for i=1:size(obj.TJ,1)
                waitbar(i/size(obj.TJ,1),f,'Loading ...');
                signal=obj.TJ.Signals{i};

                freq=1/(seconds(signal.Time(2))-seconds(signal.Time(1)));

                exobj=ExSignal(signal.Microphone,freq,'freqwindow',[100,10e+3],'signalatt',true,'noise',40,...
                                'DeadTimeSeparator',10,'fftsource','full','window','hamming','exciterhitcount',3);
                
                TF=[TF; exobj.Features];
                delete(exobj);
            end
            obj.TF=TF;
%             [obj.TF,~] = Gyro.diagnosticFeatures3(obj.TJ);
            delete(f);
        end
        
        function AssignCoor(obj)
            for i=1:size(obj.TJ,1)
                angle=obj.TJ.roll(i);
                x=interp1(obj.TA.Angle,obj.TA.X,angle);
                y=interp1(obj.TA.Angle,obj.TA.Y,angle);
%                 Idx=knnsearch(obj.TA.Angle,angle);
                obj.TJ.X(i)=x;
                obj.TJ.Y(i)=y;
                depth=double(obj.TJ.(obj.DepthCol)(i));
                obj.TJ.Z(i)=obj.GetHeight(depth);
            end
        end

        function GenerateShape(obj)
            obj.TA=table;
            switch obj.PipeType
                case 'Egg'
                    obj.TA=Gyro.GetCoorFromEggShape(obj.GetHeight(obj.PipeDim));
                case 'Circle'
                    obj.TA=Gyro.GetCoorFromCircle(obj.GetHeight(obj.PipeDim));
            end
        end

        function val=GetHeight(obj,inval)
            switch obj.CoordUnit
                case 'mm'
                    val=inval/1000;
                case 'cm'
                    val=inval/100;
                case 'm'
                    val=inval;
            end
        end
        
        function JoinRecords(obj)
            if ~TestRecords(obj)
                RepairRecords(obj);
            end
            
            
            TFG=join(obj.TS,obj.TD,'Keys','ID');
            obj.TJ=innerjoin(TFG, obj.TG,'Keys','ID');
            obj.TJ.X=zeros(size(obj.TJ,1),1);
            obj.TJ.Y=zeros(size(obj.TJ,1),1);
            obj.TJ.Z=zeros(size(obj.TJ,1),1);
            obj.TJ.(obj.DepthCol)=cell2mat(obj.TJ.(obj.DepthCol));
        end

        function state=TestRecords(obj)
            unq1=unique(obj.TS.ID);
            unq2=unique(obj.TD.ID);
            unq3=unique(obj.TG.ID);
            unq3(isnan(unq3))=[];

            A=intersect(unq1,unq2);
            B=intersect(A,unq3);
            C=intersect(A,B);
            if numel(A)==numel(B) && numel(B)==numel(C)
                state=true;
            else
                state=false;
            end
        end

        function RepairRecords(obj)
            x1=datenum(obj.TS.Date);
            x2=datenum(obj.TG.Time);
            Idx = knnsearch(x2,x1);

            Ids=unique(obj.TS.ID);
            
            for i=1:numel(Idx)
                obj.TG.ID(idx)=Ids(i);
            end
        end

        function ReadFile(obj)
            var=["is not","is"];
            ismat=1;
            obj.IsRead=false;
            try
                indata=load(obj.Filename);
                ismat=2;
                obj.TS=indata.stash.Asker.SignalsTable;
                obj.TD=indata.stash.Asker.Marker.DescTable;
                obj.TG=Gyro.ClearGyro(indata.stash.Asker.Arduino.Record);
                disp("Success!");
                obj.IsRead=true;
            catch ME
                obj.TS=[];
                obj.TD=[];
                obj.TG=[];
                error("Given file '%s' %s a .mat file and is not a IEDevice mat file\n",obj.Filename,var(ismat));
            end
        end

        function [pitch,roll]=GetRoll(obj,ard,id)
            gdata=ard.Record;
            row=find(gdata.ID==id);
            if sum(row)==0
                row=size(gdata,1)-obj.WinLen/2;
            end

            if row>ceil(obj.WinLen/2)
                lr=row-obj.WinLen/2;
            else
                lr=1;
            end

            if row+ceil(obj.WinLen/2)<(size(gdata,1))
                rr=row+ceil(obj.WinLen/2);
            else
                rr=size(gdata,1);
            end

            Ti=gdata(lr:rr,:);
            
            Tic=Gyro.ClearGyro(Ti);
            [pitch,roll]=Gyro.GetAngle(Tic);
            pitch=mean(pitch,'all');
            roll=mean(roll,'all');
        end
    end

    methods %abstract
        function Pack(obj)
        end

        function Populate(obj)
        end

        function DrawGui(obj)
        end
    end


    methods (Static)
        function [TF2]=ClearGyro(data)
            TF2=data;
            for j=4:10
                TF2{:,j}=smoothdata(TF2{:,j},'gaussian',10);
            end
            
            TF2.GyX(TF2.GyX< 0.06 & TF2.GyX>-0.06)=0;
            TF2.GyY(TF2.GyY< 0.06 & TF2.GyY>-0.06)=0;
            TF2.GyZ(TF2.GyZ< 0.06 & TF2.GyZ>-0.06)=0;
            
            TF2.AcZ=TF2.AcZ/16384*9.81;
            TF2.AcX=TF2.AcX/16384*9.81;
            TF2.AcY=TF2.AcY/16384*9.81;
            
            sen=(16.4/2);
            TF2.GyX=TF2.GyX/(32750)*sen;
            
            TF2.GyY=TF2.GyY/(32750)*sen;
            
            TF2.GyZ=TF2.GyZ/(32750)*sen;
            
            [pitch,roll]=Gyro.GetAngle(TF2);
            TF2=[TF2, table(pitch,roll,'VariableNames',{'pitch','roll'})];
        end

        function [X,Y]=GetCoor(TA,roll)
            
        end

        function [pitch,roll]=GetAngle(gyrodata)

            TA=gyrodata;
        
            x=TA.AcX;
            y=TA.AcY;
            z=TA.AcZ;
            
            pitch=zeros(numel(x),1);
            roll=zeros(numel(x),1);
            for i=1:numel(x)
                if x(i)>0 && z(i)>0
                    roll(i,1)=atan(x(i)/z(i))*57.2957795;
                elseif x(i)<0 && z(i)>0
                    roll(i,1)=atan(x(i)/z(i))*57.2957795+360;
                elseif x(i)<0 && z(i)<0
                    roll(i,1)=atan(x(i)/z(i))*57.2957795+180;
                elseif x(i)>0 && z(i)<0
                    roll(i,1)=atan(x(i)/z(i))*57.2957795+180;
                end
            end
            pitch=asin(y./9.81)*57.2957795;
        end

        function TShape=GetCoorFromCircle(height)
            val=0:0.05:360;
            anglearr=table;
            r=height;
            for i=1:numel(val)
                q=(val(i)-90)/360*2*pi;
                x = r*cos(q);    % cartesian x coordinate
                y = r*sin(q); 
                anglearr=[anglearr; table(val(i),x,y,'VariableNames',{'Angle','X','Y'})];
            end
            TShape=sortrows(anglearr,'Angle','Ascend');
        end

        function TShape=GetCoorFromEggShape(height)
            a=height; %výška vejce
            xii=linspace(0,a,2000);
            yii=zeros(numel(xii),1);
            for i=1:numel(xii)
                yii(i,1)=power(power(a,0.5)*xii(i)-power(xii(i),1.5),1/2);
            end
            
            xif=[xii'; flip(xii')];
            yif=[yii; flip(yii.*(-1))];
            
            %otočení dle orientace v terénu
            theta=-90;
            R=[cosd(theta) -sind(theta); sind(theta) cosd(theta)];
            coordT=[xif, yif];
            rotcoord=coordT*R';
            
            t=rotcoord(:,1);
            y=rotcoord(:,2);
            
            [M,I]=max(t);
            y=y-y(I);
            
            % plot(t,y);
            
            anglearr=zeros(numel(y),3);
            for i=1:numel(y)-1
                dy=diff(y)./diff(t);
                k=i; % point number 220
                tang=(t-t(k))*dy(k)+y(k);
            %     hold on
                if k<51 || k>numel(t)-51
                    red=k-1;
                else
                    red=50;
                end
                
                xd=max(t)-min(t);
                yd=max(tang)-min(tang);
                ang=atan(yd/xd)*57.2957795;
                
                if t(k)>0 && y(k)>0
                    ang=ang+180;
                elseif t(k)>0 && y(k)<=0
                    ang=360-ang;
                elseif t(k)<0 && y(k)<0
                    ang=ang;
                elseif t(k)<=0 && y(k)>0
                    ang=ang+90;
                elseif t(k)==0 && y(k)>=0
                    ang=180;
                elseif t(k)==0 && y(k)<=0
                    ang=0;
                else
                    %ang=0;
                end
                anglearr(i,1)=ang;
                anglearr(i,2)=t(i);
                anglearr(i,3)=y(i);
            end
            
            [~,I2]=unique(anglearr(:,1));
            anglearr=anglearr(I2,:);
            [~,I]=sort(anglearr(:,1),1);
            anglearr=anglearr(I,:);
            TShape=table(anglearr(:,1),anglearr(:,2),anglearr(:,3),'VariableNames',{'Angle','X','Y'});
        end

        function Fig=PlotGyro(data,bool)
            TF2=data;
            %
            if bool==true
                [TF2]=Gyro.ClearGyro(data);
            end
            %
            
            Fig=figure;
            
            xo=TF2.Time;
            x=second(TF2.Time);
            x=x-x(1);
            freq=1/((x(end)-x(1))/numel(x));

            t=tiledlayout(2,1,"TileSpacing","compact",'Padding','tight');
            ax1=nexttile;
            hold on;
            y1=smoothdata(TF2.AcX,'gaussian',20);
            y2=smoothdata(TF2.AcY,'gaussian',20);
            y3=smoothdata(TF2.AcZ,'gaussian',20);
            
            plot(xo,TF2.AcX,'-','DisplayName','Acx');
            plot(xo,TF2.AcY,'-','DisplayName','AcY');
            plot(xo,TF2.AcZ,'-','DisplayName','AcZ');
            scatter(xo(logical(TF2.B)),TF2.AcZ(logical(TF2.B)),'Filled','DisplayName','Meas');

%             lgd=legend('location','north');
%             lgd.NumColumns=4;
            ylabel('Acceleration [m/s^{2}]');
            ax2=nexttile;
            hold on;
            
            yi1=smoothdata(TF2.GyX,'gaussian',20);
            yi2=smoothdata(TF2.GyY,'gaussian',20);
            yi3=smoothdata(TF2.GyZ,'gaussian',20);
            
            plot(xo,TF2.GyX,'DisplayName','X');
            plot(xo,TF2.GyY,'DisplayName','Y');
            plot(xo,TF2.GyZ,'DisplayName','Z');
            scatter(xo(logical(TF2.B)),TF2.GyZ(logical(TF2.B)),'Filled','DisplayName','Meas');
            lgd=legend;
            lgd.NumColumns=4;
            lgd.Layout.Tile = 'South';
            ylabel('Angle velocity [°/s]');
            xlabel(t,'Time');
        end

        function [fig,ax1,cbar,ax2]=PlotPipe(TFG2,TA,zvariable)
            fig=figure('position',[0 80 750 750]);
            t=tiledlayout('flow','TileSpacing','tight','Padding','loose');
            nexttile;
            hold on;
            box on;
            grid on;
            ax1=gca;
            
            unqdepth=unique(TFG2.Depth);
            yvallabel=zvariable;
            go=[];
            xa=[];
            ya=[];
            za=[];
            fr=[];
            for ln=1:numel(unqdepth)
                Tia=linspace(unqdepth(ln),unqdepth(ln),size(TA,1))';
                Tib=linspace(unqdepth(ln),unqdepth(ln),size(TFG2,1))';
                
                Idxi=TFG2.Depth==unqdepth(ln);
                if ln==1
                    go(end+1)=scatter3(ax1,TFG2.X(Idxi),Tib(Idxi),TFG2.Y(Idxi),200,TFG2.(yvallabel)(Idxi),'filled','DisplayName','Měření pomocí IEDevice');
                    go(end+1)=plot3(ax1,TA.X,Tia,TA.Y,'-','Color',[0.5 0.5 0.5 0.5],'DisplayName','Počítaný obvod trouby');
                else
                    scatter3(ax1,TFG2.X(Idxi),Tib(Idxi),TFG2.Y(Idxi),200,TFG2.(yvallabel)(Idxi),'filled','DisplayName','Měření pomocí IEDevice');
                    plot3(ax1,TA.X,Tia,TA.Y,'-','Color',[0.5 0.5 0.5 0.5],'DisplayName','Počítaný obvod trouby');
                end
                xa=[xa; TFG2.X(Idxi)];
                ya=[ya; Tib(Idxi)];
                za=[za; TFG2.Y(Idxi)];
                fr=[fr; TFG2.(yvallabel)(Idxi)];
            
            
            
            end
            colormap(ax1,"jet");
            cbar=colorbar(ax1);
            cbar.Label.String=yvallabel;
            % set( cbar, 'YDir', 'reverse' );
            caxis(ax1,[min(TFG2.(yvallabel))*0.8,max(TFG2.(yvallabel))*1.2]);
            xlabel(ax1,'Šířka [m]');
            zlabel(ax1,'Výška [m]');
            ylabel(ax1,'Hloubka [m]');
            legend(ax1,go,'location','southoutside');
            view(ax1,60,15);
            
            
            ax2=axes(fig,'position',[0.15 0.85 0.2 .12]);
            hi=histogram(ax2,TFG2.(yvallabel));
            set(ax2,'Color','none','box','off');
            xlabel(ax2,yvallabel);
            ylabel(ax2,'Počet [-]');
            xt=hi.BinEdges(2:end)-hi.BinWidth/2;
            yt=hi.BinCounts;
            text(ax2,xt',yt'+0.07*max(yt),num2str(yt'),'HorizontalAlignment','Center',...
                'FontSize',8);
        end

        function [featureTable,outputTable] = diagnosticFeatures3(inputData)
            %DIAGNOSTICFEATURES recreates results in Diagnostic Feature Designer.
            %
            % Input:
            %  inputData: A table or a cell array of tables/matrices containing the
            %  data as those imported into the app.
            %
            % Output:
            %  featureTable: A table containing all features and condition variables.
            %  outputTable: A table containing the computation results.
            %
            % This function computes signals:
            %  Signal_interp/Microphone
            %
            % This function computes spectra:
            %  Signal_ps/SpectrumData
            %
            % This function computes features:
            %  Signal_sigstats/ClearanceFactor
            %  Signal_sigstats/CrestFactor
            %  Signal_sigstats/ImpulseFactor
            %  Signal_sigstats/Kurtosis
            %  Signal_sigstats/Mean
            %  Signal_sigstats/PeakValue
            %  Signal_sigstats/RMS
            %  Signal_sigstats/SINAD
            %  Signal_sigstats/SNR
            %  Signal_sigstats/ShapeFactor
            %  Signal_sigstats/Skewness
            %  Signal_sigstats/Std
            %  Signal_sigstats/THD
            %  Signal_ps_spec/PeakAmp1
            %  Signal_ps_spec/PeakFreq1
            %  Signal_ps_spec/Wn1
            %  Signal_ps_spec/Zeta1
            %  Signal_ps_spec/BandPower
            %
            % Organization of the function:
            % 1. Compute signals/spectra/features
            % 2. Extract computed features into a table
            %
            % Modify the function to add or remove data processing, feature generation
            % or ranking operations.
            
            % Auto-generated by MATLAB on 27-Jun-2022 20:29:26
            
            % Create output ensemble.
            outputEnsemble = workspaceEnsemble(inputData,'DataVariables',"Signals",'ConditionVariables',"Class");
            
            % Reset the ensemble to read from the beginning of the ensemble.
            reset(outputEnsemble);
            
            % Append new signal or feature names to DataVariables.
            outputEnsemble.DataVariables = unique([outputEnsemble.DataVariables;"Signal_interp";"Signal_sigstats";"Signal_ps";"Signal_ps_spec"],'stable');
            
            % Set SelectedVariables to select variables to read from the ensemble.
            outputEnsemble.SelectedVariables = "Signals";
            
            % Compute sampling freqency for interpolation
            member1 = read(outputEnsemble);
            
            time = readMemberData(member1,"Signals/Time");
            time = time2num(time,"seconds");
            Signal_interp_Fs = effectivefs(time);
            reset(outputEnsemble)
            
            % Loop through all ensemble members to read and write data.
            while hasdata(outputEnsemble)
                % Read one member.
                member = read(outputEnsemble);
            
                % Get all input variables.
                Signal = readMemberData(member,"Signals",["Time","Microphone"]);
            
                % Initialize a table to store results.
                memberResult = table;
            
                % Interpolation
                try
                    % Compute interpolation
                    time = Signal.Time;
            
                    % Get sampling period
                    samplePeriod = 1/Signal_interp_Fs;
                    if isduration(time) || isdatetime(time)
                        samplePeriod = seconds(samplePeriod);
                    end
            
                    if isdatetime(time)
                        timeOrigin = datetime(0,1,1,0,0,0);
                        ivStart = min(time) - timeOrigin;
                        ivEnd = max(time) - timeOrigin;
                    else
                        ivStart = min(time);
                        ivEnd = max(time);
                    end
            
                    gridStartIdx = ceil(ivStart/samplePeriod);
                    gridEndIdx = floor(ivEnd/samplePeriod);
            
                    ivGrid = (gridStartIdx:gridEndIdx)'*samplePeriod;
                    if isdatetime(time)
                        ivGrid = ivGrid + timeOrigin;
                    end
            
                    % Interpolation
                    val = interp1(time,Signal.Microphone,ivGrid,'linear',NaN);
                    Signal_interp = table(ivGrid,val,'VariableNames',["Time","Microphone"]);
                catch
                    % Package computed signal into a table.
                    Signal_interp = table(NaN,NaN,'VariableNames',["Time","Microphone"]);
                end
            
                % Append computed results to the member table.
                memberResult = [memberResult, ...
                    table({Signal_interp},'VariableNames',"Signal_interp")]; %#ok<AGROW>
            
                %% SignalFeatures
                try
                    % Compute signal features.
                    inputSignal = Signal.Microphone;
                    ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
                    CrestFactor = peak2rms(inputSignal);
                    ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
                    Kurtosis = kurtosis(inputSignal);
                    Mean = mean(inputSignal,'omitnan');
                    PeakValue = max(abs(inputSignal));
                    RMS = rms(inputSignal,'omitnan');
                    SINAD = sinad(inputSignal);
                    SNR = snr(inputSignal);
                    ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
                    Skewness = skewness(inputSignal);
                    Std = std(inputSignal,'omitnan');
                    THD = thd(inputSignal);
            
                    % Concatenate signal features.
                    featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];
            
                    % Package computed features into a table.
                    featureNames = ["ClearanceFactor","CrestFactor","ImpulseFactor","Kurtosis","Mean","PeakValue","RMS","SINAD","SNR","ShapeFactor","Skewness","Std","THD"];
                    Signal_sigstats = array2table(featureValues,'VariableNames',featureNames);
                catch
                    % Package computed features into a table.
                    featureValues = NaN(1,13);
                    featureNames = ["ClearanceFactor","CrestFactor","ImpulseFactor","Kurtosis","Mean","PeakValue","RMS","SINAD","SNR","ShapeFactor","Skewness","Std","THD"];
                    Signal_sigstats = array2table(featureValues,'VariableNames',featureNames);
                end
            
                % Append computed results to the member table.
                memberResult = [memberResult, ...
                    table({Signal_sigstats},'VariableNames',"Signal_sigstats")]; %#ok<AGROW>
            
                %% PowerSpectrum
                try
                    % Get units to use in computed spectrum.
                    tuReal = "seconds";
            
                    % Compute effective sampling rate.
                    tNumeric = time2num(Signal_interp.Time,tuReal);
                    [Fs,irregular] = effectivefs(tNumeric);
                    Ts = 1/Fs;
            
                    % Resample non-uniform signals.
                    x = Signal_interp.Microphone;
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
                    Signal_ps = ps;
                catch
                    Signal_ps = table(NaN, NaN, 'VariableNames', ["Frequency", "SpectrumData"]);
                end
            
                % Append computed results to the member table.
                memberResult = [memberResult, ...
                    table({Signal_ps},'VariableNames',"Signal_ps")]; %#ok<AGROW>
            
                %% SpectrumFeatures
                try
                    % Compute spectral features.
                    % Get frequency unit conversion factor.
                    factor = funitconv('Hz', 'rad/TimeUnit', 'seconds');
                    ps = Signal_ps.SpectrumData;
                    w = Signal_ps.Frequency;
                    w = factor*w;
                    Fs = factor*Signal_ps.Properties.CustomProperties.SampleFrequency/(2*pi);
                    Ts = 1/Fs;
                    mask_1 = (w>=factor*10) & (w<=factor*20000);
                    ps = ps(mask_1);
                    w = w(mask_1);
            
                    % Compute spectral peaks.
                    [peakAmp,peakFreq] = findpeaks(ps,w/factor,'MinPeakHeight',-Inf, ...
                        'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',1);
                    peakAmp = [peakAmp(:); NaN(1-numel(peakAmp),1)];
                    peakFreq = [peakFreq(:); NaN(1-numel(peakFreq),1)];
            
                    % Compute modal coefficients.
                    [wn,zeta] = modalfit(ps,w/2/pi,1/Ts,1,'FitMethod','lsrf','Feedthrough',true);
                    wn = 2*pi*wn/factor;
                    wn = [wn(:); NaN(1-numel(wn),1)];
                    zeta = [zeta(:); NaN(1-numel(zeta),1)];
            
                    % Extract individual feature values.
                    PeakAmp1 = peakAmp(1);
                    PeakFreq1 = peakFreq(1);
                    Wn1 = wn(1);
                    Zeta1 = zeta(1);
                    BandPower = trapz(w/factor,ps);
            
                    % Concatenate signal features.
                    featureValues = [PeakAmp1,PeakFreq1,Wn1,Zeta1,BandPower];
            
                    % Package computed features into a table.
                    featureNames = ["PeakAmp1","PeakFreq1","Wn1","Zeta1","BandPower"];
                    Signal_ps_spec = array2table(featureValues,'VariableNames',featureNames);
                catch
                    % Package computed features into a table.
                    featureValues = NaN(1,5);
                    featureNames = ["PeakAmp1","PeakFreq1","Wn1","Zeta1","BandPower"];
                    Signal_ps_spec = array2table(featureValues,'VariableNames',featureNames);
                end
            
                % Append computed results to the member table.
                memberResult = [memberResult, ...
                    table({Signal_ps_spec},'VariableNames',"Signal_ps_spec")]; %#ok<AGROW>
            
                %% Write all the results for the current member to the ensemble.
                writeToLastMemberRead(outputEnsemble,memberResult)
            end
            
            % Gather all features into a table.
            featureTable = readFeatureTable(outputEnsemble);
            
            % Set SelectedVariables to select variables to read from the ensemble.
            outputEnsemble.SelectedVariables = unique([outputEnsemble.DataVariables;outputEnsemble.ConditionVariables;outputEnsemble.IndependentVariables],'stable');
            
            % Gather results into a table.
            outputTable = readall(outputEnsemble);
        end



    end


end

