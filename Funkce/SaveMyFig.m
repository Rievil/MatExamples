function SaveMyFig(fig,name)
    RemoveWhiteSpacePDF(fig);

    plotfolder=[cd '\Plots\'];
    
    if ~exist(char(plotfolder), 'dir')
       mkdir(char(plotfolder))
    end


    folders{1}=[cd '\Plots\PNG\'];
    folders{2}=[cd '\Plots\PDF\'];
    
    for folder=folders
        if ~exist(char(folder), 'dir')
           mkdir(char(folder))
        end
    end

    print(fig,[char(folders{1}) char(name)],'-r400','-dpng');
    exportgraphics(fig,[char(folders{2}) char(name) '.pdf'], ...
        'Resolution',300,'ContentType','vector');
end