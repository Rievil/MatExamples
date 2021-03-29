%nactu promenou 'data' co� je double array a jejich 'popis' co� je nominal
%array
%load Promenne;

%zjistim jake jsou vsechny unikatni kategorie 
%v promene 'popis'
[unq] =unique(popis);  

%upravim si seznam unikatnich kategorii z popisu do horizontalni polohy
%pomoc� znaku ' typu cell array
CatValues=cellstr(unq');

%vytvorim kategorickou promenou popisu s definovan�m po�ad�m
%vytvorim pole p�vodn�ch kategori� a �eknu kter� je kter�
%v tento moment t� m��u p�ejmenovat, p�elo�it a jinak upravit n�zvy v
%CatValues, ale mus�m zachovat po�et a unik�tnost popisu p�vodn�ho 'unq'
%seznam CatValues muzu zkopirovat z promene
%v tomto propade to vypada takto:
%{'Lower layer' 'Slag' '28d' '23' '59d' 'Ref' '4' 'Upper layer' '24'}
B=categorical(popis,unq,CatValues,'Ordinal',true);

%
%vytvorim kategorii popisu s nov� definovan�m po�ad�m, podle toho co chci
%uv�zt jako prvn� zleva doprava, v tomto pripade chci aby napred byla
%spodn� vrstva, pot� typ receptury, sta��, potom druh� receptura a a� pot�
%druh� vrstva; mus�m dodr�et n�zvy ji� vytvo�en� kategorie 'B'
C = reordercats(B,{'Lower layer','Ref','28d','59d','Slag','Upper layer','24','23','4'});


%pretridim svou datouvou sadu beze zmen, ale ziskam indexovani pro
%pretrideni dat v promenne 'idx', popis nyn� p�et��d�n� a ulo�en� v popis2
%pou�iju pro vykresleni boxplotu
[popis2,idx]=sortrows(C);

%pretridim data dle mejho noveho indexovani
data=data(idx(:,1));


%obarveni vybran�ch skupin:
%zjistim unikatni kategorie pouze ve vybran�m popisu druh�ho sloupce, v
%tomto sloupci se mi st��daj� pouze dva typy receptury 'ref' a 'slag'
[unq]=unique(popis(:,2)); 
CatValues=cellstr(unq.');
Bcolor=categorical(popis(:,2),unq,CatValues,'Ordinal',true);

%nyn� u� nemus�m p�et�izovat promenou, protoze to �e��m v p�edch�zej�c�
%kategorick� prom�nn� 'C'; abych ale mohl popsat dle �eho maj� b�t skupiny
%obarven� v grafu mus�m si vytvo�it prom�nnou Bcolor

%kdy� bych nezm�nil indexov�n� Bcolor dle p�edch�zej�c�ho p�et��d�n�
%prom�nn� 'C' skupiny by se mi obarvily dle p�vodn� organizace prom�nn�ch
%'data' a 'popis' proto pou�iju indexov�n� i na 'Bcolor' a vytvo��m 'Bcolor2'
%kter� svou indexac� odpov�d� nov�mu t��d�n� z 'C' ale pou�iju k tomu prvn�
%sloupec
Bcolor2=Bcolor(idx(:,1));
figure(1);

%vytvoreni barev pro jednotlive sady v po�ad� 'Slag' a 'Ref'
col1=[0 0.2 1]; %slag
col2=[1 0.2 0]; %ref
col=[col1;col2];

h=boxplot(data,popis2,'ColorGroup',Bcolor2,'Colors',col,'MedianStyle','line');

%zform�tuji graf dle chuti
set(h,'LineWidth',1.4);
ylabel('Tensile splitting strength \it f_{ct} \rm [MPa]');
grid on;
ylim([3.2 5.2]);
set(gcf,'Position',[200 200 820 390]);
set(findobj(get(h(1), 'parent'), 'type', 'text'), 'fontsize', 10,'FontName','Arial');
set(gca,'LineWidth',1.4,'FontSize',12,'FontName','Arial','XMinorTick','on','TickDir','out');
