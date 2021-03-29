function [Vzorek]=NactiVzorek(cesta, name)
    
    fid = fopen([cesta '\' name],'rt');
    C = textscan(fid, '%s %s %s', 'MultipleDelimsAsOne',true, 'HeaderLines',1);
    fclose(fid);

    %name={'Sila','Vzdalenost','Cas'};
    Vzorek=struct();
    Vzorek.Name=strrep(name,'.txt','');
    
    for n=1:length(C)
        tmp=strrep(C{1,n},',','.');
        b=cellfun(@str2num, tmp);
        %tmp2=cell2mat(str2num(tmp));
        D(:,n)=b;
    end

    Vzorek.Sila=D(:,1);
    Vzorek.Vzdalenost=D(:,2);
    Vzorek.Cas=D(:,3);
end