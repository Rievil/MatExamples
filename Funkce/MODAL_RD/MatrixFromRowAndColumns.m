function [mat]=MatrixFromRowAndColumns(Row,Col,Mirror)
    n=0;
    mat=struct();
    s=1;
    for c=1:length(Col) %r=1:length(Row)
        %podínka pro prohození poèítání
        if s==1
            Low=1;
            High=length(Row);
            s=2;
        else
            Low=length(Row);
            High=1;
            s=1;
        end
        
        for r=1:length(Row) %c=1:length(Col)
            n=n+1;
            XSor(n)=Row(r);
            YSor(n)=Col(c);
            point(n)=n;
        end
        %s=s+1;
    end
    mat=struct('nPoint',point,'XSor',XSor,'YSor',YSor,'Mirror',Mirror);
end