function [PFrate, rateDist] = PFrate( TMap_gauss, GoodOccMap)
%occ map is linear ind
%TMap_gauss is not 

rateDist = TMap_gauss(GoodOccMap);

PFrate = mean(rateDist);

if isnan(PFrate), PFrate = 0; end 

end

