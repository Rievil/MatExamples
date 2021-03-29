function[p,index] = linear_section(x,y,n,length_weight)
%n is the length of the window as a fraction of the length of input x and y vectors.
%an increase to length_weight will increase the value of a longer window. 
if nargin<2
    y = x;
    x = 1:length(y);
end
if nargin<3
    n = [0.05,0.12,0.25,0.5,0.75,0.85,0.95];
end
if nargin<4
    length_weight = 4;
end

x = x(:);
y = y(:);

xs = x.^2;
xy = x.*y;

errk = 1e100;

for j = 1:length(n)
    if n(j)<=1
        n(j) = round(length(x)*n(j));
    end
    if n(j)>=length(x) - 2
        n(j) = length(x) - 2;
    end
    n(j) = round(n(j));
    
    
    sx = sum(x(1:n(j)));
    sy = sum(y(1:n(j)));
    sxs = sum(xs(1:n(j)));
    sxy = sum(xy(1:n(j)));
    
    for i = 1:length(x) - n(j) + 1
        if i>1
            sx  = sx - x(i-1) + x(i+n(j)-1);
            sy  = sy - y(i-1) + y(i+n(j)-1);
            sxs = sxs - xs(i-1) + xs(i+n(j)-1);
            sxy = sxy - xy(i-1) + xy(i+n(j)-1);
        end
        
        slope = (n(j)*sxy - sx*sy)/(n(j)*sxs - sx^2);
        yint  = (sy - slope*sx)/n(j);
        
        ind = i:i+n(j)-1;
        
        err = sum((x(ind)*slope - y(ind) + yint).^2)/(n(j).^length_weight);
        
        if err<errk
            errk = err;
            indk = ind;
            slopek = slope;
            yintk = yint;
        end
    end
end
p = [slopek,yintk];
index = indk;
end