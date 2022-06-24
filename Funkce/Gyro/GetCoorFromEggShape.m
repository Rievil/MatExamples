function anglearr=GetCoorFromEggShape(height)
    a=height; %výška vejce
    xii=linspace(0,a,2000);
    yii=zeros(numel(xii),1);
    for i=1:numel(xii)
        yii(i,1)=power(power(a,0.5)*xii(i)-power(xii(i),1.5),1/2);
    end
    
    xif=[xii'; flip(xii')];
    yif=[yii; flip(yii.*(-1))];
    
    %otočení dle orientace v terénu
    theta=-90;
    R=[cosd(theta) -sind(theta); sind(theta) cosd(theta)];
    coordT=[xif, yif];
    rotcoord=coordT*R';
    
    t=rotcoord(:,1);
    y=rotcoord(:,2);
    
    [M,I]=max(t);
    y=y-y(I);
    
    % plot(t,y);
    
    anglearr=zeros(numel(y),3);
    for i=1:numel(y)-1
        dy=diff(y)./diff(t);
        k=i; % point number 220
        tang=(t-t(k))*dy(k)+y(k);
    %     hold on
        if k<51 || k>numel(t)-51
            red=k-1;
        else
            red=50;
        end
    %     plot(t(k-red:1:k+red),tang(k-red:1:k+red),':o');
    %     scatter(t(k),y(k));
        
        xd=max(t)-min(t);
        yd=max(tang)-min(tang);
        ang=atan(yd/xd)*57.2957795;
        if t(k)>0 && y(k)>0
            ang=ang+180;
        elseif t(k)>0 && y(k)<0
            ang=360-ang;
        elseif t(k)<0 && y(k)<0
            ang=ang;
        elseif t(k)<0 && y(k)>0
            ang=ang+90;
        elseif t(k)==0 && y(k)>0
            ang=180;
        elseif t(k)==0 && y(k)<0
            ang=0;
        else
            ang=0;
        end
        anglearr(i,1)=ang;
        anglearr(i,2)=t(i);
        anglearr(i,3)=y(i);
    end

    anglearr=sort(anglearr,1);
end