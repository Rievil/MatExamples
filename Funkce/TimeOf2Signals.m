function [t,vz,sor]=TimeOf2Signals(time,signal1,signal2,length)
x=time;

for i=1:2
    
    
    y=eval(['signal' num2str(i) ';']);
    arr=y;
    arr=arr.^2;

    normA = arr - min(arr(:));
    normA = normA ./ max(normA(:)); % *
    normA=cumtrapz(normA);
    amptmp(:,i)=normA;
    
    pocetzaznamu(i)=size(x,1);
    
    xtmp=x(1:1:pocetzaznamu*0.03);
    ytmp=normA(1:1:pocetzaznamu*0.03);

    [p,S] = polyfit(xtmp,ytmp,1); 
    [y_fit,delta] = polyval(p,x,S);
    
    poly{i,1}=x;
    poly{i,2}=y_fit;
    
    %prumer(i)=mean(normA);
    s(i)=std(normA);
    clear nvzd prumvzd;
    
    vzdalenost=1;
    
    for k=1:1:pocetzaznamu(i)*0.1
        y=amptmp(k,i);
        yfit=poly{i,2}(k,1);
        
        rozdil(k,i)=abs(y-yfit);
        
        if k==1
           prumer=rozdil(k,i); 
        end
        
        
        
        if k>1 && k<10
            X=[poly{i,1}(k,1),poly{i,2}(k,1);poly{i,1}(k+1,1),poly{i,2}(k+1,1)];
            vzdalenost=pdist(X,'euclidean');
            nvzd(k)=vzdalenost;
        end
        
        if k>10
            prumvzd=sum(nvzd,2)/size(nvzd,2);
        else
            prumvzd=10;
            
        end 
        
        
        if rozdil(k,i)>(prumer+S.normr*.06) | vzdalenost>prumvzd*1.15
            index(i)=k;
            break;
        end

        
        prumer=sum(rozdil(:,i),2)/size(rozdil(:,i),2);
        tmp=vzdalenost;
    end
end

cas1=x(index(1));
cas2=x(index(2));

rozdilcasu=abs(cas2-cas1);
rychlost=length/rozdilcasu;

%vystup

sor=[x(index(1)),signal1(index(1));x(index(2)),signal2(index(2))];
t=rozdilcasu;
vz=rychlost;
end
