function [f,y]=MyFFT(Signal,freq)
    Fs = freq;                % Sampling frequency
    T = 1/Fs;                  % Sampling period

    L=length(Signal);
    t = (0:L-1)*T;  
    Y = fft(Signal);

    P2 = abs(Y/L(1));
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
     
    L2=length(P1);
    
    f=zeros(L2,1);
    
    f(:,1)=Fs*(0:(L/2))/L;
    y=P1;
end
