classdef ReadPundit < handle
    properties (SetAccess = public)       
        SignalProperties;
        Signals;      
        ExpCount;
    end
    
    properties (SetAccess = private)        
        Filename char; %stringová cesta k souboru
        SignalsBool;
    end
    
    properties (Hidden)
        VarNames;
        Samples;
        Idx; 
        Data;
    end
    
    methods (Access = public)
        function obj = ReadPundit(filename)
            obj.Filename=filename;
            
            obj.Data=readtable(filename,'HeaderLines',15,'Delimiter','tab','ReadVariableNames',true);
            obj.VarNames=string(obj.Data.Properties.VariableNames);
            
            HasSignals(obj);

            names=obj.VarNames(1:obj.Idx);
            SignalProperties=obj.Data(:,names);
            %blok kódu který se provede bez rozdílu jestli mám nebo nemám
            %signály
            
            
            %result
            ResultSTR=string(SignalProperties.Result);
            ResultSTR2=split(ResultSTR," ");
            Result=str2double(ResultSTR2(:,1));
            SignalProperties.Result=Result;
            obj.Data.Result=Result;
            
            %DateTime
            DateTimeSTR=datetime(SignalProperties.Date_Time,'Locale','de_DE','Format','dd.MM.yyyy hh:mm');
            SignalProperties.Date_Time=DateTimeSTR;
            
            %pokud mám tak pøidám signály
            %SignalProperties=[SignalProperties, obj.Signals];
            
            obj.SignalProperties=SignalProperties;
            RepairTime(obj);
            obj.ExpCount=size(obj.SignalProperties,1);
        end
        
        % Zjisti mi jestli má dané mìøení obsažené signály
        function HasSignals(obj)
            IdxSig=find(obj.VarNames=='Signal___');
            if IdxSig>0
                Signals=double(obj.Data{:,IdxSig:end});
                for i=1:size(Signals,1)
                    obj.Signals{i,1}=Signals(i,:);
                end
                obj.SignalsBool=true; 
                SampleCountStr='SignalSize';
                
                obj.Idx=find(obj.VarNames==SampleCountStr);
                obj.Samples=double(obj.Data{:,obj.Idx});
                
            else
               obj.SignalsBool=false; 
               obj.Idx=find(obj.VarNames=='Comment');
            end
        end
        
        function RepairTime(obj)
            % oprava Time
            romanNum={'i','ii','iii','iv','v','vi','vii','viii','ix'};
            tmpTime=obj.SignalProperties.Time1__s_;
            TimeCol=split(tmpTime,'.');
            clear Time1B TimeB;
            [rs,cs]=size(TimeCol);
            Time1B=zeros(rs,1);
            for i=1:rs
                A=str2double(TimeCol{i,1});
                smallB=lower(TimeCol{i,2});
                if ismember(smallB,romanNum)
                    [idA,idB]=ismember(smallB,romanNum);
                    B=idB;
                else
                    B=str2double(smallB);
                end
                Time1B(i,1)=A+B/10;
            end
            %TimeB=table(Time1B);
            %BigTab=[BigTab, TimeB];
            obj.SignalProperties = addvars(obj.SignalProperties,Time1B,...
                'Before','Time1__s_','NewVariableNames','Time1B');
        end
        
        function Save(obj)
            [filepath,name,ext] = fileparts(obj.Filename);
            File2Save=[filepath '\PunditMatData.mat'];
            Properties=obj.SignalProperties;
            Signals=obj.Signals;
            save(File2Save,'Properties','Signals');
        end
        
        function Load(obj)
            [filepath,name,ext] = fileparts(obj.Filename);
            File2Load=[filepath '\PunditMatData.mat'];
            if isfile(File2Load)
                load(File2Load);
                obj.SignalProperties=Properties;
                obj.Signals=Signals;
            end
        end
    end
end