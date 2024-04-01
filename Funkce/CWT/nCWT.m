classdef nCWT < handle
    properties
        y;
        fs;
        lowfreq;
        highfreq;
        count;
        m;
        f;
    end

    methods
        function obj=nCWT(y,fs,lowfreq,highfreq,count)
            obj.y=y;
            obj.fs=fs;
            obj.lowfreq=lowfreq;
            obj.highfreq=highfreq;
            obj.count=count;
            %fCWT(single(y.'),1,Fs,30e+3,0.5e+6,200,1);
            [B,fyy] = fCWT(single(obj.y.'),5,obj.fs,obj.lowfreq,obj.highfreq,obj.count,1);
            fcwt_tfm_sig = abs(B.');
            obj.m=fcwt_tfm_sig;
            f=fyy;
            
            period=1/obj.fs;
            time=linspace(0,period*numel(obj.y),numel(obj.y))';
            ax=gca;
            image(obj.m,"CDataMapping","scaled","XData",time,"YData",flip(fyy),...
                'Parent',ax);
            ax.YDir='normal';
%             set(ax,'YDir','reverse')
            colormap(jet);
        end
    end
end