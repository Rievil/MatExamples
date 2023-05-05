classdef IERead < handle
    properties
        TimeCol=1;
        SigCol=2;
        SamplingFrequency=192e+3;
        SFSet=false;
        FileTable;
        Format='tiepie';
        Out;
    end

    properties (Hidden)

    end

    methods
        function obj=IERead(varargin)

            if ~isempty(varargin)
                while numel(varargin)>0
                    
                    switch lower(varargin{1})
                        case 'signalcol'
                            obj.SigCol=varargin{2};
                        case 'timecol'
                            obj.TimeCol=varargin{2};
                        case 'samplingfrequency'
                            obj.SamplingFrequency=varargin{2};
                            obj.SFSet=true;
                        case 'filetable'
                            obj.FileTable=varargin{2};
                        case 'inputformat'
                            switch varargin{2}
                                case 'tiepie'
                                    obj.Format='tiepie';
                                otherwise
                            end
                    end
                    varargin(1:2)=[];
                end
            end
        end
    end

    methods (Access = private)
        function SweepTable(obj)
            
            parpool;
            Q = parallel.pool.DataQueue;
            afterEach(Q,@(data) updatePlot);
            f(1:size(obj.FileTable,1)) = parallel.FevalFuture;
            tic;
            h = waitbar(0,'Waiting...');
            for ii=1:numel(f)
                filename=sprintf("%s\\%s",obj.FileTable.folder(ii),obj.FileTable.name(ii));
                f(ii) = parfeval(@obj.ReadFunction,1,filename);
            end
            updateWaitbar = @(~) waitbar(mean({f.State} == "finished"),h);
            updateWaitbarFutures = afterEach(f,updateWaitbar,0);
            afterAll(updateWaitbarFutures,@(~) delete(h),0);
            wait(f);
            toc;
            close(h);

            obj.Out=array2table(fetchOutputs(f),'VariableNames',{'Name','Features'});
        end

        function result=ReadFunction(obj,file)
            switch obj.Format
                case 'tiepie'
                    T=readtable(file,'NumHeaderLines',8,'DecimalSeparator',',');
            end

            y=T(:,obj.SigCol);
            x=T(:,obj.TimeCol);

            if obj.SFSet==false
                obj.SamplingFrequency=1/(x(2)-x(1));
            end

            obj=ExSignal(y,obj.SamplingFrequency,'startmethod','fix','trsh',100,'freqpeaks',1,'fftsource','full',...
                'DeadTimeSeparator',100,'spectrumtype','fft','signalatt',false);
            T=obj.Features;
            
        
            result={file,T};
        end
    end
end
