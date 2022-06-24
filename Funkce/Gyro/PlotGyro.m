function Fig=PlotGyro(data)
    TF2=data;
    %
    [TF2]=ClearGyro(data);
    %
    
    Fig=figure;
    
    xo=TF2.Time;
    x=second(TF2.Time);
    x=x-x(1);
    freq=1/((x(end)-x(1))/numel(x));
    subplot(2,1,1);
    hold on;
    y1=smoothdata(TF2.AcX,'gaussian',20);
    y2=smoothdata(TF2.AcY,'gaussian',20);
    y3=smoothdata(TF2.AcZ,'gaussian',20);
    
    plot(xo,TF2.AcX,'-','DisplayName','Acx');
    plot(xo,TF2.AcY,'-','DisplayName','AcY');
    plot(xo,TF2.AcZ,'-','DisplayName','AcZ');
    scatter(xo(logical(TF2.B)),TF2.AcZ(logical(TF2.B)),'DisplayName','GyZ');
    legend;
    
    subplot(2,1,2);
    hold on;
    
    yi1=smoothdata(TF2.GyX,'gaussian',20);
    yi2=smoothdata(TF2.GyY,'gaussian',20);
    yi3=smoothdata(TF2.GyZ,'gaussian',20);
    
    plot(xo,TF2.GyX,'DisplayName','GyX');
    plot(xo,TF2.GyY,'DisplayName','GyY');
    plot(xo,TF2.GyZ,'DisplayName','GyZ');
    scatter(xo(logical(TF2.B)),TF2.GyZ(logical(TF2.B)),'Filled','DisplayName','Meas');
    legend;
end