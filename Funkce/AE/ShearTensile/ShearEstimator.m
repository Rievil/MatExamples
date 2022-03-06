classdef ShearEstimator < handle    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Parent;
        RAVal;
        AvgFreqVal;
        Loc;
        TLoc;
        MidleType;
        Alpha;
        Beta;
    end

    methods
        function obj = ShearEstimator(parent)
            obj.Parent=parent;
            obj.MidleType='mean';
        end

        function SetValues(obj,raval,avgfreqval,loc)
            obj.RAVal=raval;
            obj.AvgFreqVal=avgfreqval;
            obj.Loc=loc;
        end
    end

    methods (Access=private)
        function CountLoc(obj)
            if numel(obj.TLoc)>0
                switch lower(obj.MidleType)
                    case 'mean'
                        obj.TLoc=obj.Loc-mean(obj.Loc);
                end
            end
        end

        
    end
end