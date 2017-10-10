function [TMap_zscore] = ZScoreLinPFs(TMap, zeronans)
%This function loads a tmap, organized as cell x condition x day, and
%returns a cell array of the same organization which zscores the firing 
%rates in each bin across conditions for each cell 

%{
if ~exist('whichTmap','var')
    whichTmap = 'TMap_gauss'; %'TMap_unsmoothed'
end

TLoad = load(fullfile(PFsLin_dir,'PFsLin.mat'),whichTmap);
TMap = TLoad.(whichTmap);
clear TLoad
%}

numCells = size(TMap,1);
numConds = size(TMap,2);
numDays = size(TMap,3);

TMap_zscore = cell(size(TMap));

for dayI = 1:numDays
    for cellI = 1:numCells
        theseFields = TMap(cellI,:,dayI);
        condArrSize = cellfun(@length,theseFields);%,'UniformOutput',false);
        condArrSize = [0 condArrSize];
        %zscore doesn't automatically handle nans
        allRateBins = [theseFields{:}];

        %This step is to make it easier to index later steps
        if zeronans == 1
            zeroThese = isnan(allRateBins);
        elseif zeronans == 0 
            zeroThese = zeros(size(allRateBins));
        end

        allRateBins(zeroThese) = 0;
        
        %zRates = nan(size(allRateBins));
        %zRates(~zeroThese) = zscore(allRateBins(~zeroThese));
        zRates = zeros(size(allRateBins));
        zRates = zscore(allRateBins);
        
        for condI = 1:numConds
            TMap_zscore{cellI,condI,dayI} =...
                zRates((sum(condArrSize(1:condI))+1):sum(condArrSize(1:condI+1)));
        end
    end
end


end