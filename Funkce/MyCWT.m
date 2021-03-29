function [tmp2,frq]=MyCWT(Signal,fs,time)
%figure(1);
%Signal=Concrete(1).IE(1).signal(1).odezva{1};
%fs=195e+3;
% time=-5;
% if isempty(time)
%     t=time;
% else
%     period=1/fs;
%     len=size(Signal,1);
%     delka=len*period;
%     t=double(period:period:delka);
% end
%
%figure(1);
[cfs,frq] = cwt(Signal,fs);
tmp1 = abs(cfs);
t1 = size(tmp1,2);
tmp1 = tmp1';
minv = min(tmp1);
tmp1 = (tmp1-minv(ones(1,t1),:));
%Find the maximum value at every level of tmp1. For each level, divide every value by the maximum value at that level. Multiply the result by the number of colors in the colormap. Set equal to 1 all zero entries. Transpose the result.

maxv = max(tmp1);
maxvArray = maxv(ones(1,t1),:);
indx = maxvArray<eps;
tmp1 = 240*(tmp1./maxvArray);
tmp2 = 1+fix(tmp1);
tmp2(indx) = 1;
tmp2 = tmp2';
%Display the result. The scalogram values are now scaled by the maximum absolute value at each level. Frequencies are displayed on a linear scale.

%t = 0:length(Signal)-1;

pcolor(time,frq,tmp2);
shading interp;

end
%Zaloha
% 
% 
% %rada casu
% %radasignalu
% %fs=sampling frequency
% 
% Signal=Concrete(1).IE(1).signal(1).odezva{1};
% fs=195e+3;
% 
% period=1/fs;
% 
% len=size(Signal,1);
% delka=len*period;
% time=double(period:period:delka);
% %
% figure(1);
% [cfs,frq] = cwt(Signal,fs);
% tmp1 = abs(cfs);
% t1 = size(tmp1,2);
% tmp1 = tmp1';
% minv = min(tmp1);
% tmp1 = (tmp1-minv(ones(1,t1),:));
% %Find the maximum value at every level of tmp1. For each level, divide every value by the maximum value at that level. Multiply the result by the number of colors in the colormap. Set equal to 1 all zero entries. Transpose the result.
% 
% maxv = max(tmp1);
% maxvArray = maxv(ones(1,t1),:);
% indx = maxvArray<eps;
% tmp1 = 240*(tmp1./maxvArray);
% tmp2 = 1+fix(tmp1);
% tmp2(indx) = 1;
% tmp2 = tmp2';
% %Display the result. The scalogram values are now scaled by the maximum absolute value at each level. Frequencies are displayed on a linear scale.
% 
% t = 0:length(Signal)-1;
% 
% pcolor(time,frq,tmp2);
% shading interp;
% ylabel('Frequency \it f_{L} \rm [Hz]');
% xlabel('Time \it t \rm [s]');
% axis([-2e-3 8e-2 0 1.5e+4]);
% title('Scalogram Scaled By Level');
% colormap(parula);
