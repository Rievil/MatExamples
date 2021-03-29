function [NewImage]=RGBLowHighFilter(Original_Picture,trsh,range)
low=trsh;
high=low+range;

if trsh+range>255
    msg = 'Error occurred.';
    error(msg)
return
else if trsh+range<0
    msg = 'Error occurred.';
    error(msg)
return
    end
end

    for RGB=1:1:3
       channel=Original_Picture(:,:,RGB);
       Rozmer=size(channel);
       for x=1:1:Rozmer(1)
            for y=1:1:Rozmer(2)
                if channel(x,y)>high
                    channel(x,y)=high;
                else if channel(x,y)<low
                        channel(x,y)=low;
                    end
                end

            end 
       end
       NewChannel(:,:,RGB)=channel;
    end
NewImage=cat(3, NewChannel(:,:,1), NewChannel(:,:,2), NewChannel(:,:,3));
imshow(NewImage);
end