classdef ImDataset < handle
    properties
        Data;
        VarNames;
        ClassColName='Class';
        TargetFolder;
        Method='ImageClass';
        Classes;
        ClassNum;
        FactClasses;
        ValRatio=0.3;
        TestRatio=0.05;
        DatasetName='IEDataset';
        OutShape=[544,672];
        Resize=false;
        SplitFun;
        MakeFun;
        plot;
    end

    properties (Hidden)
        AlreadySplit=false;
        HasTargetFolder=false;
    end

    properties (Dependent)
        TrainRatio;
    end

    methods
        function val=get.TrainRatio(obj)
            val=1-obj.ValRatio-obj.TestRatio;
        end

        function obj=ImDataset(T,varargin)
            arguments 
                T table;
            end
            arguments (Repeating)
                varargin;
            end
            obj.Data=T;
            
            while numel(varargin)>0
                switch lower(varargin{1})
                    case 'classcol'
                        obj.ClassColName=varargin{2};
                        varargin([1,2])=[];
                    case 'targetfolder'
                        obj.TargetFolder=varargin{2};
                        varargin([1,2])=[];
                        obj.HasTargetFolder=true;
                    case 'method'
                        obj.Method=varargin{2};
                        varargin([1,2])=[];
                    case 'datasetname'
                        obj.DatasetName=varargin{2};
                        varargin([1,2])=[];
                    case 'valratio'
                        obj.ValRatio=varargin{2};
                        varargin([1,2])=[];
                    case 'testratio'
                        obj.TestRatio=varargin{2};
                        varargin([1,2])=[];
                    case 'outshape'
                        obj.OutShape=varargin{2};
                        
                        varargin([1,2])=[];
                        obj.Resize=true;
                end
            end
            obj.Data.(obj.ClassColName)=string(obj.Data.(obj.ClassColName));
            
            unqval=unique(obj.Data.(obj.ClassColName));
            obj.Classes=unqval;
            obj.ClassNum=numel(unqval);
            valset=string(1:numel(unqval));
            obj.FactClasses=double(categorical(obj.Data.(obj.ClassColName),obj.Classes',valset,'Ordinal',true));
            obj.Data.Training(:)="";
        end

        function Run(obj)

            % split(obj);
            switch lower(obj.Method)
                case 'imageclass'
                    obj.SplitFun=@obj.splitImClass;
                    obj.MakeFun=@obj.makeImClass;
                    obj.plot=@obj.plotImClass;

                    obj.splitImClass;
                    obj.makeImClass;
                case 'pixelclass'
                otherwise

                    
            end

        end

        function split(obj)
            switch lower(obj.Method)
                case 'imageclass'
                    splitImClass(obj);
            end
        end

        function splitImClass(obj)
            classes=obj.Classes;
            obj.Data.Training(:)="train";
            for i=1:size(classes)
                classidx=find(obj.Data.(obj.ClassColName)==classes(i));
            
                validx=randperm(numel(classidx),int64(numel(classidx)*obj.ValRatio));
                obj.Data.Training(classidx(validx))="val";
                
                if obj.TestRatio>0
                    classidx(validx)=[];
                    testidx=randperm(numel(classidx),int64(numel(classidx)*obj.TestRatio));
                    obj.Data.Training(classidx(testidx))="test";
                end
            end
            obj.AlreadySplit=true;
        end

        function fig=plotImClass(obj)
            if ~obj.AlreadySplit
                obj.splitImClass;
            end

            fig=figure;
            hold on;
            histogram(categorical(obj.Data.(obj.ClassColName)(obj.Data.Training=="train")),'DisplayName','Train');
            histogram(categorical(obj.Data.(obj.ClassColName)(obj.Data.Training=="val")),'DisplayName','Validate');
            histogram(categorical(obj.Data.(obj.ClassColName)(obj.Data.Training=="test")),'DisplayName','Test');
            legend;
        end

        function makeImClass(obj)
            if ~obj.AlreadySplit
                obj.splitImClass;
            end
            unqgroups=unique(obj.Data.Training);
            unqgroups=reshape(unqgroups,[1,numel(unqgroups)]);
            for tr=unqgroups
                Ti=obj.Data(obj.Data.Training==tr,:);
                unqclass=unique(Ti.(obj.ClassColName));
                if obj.HasTargetFolder
                    if ~exist(sprintf("%s\\%s\\%s",obj.TargetFolder,obj.DatasetName,tr), 'dir')
                        mkdir(sprintf("%s\\%s\\%s",obj.TargetFolder,obj.DatasetName,tr))
                    end
                else
                    if ~exist(sprintf("IEDataset\\%s",tr), 'dir')
                        mkdir(sprintf("IEDataset\\%s",tr))
                    end
                end
            
                for j=1:numel(unqclass)
                    Tii=Ti(Ti.(obj.ClassColName)==unqclass(j),:);
                    if obj.HasTargetFolder
                        if ~exist(sprintf("%s\\%s\\%s\\%s",obj.TargetFolder,obj.DatasetName,tr,unqclass(j)), 'dir')
                            mkdir(sprintf("%s\\%s\\%s\\%s",obj.TargetFolder,obj.DatasetName,tr,unqclass(j)));
                        end
                    else
                        if ~exist(sprintf("%s\\%s\\%s",obj.DatasetName,tr,unqclass(j)), 'dir')
                            mkdir(sprintf("%s\\%s\\%s",obj.DatasetName,tr,unqclass(j)));
                        end
                    end
                    for k=1:size(Tii,1)
                        orgfile=sprintf("%s\\%s",Tii.folder(k),Tii.name(k));
                        
                        if obj.HasTargetFolder
                            newfile=sprintf("%s\\%s\\%s\\%s\\%s",obj.TargetFolder,obj.DatasetName,tr,Tii.(obj.ClassColName)(k),Tii.name(k));
                        else
                            newfile=sprintf("%s\\%s\\%s\\%s",obj.DatasetName,tr,Tii.Class(k),Tii.name(k));
                        end

                        if obj.Resize
                            img=imread(orgfile);
                            img2=imresize(img,obj.OutShape);
                            imwrite(img2,newfile);
                        else
                            copyfile(orgfile,newfile);
                        end
                    end
                end
            end
        end

    end

    methods (Static)
        function imgs=SplitByRes(I,origSIze)
            sz=size(I(:,:,1));
            
            test=0;
            
            subIsize=origSIze;
            
            n=0;
            while test<0.95
                if n<100
                    subIsize=subIsize+1;
                else
                    if n==100
                        subIsize=origSIze;
                    end
                    subIsize=subIsize-1;
                end
                n=n+1;
                xd=sz(2)/subIsize;
                yd=sz(1)/subIsize;
                
                fx=ceil(xd);
                fy=ceil(yd);
                
                nsizex=sz(2)/fx;
                nsizey=sz(1)/fy;
                if nsizey>nsizex
                    test=nsizex/nsizey;
                else
                    test=nsizey/nsizex;
                end
                
            end
            Xsi=int32(nsizex);
            Ysi=int32(nsizey);
            
            n=0;
            imgs=cell(fx*fy,1);
            for i=1:fx
                for j=1:fy
                    n=n+1;
                    dim=[Xsi*(i-1),Ysi*(j-1),Xsi,Ysi];
                    imgs{n}=imresize(imcrop(I,dim),[origSIze,origSIze]);
                end
            end
        end

    end

end