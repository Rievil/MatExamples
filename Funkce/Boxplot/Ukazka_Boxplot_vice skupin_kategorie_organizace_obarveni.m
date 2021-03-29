%nactu promenou 'data' což je double array a jejich 'popis' což je nominal
%array
%load Promenne;

%zjistim jake jsou vsechny unikatni kategorie 
%v promene 'popis'
[unq] =unique(popis);  

%upravim si seznam unikatnich kategorii z popisu do horizontalni polohy
%pomocí znaku ' typu cell array
CatValues=cellstr(unq');

%vytvorim kategorickou promenou popisu s definovaným poøadím
%vytvorim pole pùvodních kategorií a øeknu která je která
%v tento moment též mùžu pøejmenovat, pøeložit a jinak upravit názvy v
%CatValues, ale musím zachovat poèet a unikátnost popisu pùvodního 'unq'
%seznam CatValues muzu zkopirovat z promene
%v tomto propade to vypada takto:
%{'Lower layer' 'Slag' '28d' '23' '59d' 'Ref' '4' 'Upper layer' '24'}
B=categorical(popis,unq,CatValues,'Ordinal',true);

%
%vytvorim kategorii popisu s novì definovaným poøadím, podle toho co chci
%uvézt jako první zleva doprava, v tomto pripade chci aby napred byla
%spodní vrstva, poté typ receptury, staøí, potom druhá receptura a až poté
%druhá vrstva; musím dodržet názvy již vytvoøené kategorie 'B'
C = reordercats(B,{'Lower layer','Ref','28d','59d','Slag','Upper layer','24','23','4'});


%pretridim svou datouvou sadu beze zmen, ale ziskam indexovani pro
%pretrideni dat v promenne 'idx', popis nyní pøetøídìný a uložený v popis2
%použiju pro vykresleni boxplotu
[popis2,idx]=sortrows(C);

%pretridim data dle mejho noveho indexovani
data=data(idx(:,1));


%obarveni vybraných skupin:
%zjistim unikatni kategorie pouze ve vybraném popisu druhého sloupce, v
%tomto sloupci se mi støídají pouze dva typy receptury 'ref' a 'slag'
[unq]=unique(popis(:,2)); 
CatValues=cellstr(unq.');
Bcolor=categorical(popis(:,2),unq,CatValues,'Ordinal',true);

%nyní už nemusím pøetøizovat promenou, protoze to øeším v pøedcházející
%kategorické promìnné 'C'; abych ale mohl popsat dle èeho mají být skupiny
%obarvené v grafu musím si vytvoøit promìnnou Bcolor

%když bych nezmìnil indexování Bcolor dle pøedcházejícího pøetøídìní
%promìnné 'C' skupiny by se mi obarvily dle pùvodní organizace promìnných
%'data' a 'popis' proto použiju indexování i na 'Bcolor' a vytvoøím 'Bcolor2'
%které svou indexací odpovídá novému tøídìní z 'C' ale použiju k tomu první
%sloupec
Bcolor2=Bcolor(idx(:,1));
figure(1);

%vytvoreni barev pro jednotlive sady v poøadí 'Slag' a 'Ref'
col1=[0 0.2 1]; %slag
col2=[1 0.2 0]; %ref
col=[col1;col2];

h=boxplot(data,popis2,'ColorGroup',Bcolor2,'Colors',col,'MedianStyle','line');

%zformátuji graf dle chuti
set(h,'LineWidth',1.4);
ylabel('Tensile splitting strength \it f_{ct} \rm [MPa]');
grid on;
ylim([3.2 5.2]);
set(gcf,'Position',[200 200 820 390]);
set(findobj(get(h(1), 'parent'), 'type', 'text'), 'fontsize', 10,'FontName','Arial');
set(gca,'LineWidth',1.4,'FontSize',12,'FontName','Arial','XMinorTick','on','TickDir','out');
