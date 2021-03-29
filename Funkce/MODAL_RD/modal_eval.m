function [sx,sy]=modal_eval(rada,sloupec)
 % priprava retezce na prikaz prirazeni - jednoduche
 % rada - cislo rady
 % sloupec - cislo sloupce - po trojici
 rady=['ABCDEFGHI'];
 sodezva='RadaAOdezva(:,';
 suder='RadaAUder(:,';
 
 sodezva(5)=rady(rada);
 suder(5)=rady(rada);
 
 sx=['Xhammer=['];
 sy=['Yhammer=['];
 nsl=sloupec*3-3;
 for i=1:3
   sx=[sx suder num2str(nsl+i) '); '];
   sy=[sy sodezva num2str(nsl+i) '); '];
 end % i
 sx(end-1:end)='];';
 sy(end-1:end)='];';
 
%sx='Xhammer=[RadaAOdezva(:,1); RadaAOdezva(:,2); RadaAOdezva(:,3)];';
%sy='Yhammer=[RadaAUder(:,1); RadaAUder(:,2); RadaAUder(:,3)];';

