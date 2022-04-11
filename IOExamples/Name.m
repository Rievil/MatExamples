% Pokud chci mít třídy v matlabu, které mají udělat několik neávislých
% operací a mají si stále pamatovat co se v nich 'dělo' (změna proměných),
% tak třída musí dědit obecný odkaz na '< handle', bez toh po každém
classdef Name < handle
    
    properties
    Thickness=1
    NumLayers=1
    end
    
    methods
    
        function out = f1(obj, in)
            %Na vlastní metody třídy lze odkazoat dvojím způsobem
            %Buď volám funkci kde odkaz na třídu je argumentem
            out = f2(obj, f3(obj,in * obj.Thickness));

            %Nebo mohu funkce volat stejně jako properties třídy, kde
            %oddělím objekt tečkou - oba dva postupy se používají
            out = obj.f2(obj.f3(in * obj.Thickness));

        end
    
    end
    
    methods (Access=private, Hidden=true)
    
        function out = f2(obj, in)
            %pokud chci volat vlastní metodu třídy 'Name' musím odkazovat
            %na třídu pomocí argumentu 'obj'
            out = obj.f3(in / obj.NumLayers);
        end
        
        function out = f3(obj,in)
            out = in;
        end
    
    end

    methods (Static)
        %Statické metody - nemusí odkazovat na třídu pomocí argumentu 'obj'
        function out = f4(in)
            out = in;
        end
    end
end