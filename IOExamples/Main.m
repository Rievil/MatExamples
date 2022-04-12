%vytvoření instance třídy 'Name' pojmenované 'a'
a=Name;

% volání Public funkce f1 instance 'a' trídy 'Name', která volá vnitřní privátní funkce f2 a f3
result1=a.f1(1);

%vymazání instance 'a' třídy 'Name'
clear a;

%Volání statické funkce třídy 'Name' - aniž bych musel mít vtvořenou instanci
%třídy; v tomto případě se část paměti rezervované pro funkci po vykonání
%instrukcí opět uvolní a nevznikne tedy instance třídy uložené v paměti,
%zůstane pouze result2
result2=Name.f4(1);
