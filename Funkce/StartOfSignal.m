function [result]=StartOfSignal(SignalB)

samples=length(SignalB);
y=abs(SignalB);
NoiseId=round(samples*0.07,0);

noiseMean=mean(y(end-NoiseId:end));
noiseStd=std(y(end-NoiseId:end));

trsh=noiseMean+noiseStd*5;
Idx=find(y>trsh,1,'first');

mfnc = mean(y(1:Idx-5));
sfnc = std(y(1:Idx-5));
[iupper,ilower]=cusum(y,80,5,mfnc,sfnc);

Id=[iupper; ilower];
result=min(Id)-3;

end
