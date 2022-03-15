function imgs=SplitImage(img,tarcount)
    Xs=size(img,2);
    Ys=size(img,1);

    switch tarcount
        case 1
            dx=1;
            dy=1;
        case 2
            dx=2;
            dy=1;
        case 4
            dx=2;
            dy=2;
        case 8
            dx=4;
            dy=2;
        case 16
            dx=4;
            dy=4;
        case 32
            dx=8;
            dy=4;
    end

    count=dx*dy;
    
    Xsi=int32(Xs/dx);
    Ysi=int32(Ys/dy);

    n=0;
    img2=cell(tarcount);
    for i=1:dx
        for j=1:dy
            n=n+1;
            dim=[Xsi*(i-1),Ysi*(j-1),Xsi,Ysi];
            nexttile;
            img2{n}=imcrop(img,dim);
%             imshow(img2);
        end
    end
end