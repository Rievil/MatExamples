classdef TrenarPlot < handle
    properties 
        MT table;
        CT table;
        SZ (1,2) double;
        UC string;
        ShapeList;
        xLim;
        yLim;
    end
    properties (Hidden)
        Done=false;
        Height;
    end

    methods
        function obj=TrenarPlot
            load("TrenarTriagnles.mat");
            obj.MT=T;
            obj.MT.("Layer")=string(obj.MT.("Layer"));
            obj.UC="Layer";
            obj.SZ=size(obj.MT);
            obj.MT.Check(:)=false;
            GetFrame(obj);

            LoopTable(obj);
        end
        
        function GetFrame(obj)
            obj.Height=tan(deg2rad(60))*0.50;
            X=[min([obj.MT.("Start X");obj.MT.("End X")]),max([obj.MT.("Start X");obj.MT.("End X")])]';
            Y=[min([obj.MT.("Start Y");obj.MT.("End Y")]),max([obj.MT.("Start Y");obj.MT.("End Y")])]';
            Tl=table(X,Y);
            for ax=["X","Y"]
                for side=["Start","End"]
                    obj.MT.(sprintf("%s %s",side,ax))=obj.MT.(sprintf("%s %s",side,ax))-Tl.(sprintf("%s",ax))(1);
                end
            end

            X=[min([obj.MT.("Start X");obj.MT.("End X")]),max([obj.MT.("Start X");obj.MT.("End X")])]';
            Y=[min([obj.MT.("Start Y");obj.MT.("End Y")]),max([obj.MT.("Start Y");obj.MT.("End Y")])]';
            Tl=table(X,Y);
            for ax=["X","Y"]
                for side=["Start","End"]
                    switch ax
                        case "X"
                            obj.MT.(sprintf("%s %s",side,ax))=obj.MT.(sprintf("%s %s",side,ax))/Tl.(sprintf("%s",ax))(2);
                        case "Y"
                            obj.MT.(sprintf("%s %s",side,ax))=obj.MT.(sprintf("%s %s",side,ax))/Tl.(sprintf("%s",ax))(2);
                            obj.MT.(sprintf("%s %s",side,ax))=obj.MT.(sprintf("%s %s",side,ax))*obj.Height;
                    end
                            
                end
            end

            obj.xLim=[min([obj.MT.("Start X");obj.MT.("End X")]),max([obj.MT.("Start X");obj.MT.("End X")])];
            obj.yLim=[min([obj.MT.("Start Y");obj.MT.("End Y")]),max([obj.MT.("Start Y");obj.MT.("End Y")])];
        end

        function LoopTable(obj)
            unqval=string(unique(obj.MT.(obj.UC)));
            for i=1:numel(unqval)
                Ti=obj.MT(obj.MT.(obj.UC)==unqval(i),:);
                if i==5
                    obj2=CadShape(Ti);
                else
                    obj2=CadShape(Ti);
                end
                obj.ShapeList{end+1}=obj2;
            end
            obj.Done=true;
        end

        function AddPoints(obj,x,y)
            for i=1:numel(obj.ShapeList)
                sh=obj.ShapeList{i};
                sh.AddPoints(x,y);
            end
        end

        function fig=plot(obj)
            if obj.Done
                fig=figure('position',[80,80,500,500]);
                t=tiledlayout(1,1,'TileSpacing','none','Padding','none');
                nexttile;
                hold on;
                
                ax=gca;
                set(gca,'TickLabelInterpreter','latex');
                axis equal;
                lh=[];
                han=[];
                h1=[];
                pointcount=0;
                shapecol=parula(numel(obj.ShapeList));
                shapelabels=strings(numel(obj.ShapeList),1);
                for i=1:numel(obj.ShapeList)
                    sh=obj.ShapeList{i};
                    h=plot(sh.Polygon,'DisplayName',string(i));
                    shapelabels(i)=string(i);
                    h1(end+1)=h;
%                     [xs,ys] = centroid(sh.Polygon);
                    h.LineStyle='-';
                    h.EdgeColor ='k';
                    h.FaceColor=shapecol(i,:);
                    lh(end+1)=h;
%                     text(xs,ys,string(i));
                    if sh.PCount>0
                        pointcount=pointcount+1;
                        x=sh.Points.x;
                        y=sh.Points.y;
                        color=h.FaceColor*0.9;
                        han(end+1)=scatter(x,y,20,'o','filled','MarkerFaceColor',color,'MarkerEdgeColor','none',...
                            'DisplayName',sprintf("%d",i));
                        
                    end
                    %                     h.FaceColor ='#4DBEEE';
                end

                if pointcount>0
                    lgd=legend(han,'Location','northwest','NumColumns',1,'Interpreter','latex');
                    title(lgd,'Mixtures','Interpreter','latex');
                end
                cbr=colorbar('ticklabels',shapelabels,'TickLabelInterpreter','latex');
                % colormap(shapecol);
                % cbr=legend(h1,'Interpreter','latex','Location','northeast');
                set(get(cbr,'Label'),'String','Phazes','interpreter','latex');
                % cbr.Title.String='Phazes';

                set(get(ax,'YAxis'),'Color','none');
                set(get(ax,'XAxis'),'Color','none');
                xlim([-0.2,1.2]);
                ylim([-0.2,obj.Height+0.2]);

                text(0.5,obj.Height+0.1,sprintf("$H_{2}O$"),'HorizontalAlignment','center',...
                    'HandleVisibility','off','Interpreter','latex');
                text(-0.1,-0.1,sprintf("$Na_{2}O$"),'HorizontalAlignment','center',...
                    'HandleVisibility','off','Interpreter','latex');
                text(1.1,-0.1,sprintf("$SiO_{2}$"),'HorizontalAlignment','center',...
                    'HandleVisibility','off','Interpreter','latex');

                x=[0,0.5,1,0];
                y=[0,obj.Height,0,0];
                plot(x,y,'-k','LineWidth',1.2,'HandleVisibility','off');

                tickLength=0.02;
                yb=cos(deg2rad(60))*tickLength;
                xa=sin(deg2rad(60))*tickLength;
                for i=1:3
                    xi=linspace(x(i),x(i+1),11)';
                    yi=linspace(y(i),y(i+1),11)';
                    for j=1:numel(xi)
                        

                        switch i
                            case 1
                                dy=+yb;
                                dx=-xa;
                            case 2
                                dy=+yb;
                                dx=+xa;
                            case 3
                                dy=-xa;
                                dx=0;
                        end
                        xii=[xi(j),xi(j)+dx];
                        yii=[yi(j),yi(j)+dy];
                        plot(xii,yii,'-k','HandleVisibility','off');
                        text(xii(2)+dx,yii(2)+dy,string(11-j),'HorizontalAlignment','center','HandleVisibility','off',...
                            'Interpreter','latex');
                    end
                end
            end
        end
    end


end