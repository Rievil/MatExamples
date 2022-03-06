function out=WalkDirectory(folder)
    files=struct2table(dir(folder));
    files.name=string(files.name);
    files.folder=string(files.folder);
    files.isdir=logical(files.isdir);
    files.date=datetime(files.datenum,'ConvertFrom','datenum');
    files.datenum=[];
    
    files(files.name==".",:)=[];
    files(files.name=="..",:)=[];

    out=files(files.isdir==0,:);

    folders=files(files.isdir==1,:);
    
    for i=1:size(folders,1)
        targetfolder=[char(folders.folder(i)) '\' char(folders.name(i))];
        out=[out; WalkDirectory(targetfolder)];
    end
    
end