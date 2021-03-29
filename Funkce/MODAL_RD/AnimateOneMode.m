function AnimateOneMode(ModeNum, fn, ModeShapes, AccelPos)
% Animate one mode.
% ModeNum: Index of the mode.
    
% Reorder the sensor locations for plotting so that a continuous, 
% non-intersecting curve is traced around the body of the aircraft.
PlotOrder = [19:-2:11, 1:2:9, 10:-2:2, 12:2:20, 19];
Fwd = PlotOrder(1:10);
Aft = PlotOrder(20:-1:11); 
x = AccelPos(PlotOrder,1);
y = AccelPos(PlotOrder,2);
xAft = AccelPos(Aft,1);
yAft = AccelPos(Aft,2);
xFwd = AccelPos(Fwd,1);
yFwd = AccelPos(Fwd,2);

wn = fn(ModeNum)*2*pi;  % Mode frequency in rad/sec
T = 1/fn(ModeNum);      % Period of modal oscillation
Np  = 2.25;             % Number of periods to simulate
tmax = Np*T;            % Simulate Np periods
Nt = 100;               % Number of time steps for animation
t = linspace(0,tmax,Nt);
ThisMode = ModeShapes(:,ModeNum)/max(abs(ModeShapes(:,ModeNum))); % normalized for plotting
z0 = ThisMode(PlotOrder);
zFwd = ThisMode(Fwd);
zAft = ThisMode(Aft);

clf
col1 = [1 1 1]*0.5;
xx = reshape([[xAft, xFwd]'; NaN(2,10)],[2 20]);
yy = reshape([[yAft, yFwd]'; NaN(2,10)],[2 20]);
plot3(x,y,0*z0,'-', x,y,0*z0,'.', xx(:), yy(:), zeros(40,1),'--',...
   'Color',col1,'LineWidth',1,'MarkerSize',10,'MarkerEdgeColor',col1);
xlabel('x')
ylabel('y')
zlabel('Amplitude')
ht = max(abs(z0));
axis([-100  100  10  40 -ht ht])
view(5,55)
title(sprintf('Mode %d. FN = %s Hz', ModeNum, num2str(fn(ModeNum),4)));

% Animate by updating z-coordinates.  
hold on
col2 = [0.87 0.5 0];
h1 = plot3(x,y,0*z0,'-', x,y,0*z0,'.', xx(:), yy(:), zeros(40,1),'--',...
   'Color',col2,'LineWidth',1,'MarkerSize',10,'MarkerEdgeColor',col2);
h2 = fill3(x,y,0*z0,col2,'FaceAlpha',0.6);
hold off

for k = 1:Nt
   Rot1 = cos(wn*t(k));
   Rot2 = sin(wn*t(k));
   z_t = real(z0)*Rot1 - imag(z0)*Rot2;
   zAft_t = real(zAft)*Rot1 - imag(zAft)*Rot2;
   zFwd_t = real(zFwd)*Rot1 - imag(zFwd)*Rot2;
   zz = reshape([[zAft_t, zFwd_t]'; NaN(2,10)],[2 20]);
   set(h1(1),'ZData',z_t)
   set(h1(2),'ZData',z_t)
   set(h1(3),'ZData',zz(:))
   h2.Vertices(:,3) = z_t;
   pause(0.1)
end

end