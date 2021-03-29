function [xx_principal, yy_principal, angle_t, angle_c] = principalValues(xx, yy, xy)

angle = 0.5*atan(2*xy./(xx-yy));
angle(isnan(angle)) = 0; % eliminate NaN entries

xx_principal = xx.*((cos(angle)).^2) + yy.*((sin(angle)).^2) + xy.*(2*sin(angle).*cos(angle));
yy_principal = xx.*(sin(angle)).^2 + yy.*(cos(angle)).^2 - xy.*(2*sin(angle).*cos(angle));

angle_t = zeros(size(xx_principal));
angle_c = zeros(size(xx_principal));

for i = 1:size(xx_principal,1)
    for j = 1:size(xx_principal,2)
        
        xx_pr_cur = xx_principal(i,j);
        yy_pr_cur = yy_principal(i,j);
        
        if xx_pr_cur >= yy_pr_cur
            if angle(i,j) >= 0
                angle_t(i,j) = 180*angle(i,j)/pi;
                angle_c(i,j) = angle_t(i,j)+90;
            else
                angle_t(i,j) = 180*angle(i,j)/pi+180;
                angle_c(i,j) = angle_t(i,j)-90;
            end
        else
            if angle(i,j) >= 0
                angle_t(i,j) = 180*angle(i,j)/pi+90;
                angle_c(i,j) = angle_t(i,j)-90;
            else
                angle_t(i,j) = 180*angle(i,j)/pi+90;
                angle_c(i,j) = angle_t(i,j)+90;
            end
        end
        
    end
end

