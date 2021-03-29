function [x,y]=Hypotenuse(XMax,YMax,Alpha)
%Funkce pro výpoèet souøadnice vrcholu pravoúhlého trojúhelníka v
%obedlníku, pokud znám úhel trojúhelníka v levém dolním rohu a rozmìry
%obedlníka

OrigAlpha=atan(YMax/XMax); %In radians
NinDegree=deg2rad(90);
DiffUp=NinDegree-OrigAlpha;
Alpha=deg2rad(Alpha);

    if Alpha==deg2rad(45)
        x=XMax;
        y=YMax;
    else
        
        
        if Alpha>deg2rad(45)

            RatioDegree=1-Alpha/NinDegree;
            
            y=YMax;
            x=RatioDegree*XMax;
        else
            %alpha<45°
            FortyFiveDegree=deg2rad(45);
            RatioDegree=Alpha/FortyFiveDegree;
            x=XMax;
            y=RatioDegree*YMax;
        end
    end
    
    
end