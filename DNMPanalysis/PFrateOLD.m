function [PFrate, GoodPFpixels, rateDist] = PFrateOLD( PFpixels, TMap_gauss, GoodOccMap)
%occ map is linear ind
%PFpixels is linear ind
%TMap_gauss is not

GoodPFpixels = PFpixels(ismember(PFpixels, GoodOccMap));

rateDist = TMap_gauss(GoodPFpixels);

PFrate = mean(rateDist);

end

