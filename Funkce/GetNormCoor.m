function [outx,outy]=GetNormCoor(axes,inx,iny)
    fig=axes.Parent;
    axespos=axes.Position;
    figpos=fig.Position;
    
    minx=axes.XLim(1);
    maxx=axes.XLim(2);
    
    miny=axes.YLim(1);
    maxy=axes.YLim(2);
    
    
    normX = inx - minx;
    normX = normX ./ maxx; % *
    
    normY = iny - miny;
    normY = normY ./ maxy; % *
    
    axminx=axespos(1);
    axmaxx=axespos(3);
    
    axminy=axespos(2);
    axmaxy=axespos(4);
    
    outx = normX - axminx;
    outx = outx ./ axmaxx; % *
    
    outy = normY - axminy;
    outy = outy ./ axmaxy; % *
    
    
%     outx=normX;
%     outy=normY;

end