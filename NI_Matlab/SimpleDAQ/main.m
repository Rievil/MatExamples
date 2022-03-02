d = daqlist("ni");
%
deviceInfo = d{1, "DeviceInfo"}
%%
dq = daq("ni");
%

addinput(dq, "NICard", "ai0", "Voltage");


%%
data = read(dq,seconds(1),"OutputFormat","Matrix");
%
plot(data)
%%
dq = daq("ni");
dq.Rate = 200000;

	%%
data=startForeground(s);
%%

dq = daq("ni");
dq.Rate = 100000;
addinput(dq, "NICard", "ai0", "Voltage");
addinput(dq, "NICard", "ai2", "Voltage");
%%
tabledata = read(dq,seconds(1));
%%
% could work with IEPE sensor type
noth=y;
%%
tabledata = read(dq,seconds(2));
x=tabledata.Time;
y=tabledata.NICard_ai0-noth;
yi=tabledata.NICard_ai2;
%
figure;
hold on;
plot(x,y);
% plot(x,yi);
