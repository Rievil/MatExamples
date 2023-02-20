function SaveMyFig(fig,name,varargin)
    RemoveWhiteSpacePDF(fig);

    plotfolder=[cd '\Plots\'];
    
    if ~exist(char(plotfolder), 'dir')
       mkdir(char(plotfolder))
    end


    folders{1}=[cd '\Plots\PNG\'];
    folders{2}=[cd '\Plots\PDF\'];
    folders{3}=[cd '\Plots\SVG\'];
    
    for folder=folders
        if ~exist(char(folder), 'dir')
           mkdir(char(folder))
        end
    end

    
    
    if numel(varargin)>0
        while(numel(varargin))>0
            switch lower(varargin{1})
                case 'format'
                    formats=string(varargin{2});
            end
            varargin(1:2)=[];
        end
    else
        formats=["png","pdf","svg"];
    end

    for i=1:numel(formats)
        switch formats(i)
            case "png"
                print(fig,[char(folders{1}) char(name)],'-r300','-dpng');
            case "svg"
                    print(fig,[char(folders{3}) char(name)],'-r400','-dsvg');
            case "pdf"
                    exportgraphics(fig,[char(folders{2}) char(name) '.pdf'], ...
                    'Resolution',300,'ContentType','vector');
        end
    end
end