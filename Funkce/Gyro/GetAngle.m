function [pitch,roll]=GetAngle(gyrodata)

    TA=gyrodata;

    x=TA.AcX;
    y=TA.AcY;
    z=TA.AcZ;
    
    pitch=zeros(numel(x),1);
    roll=zeros(numel(x),1);
    for i=1:numel(x)
        if x(i)>0 && z(i)>0
            roll(i,1)=atan(x(i)/z(i))*57.2957795;
        elseif x(i)<0 && z(i)>0
            roll(i,1)=atan(x(i)/z(i))*57.2957795+360;
        elseif x(i)<0 && z(i)<0
            roll(i,1)=atan(x(i)/z(i))*57.2957795+180;
        elseif x(i)>0 && z(i)<0
            roll(i,1)=atan(x(i)/z(i))*57.2957795+180;
        end
    end
    pitch=asin(y./9.81)*57.2957795;
end