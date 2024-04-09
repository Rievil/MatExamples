function SaveMyFig(fig,name,varargin)
    arguments
        fig matlab.ui.Figure;
        name string;
    end
    arguments (Repeating)
        varargin;
    end
    hasFolder=false;
    RemoveWhiteSpacePDF(fig);

    dpival=300;
    dpistr='-r300';
    transparent=false;
    if numel(varargin)>0
        while(numel(varargin))>0
        
            switch lower(varargin{1})
                case 'format'
                    formats=string(varargin{2});
                case 'dpi'
                    dpistr=char(sprintf("-r%d",varargin{2}));
                    dpival=varargin{2};
                case 'folder'
                    hasFolder=true;
                    folderOut=char(varargin{2});
                    lastM=find(folderOut=='\');
                    if lastM(end)==numel(folderOut)
                        folderOut=folderOut(1:end-1);
                    end
                case 'transparent'
                    transparent=varargin{2};
            end

            varargin(1:2)=[];
        end
    else
        formats=["png","pdf","svg"];
    end

    % if contains(name,"..")
    %     fo=
    % else
    % end

    if ~hasFolder
        plotfolder=[cd '\Plots\'];
        
        if ~exist(char(plotfolder), 'dir')
           mkdir(char(plotfolder))
        end
    
    
        folders{1}=[cd '\Plots\PNG\'];
        folders{2}=[cd '\Plots\PDF\'];
        folders{3}=[cd '\Plots\SVG\'];
        % folders{4}=[cd '\Plots\EPS\'];
        
        for folder=folders
            if ~exist(char(folder), 'dir')
               mkdir(char(folder))
            end
        end
    else
        folders{1}=[folderOut '\'];
        folders{2}=[folderOut '\'];
        folders{3}=[folderOut '\'];
        % folders{4}=[folderOut '\'];
    end
        


    
    
    
    if transparent
        set(fig,'color', 'none');
    end

    for i=1:numel(formats)
        switch formats(i)
            case "png"
                print(fig,[char(folders{1}) char(name)],dpistr,'-dpng');
            case "svg"
                    print(fig,[char(folders{3}) char(name)],dpistr,'-dsvg');
            case "pdf"
                    exportgraphics(fig,[char(folders{2}) char(name) '.pdf'], ...
                    'Resolution',dpival,'ContentType','vector');
            case "eps"
                print(fig,[char(folders{1}) char(name)],dpistr,'-deps');
        end
    end
end