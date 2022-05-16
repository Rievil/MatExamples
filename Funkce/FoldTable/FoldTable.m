function sT=FoldTable(inT,namcol,valcols,varargin)
    org=varargin;
%     unqVal=cell;
    com=[];
    varnames=inT.Properties.VariableNames;
    for i=1:numel(namcol)
        unqVal{i}=unique(inT{:,namcol(i)});
        unqValNum{i}=1:1:numel(unqVal{i});
        com=[com, sprintf('unqValNum{%d},',i)];
    end
    com(end)=[];
    result=eval(['combvec(',com,');'])';
    
    sT=table;
    for i=1:size(result,1)
        
        B=inT;
        
        
        for j=1:size(result,2)
            arr=B{:,namcol(j)};
            idx=arr==unqVal{j}(result(i,j));
            B=B(idx,:);
        end
        if size(B,1)>0

            oT=table;
            for i=1:numel(valcols)
                oT=[oT, table({B{:,valcols(i)}},'VariableNames',varnames(valcols(i)))];
            end
            
            rT=[B(1,namcol),oT];
            org2=org;
            while numel(org2)>0
                for k=1:numel(valcols)
                    
                    switch org2{1}
                        case 'none'
                            skip=true;
                        case 'mean'
                            name='Mean';
                            arr=mean(B{:,valcols(k)});
                            skip=false;
                        case 'std'
                            name='Std';
                            arr=std(B{:,valcols(k)});
                            skip=false;
                        case 'modus'
                            name='Modus';
                            arr = mode(B{:,valcols(k)});
                            skip=false;
                        case 'median'
                            name='Median';
                            arr = median(B{:,valcols(k)});
                            skip=false;
                        case 'max'
                            name='Max';
                            arr = max(B{:,valcols(k)});
                            skip=false;
                        case 'min'
                            name='Min';
                            arr = min(B{:,valcols(k)});
                            skip=false;
                    end

                    if ~skip
                        newname=sprintf('%s%s',name,varnames{valcols(k)});
                        ssT=table(arr,'VariableNames',{newname});
                        rT=[rT, ssT];
                    else
                         rT=rT;
                    end
                end            
                org2(1)=[];
            end
            
            sT=[sT; rT];
        end
        
    end
    

    
end