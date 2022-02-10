function out=IELocal(data, signalcol, typecol)
    arguments
            data table
            signalcol double
            typecol double
    end
    T=data;
    colanmes=string(T.Properties.VariableNames);
    freqdim=[50,20e+3];
    
    AllSpec=table;
    outparam=table;
    wavetype=["Flexural","Torsional","Longitudinal"];
    wavetypesymbol=["f","t","l"];
    
    for i=1:3
        T2=T(T.(colanmes(typecol))==wavetypesymbol(i),:);
        freq=1/(seconds(T2.(colanmes(signalcol)){1}.Time(2)-T2.(colanmes(signalcol)){1}.Time(1)));
        [f,y]=MyFFT(T2.(colanmes(signalcol)){1}.Amplitude,freq);
        spec=table(f,y,'VariableNames',{'Freq','Amp'});
        spec=spec(spec.Freq>freqdim(1) & spec.Freq<freqdim(2),:);
      
        switch wavetypesymbol(i)
            case 'f'
    
            case 't'
                filter=AllSpec.Param{AllSpec.WaveType==wavetype(1)}.Filter;
                spec.Amp(spec.Freq>filter(1) & spec.Freq<filter(2))=0;
    
            case 'l'
                filter=[AllSpec.Param{AllSpec.WaveType==wavetype(1)}.Filter;
                    AllSpec.Param{AllSpec.WaveType==wavetype(2)}.Filter];
    
                spec.Amp(spec.Freq>min(filter(1,:)) & spec.Freq<max(filter(2,:)))=0;
            otherwise
        end
            
        spec.Amp=spec.Amp-min(spec.Amp);
        spec.Amp=spec.Amp/max(spec.Amp);
    
        [pks,locs,w,p]=findpeaks(spec.Amp,spec.Freq,'MinPeakProminence',.2,'Annotate','extents','WidthReference','halfheight');
        w=w;
        filter=[locs-w,locs+w];
        param=table(pks,locs,w,p,filter,'VariableNames',{'Amplitude','Frequency','With','Prominence','Filter'});
        param=sortrows(param,'Amplitude','descend');
        
        outparam=[outparam; table(wavetypesymbol(i),'VariableNames',{char(colanmes(typecol))}), param(1,:)];
        AllSpec=[AllSpec; table({spec},{param(1,:)},string(wavetype(i)),wavetypesymbol(i),'VariableNames',{'Spectrum','Param','WaveType','Symbol'})];
        
        
    end
    out = join(data,outparam,'Keys',colanmes(typecol));

end