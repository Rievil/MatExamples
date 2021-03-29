function ReduceWhiteFrame(plusleft,plusbottom,pluswidth,plusheight)

ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 

if isempty(plusleft)
    left = outerpos(1) + ti(1);
else
    left = outerpos(1) + ti(1)+plusleft;
end

if isempty(plusbottom)
    bottom = outerpos(2) + ti(2);
else
    bottom = outerpos(2) + ti(2)+plusbottom;
end

if isempty(pluswidth)
    ax_width = outerpos(3) - ti(1) - ti(3);
else
    ax_width = outerpos(3) - ti(1) - ti(3)+pluswidth;
end

if isempty(plusheight)
    ax_height = outerpos(4) - ti(2) - ti(4);
else
    ax_height = outerpos(4) - ti(2) - ti(4)+plusheight;
end


ax.Position = [left bottom ax_width ax_height];

end