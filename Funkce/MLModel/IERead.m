classdef IERead < handle
    properties
        TimeCol=1;
        SigCol=2;
        HamCol=3;
        SamplingFrequency=192e+3;
        SFSet=false;
        FileTable;
        Format='tiepie';
        ReadType=2;
        Out;
        Tasks;
        SignalTable;
        Features;
    end

    properties (Hidden)
        HasFileTable=false;
        FilesRead=false;
        HasHammer=false;
        SigCount=0;
    end

    methods
        function obj=IERead(varargin)

            if ~isempty(varargin)
                while numel(varargin)>0
                    
                    switch lower(varargin{1})
                        case 'sigcol'
                            obj.SigCol=varargin{2};
                        case 'timecol'
                            obj.TimeCol=varargin{2};
                        case 'hamcol'
                            obj.HamCol=varargin{2};
                            obj.HasHammer=true;
                        case 'samplingfrequency'
                            obj.SamplingFrequency=varargin{2};
                            obj.SFSet=true;
                        case 'filetable'
                            obj.FileTable=varargin{2};
                            obj.HasFileTable=true;
                        case 'signaltable'
                            obj.SignalTable=varargin{2};
                            obj.FilesRead=true;
                        case 'inputformat'
                            switch varargin{2}
                                case 'tiepie'
                                    obj.Format='tiepie';
                                otherwise
                            end
                        case 'readfun'
                            obj.ReadType=varargin{2};
                    end
                    varargin(1:2)=[];
                end
            end


        end

        function Run(obj)
            
            if ~obj.FilesRead
                TO=table;
                h = waitbar(0,'Waiting...');
                for row=1:size(obj.FileTable,1)
                    file=sprintf("%s\\%s",obj.FileTable.folder(row),obj.FileTable.name(row));
                    TS=readtable(file,'NumHeaderLines',8,'DecimalSeparator','.');
    
                    TS.Properties.VariableNames(obj.TimeCol)="Time";
                    if obj.HasHammer
                        TS.Properties.VariableNames(obj.HamCol)="Hammer";
                    end
                    TS.Properties.VariableNames(obj.SigCol)="Signal";
    
                    TO=[TO; table({TS},'VariableNames',["Signals"])];
                    waitbar(row/size(obj.FileTable,1),h,sprintf("Reading %d//%d signals",row,size(obj.FileTable,1)));
                end
                delete(h);
                obj.FilesRead=true;
                obj.SignalTable=TO;
            end

            obj.SigCount=size(obj.SignalTable,1);
            obj.SweepTable;
            StackResult(obj);
        end

        function FT=StackResult(obj)
            cols=obj.Out.Features{find(obj.Out.Success==1,1,'first')}.Properties.VariableNames;
            sz=numel(cols);
            T0=array2table(nan(1,sz),'VariableNames',cols);
            
            TF=table;
            for i=1:size(obj.Out,1)
                try
                    if obj.Out.Success(i)==true
                        TF=[TF; obj.Out.Features{i}];
                    else
                        TF=[TF; T0];
                    end
                catch
                    TF=[TF; T0];
                end
            end

            if obj.HasFileTable==true
                FT=[obj.FileTable,obj.SignalTable,obj.Out(:,"Success"),TF];
            else
                FT=[obj.SignalTable,obj.Out(:,"Success"),TF];
            end
            obj.Features=FT;
        end
    end

    methods (Access = private)
        function SweepTable(obj)
            
            p = gcp('nocreate');
            if isempty(p)
                % There is no parallel pool
                poolsize = 0;
                parpool('Processes');
            else
                % There is a parallel pool of <p.NumWorkers> workers
                poolsize = p.NumWorkers;
            end
            
            signalcolCanmes=["Signal","Signals","Item","Items"];
            colNames=string(obj.SignalTable.Properties.VariableNames);
            A=find(matches(colNames,signalcolCanmes,'IgnoreCase',false));
            % typer=
            

            Q = parallel.pool.DataQueue;
            afterEach(Q,@(data) updatePlot);
            f(1:obj.SigCount) = parallel.FevalFuture;
            tic;
            h = waitbar(0,'Waiting...');

            feset=ExSignal.GetFeset;
            feset.MinPeakProminence=5e-10;
            feset.MinPeakDistance=40;
            feset.MinPeakWidth=10;
            feset.MinPeakHeight=1e-11;

            for ii=1:obj.SigCount
                switch obj.ReadType
                    case 1
                        signal=obj.SignalTable.(colNames(A)){ii};


                        f(ii) = parfeval(@IERead.ReadFunction,1,signal);
                    case 2
                        file=sprintf("%s\\%s",obj.FileTable.folder(ii),obj.FileTable.name(ii));
                        f(ii) = parfeval(@IERead.ReadFunction2,3,file,obj.SigCol,obj.TimeCol);
                    case 3
                        signal=obj.SignalTable.(colNames(A)){ii};
                        colnames=signal.Properties.VariableNames;
                        colnames2=string(colnames);
                        % idT=find(intersect(colnames,obj.TimeCol));
                        if isnumeric(obj.SigCol)
                            idS=obj.SigCol;
                        else
                            idS=colnames2==obj.SigCol;
                        end
                        signal.Properties.VariableNames{idS}='Signal';
                        f(ii) = parfeval(@IERead.ReadFunction3,1,signal);
                    case 4
                        signal=obj.SignalTable.(colNames(A)){ii};
                        f(ii) = parfeval(@IERead.ReadFunction4,1,signal,obj.SigCol,obj.TimeCol);
                    case 5
                        signal=obj.SignalTable.(colNames(A)){ii};
                        f(ii) = parfeval(@IERead.ReadFunction5,1,signal,obj.SamplingFrequency);
                end
            end
            updateWaitbar = @(~) waitbar(mean({f.State} == "finished"),h);
            updateWaitbarFutures = afterEach(f,updateWaitbar,0);
            afterAll(updateWaitbarFutures,@(~) delete(h),0);
            wait(f);
            toc;

            delete(h);
            obj.Tasks=f;
            obj.Out=array2table(fetchOutputs(f),'VariableNames',{'Features','Success'});
            obj.Out.('Success')=logical(cell2mat(obj.Out.('Success')));
        end
        
        
        


    end

    methods (Static)
        function result=ReadFunction(signal)

            y=signal.Signal(:);
            y2=signal.Hammer(:);
            x=signal.Time(:);


            freq=1/(x(2)-x(1));

            obj=ExSignal(y,freq,'startmethod','fix','trsh',0.06,'freqpeaks',1,'fftsource','full',...
     'DeadTimeSeparator',0.005,'spectrumtype','frf','signalatt',false,'hammer',y2,...
     'freqwindow',[0,1e+3],'domsig',false);

            T=obj.Features;

            result={T,obj.Success};
            delete(obj);
        end

        function result=ReadFunction2(file,col,sig)
            TS=readtable(file,'NumHeaderLines',8,'DecimalSeparator','.');
    
            TS.Properties.VariableNames(col)="Time";
            TS.Properties.VariableNames(sig)="Signal";

            y=TS.Amp(:);
            x=TS.Time(:);

            freq=1/(x(2)-x(1));

            obj=ExSignal(y,freq,'startmethod','fix','trsh',0.05,'freqpeaks',1,'fftsource','full',...
                 'DeadTimeSeparator',100,'spectrumtype','fft','signalatt',false);
            T=obj.Features;

            result={T,obj.Success};
            delete(obj);
            
            clear TS obj;
        end

        function result=ReadFunction3(signal)
            y=signal.Signal(:);

            x=signal.Time(:);
            
            if strcmp(class(x),'duration')
                x=seconds(x);
            end

            freq=1/(x(2)-x(1));

            obj=ExSignal(y,freq,'startmethod','fix','trsh',0.05,'freqpeaks',1,'fftsource','full',...
                 'DeadTimeSeparator',100,'spectrumtype','fft','signalatt',false);
            T=obj.Features;

            result={T,obj.Success};
            delete(obj);
            
            clear TS obj;
        end

        function result=ReadFunction4(signal,sigcol,timecol)
            y=signal.(sigcol)(:);

            x=seconds(signal.(timecol)(:));

            freq=1/(x(2)-x(1));

            obj=ExSignal(y,freq,'startmethod','fix','trsh',0.002,'freqpeaks',1,'fftsource','full',...
                 'DeadTimeSeparator',0.1,'spectrumtype','power','signalatt',false);
            T=obj.Features;

            result={T,obj.Success};
            delete(obj);
            
            clear TS obj;
        end

        function result=ReadFunction5(signal,fs)
            y=signal;
            freq=fs;
            period=1/freq;
            duration=numel(y)*period;
            x=linspace(0,duration,numel(y));
            % x=seconds(signal.(timecol)(:));

            

            obj=ExSignal(y,freq,'startmethod','fix','trsh',0.002,'freqpeaks',1,'fftsource','full',...
                 'DeadTimeSeparator',0.1,'spectrumtype','power','signalatt',false,...
                 'powerrange',10);
            T=obj.Features;

            result={T,obj.Success};
            delete(obj);
            
            clear TS obj;
        end
    end
end
