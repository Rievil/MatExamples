function ChangeMinus(fig,exps)
    set(groot,'defaultAxesTickLabelInterpreter','latex'); 
    fch=fig.Children';
    ax=fig.CurrentAxes;
    minusOld='-';
    minusTarget='-';
	
    if strcmp(class(fch),'matlab.graphics.layout.TiledChartLayout')
        fch=fch.Children';
    end
    for ch=fch
%         disp(class(ch));
        switch lower(class(ch))
            case 'matlab.graphics.axis.axes'
                i=0;

                for n=["X","Y","Z"]
                    i=i+1;
                    vals=ch.(sprintf("%sTick",n));
                    axn=ch.(sprintf("%sAxis",n));

                    exponent=axn.Exponent;
                    if exponent~=0
                        vals=vals/power(10,exps(i));
                    end                    
%                     floor(min(vals));
                    naxlab=string(vals);
                    naxlab=replace(naxlab,minusOld,minusTarget);
                    ch.(sprintf("%sTickLabel",n))=naxlab;
                    lab=get(ch,sprintf("%sLabel",n));
                    labstr=lab.String;
                    
                    if exps(i)~=0
                        labstr=sprintf("%s \\times10^{%d}",labstr,exps(i));
                    end   
                    labstr=replace(labstr,minusOld,minusTarget);
                    eval(lower(sprintf("%slabel(ch,labstr);",n)));
                end
%                 set(ch,'FontName','Palatino linotype');

            case 'matlab.graphics.illustration.colorbar'
                ch.Label.String=replace(ch.Label.String,minusOld,minusTarget);
                %ch
                naclab=string(ch.Ticks);
                naclab=replace(naclab,minusOld,minusTarget);
                ch.TickLabels=string(naclab);
        end
    end
end