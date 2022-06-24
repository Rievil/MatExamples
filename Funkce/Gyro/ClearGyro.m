function [TF2]=ClearGyro(data)
    TF2=data;
    for j=4:10
        TF2{:,j}=smoothdata(TF2{:,j},'gaussian',10);
    end
    
    TF2.GyX(TF2.GyX< 0.06 & TF2.GyX>-0.06)=0;
    TF2.GyY(TF2.GyY< 0.06 & TF2.GyY>-0.06)=0;
    TF2.GyZ(TF2.GyZ< 0.06 & TF2.GyZ>-0.06)=0;
    %
    
    % TF2.AcZ=TF2.AcZ/maz*9.81;
    % TF2.AcX=(TF2.AcX-max)/(1.5478e+04)*9.81;
    % TF2.AcY=(TF2.AcY-may)/(1.5478e+04)*9.81;
    
    % TF2.AcX=TF2.AcX-max;
    % TF2.AcY=TF2.AcY-may;
    
    TF2.AcZ=TF2.AcZ/16384*9.81;
    TF2.AcX=TF2.AcX/16384*9.81;
    TF2.AcY=TF2.AcY/16384*9.81;
    
    sen=(16.4/2);
    TF2.GyX=TF2.GyX/(32750)*sen;
    
    TF2.GyY=TF2.GyY/(32750)*sen;
    
    TF2.GyZ=TF2.GyZ/(32750)*sen;
    
    [pitch,roll]=GetAngle(TF2);
    TF2=[TF2, table(pitch,roll,'VariableNames',{'pitch','roll'})];
end