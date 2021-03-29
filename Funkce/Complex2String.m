function [strArr]=Complex2String(data)

vel=size(data);
strArr(1:1:vel(1),1)=string();
%blank=cell();
    for j=1:1:vel(2)
        for i=1:1:vel(1)
            if isnan(data(i,j))
                 strArr(i,j)={'NaN'};
            else
                strArr(i,j)=sprintf('%g%+gi', real(data(i,j)), imag(data(i,j)));
            end
        end
    end
end
