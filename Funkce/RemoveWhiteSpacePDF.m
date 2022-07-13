function RemoveWhiteSpacePDF(fig)
    set(fig,'Units','centimeters');
    screenposition = get(gcf,'Position');
    set(fig,...
        'PaperPosition',[0 0 screenposition(3:4)],...
        'PaperSize',[screenposition(3:4)]);
end