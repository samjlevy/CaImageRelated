function [trialNormalizedCoactivity] = findingEnsemblesNotes2(trialbytrial,dayOrNum)

% use dayornum to choose between sessNumber or sessID

numConds = length(trialbytrial);
sessHere = unique(trialbytrial(1).sessID);
numSess = length(sessHere);

%sessNumsHere = unique(trialbytrial(1).sessNumber);
%numSesses = unique(sessNumsHere);

numCells = size(trialbytrial(1).trialPSAbool{1},1);

for condI = 1:numConds
    
    for sessJ = 1:length(sessHere)
        sessI = sessHere(sessJ);
        trialsHere = (trialbytrial(condI).sessID == sessI);
        numTrials = sum(trialsHere);
        
        cellFiresAtAll = cellfun(@(x) sum(x,2)>0,[trialbytrial(condI).trialPSAbool(trialsHere)],'UniformOutput',false);
        
        cellsCoactive = zeros(numCells,numCells);
        for trialI = 1:numTrials
            cellsCoactiveHere = cellFiresAtAll{trialI}(:) & cellFiresAtAll{trialI}(:)';
            cellsCoactive = cellsCoactive + cellsCoactiveHere;
        end
        I = logical(eye(numCells));
        numTrialsActive = cellsCoactive(I);
        
        cellsCoactive(I) = 0;
        
        trialNormalizedCoactivity{condI}{sessJ} = cellsCoactive ./ repmat(numTrialsActive(:),1,numCells);
        
        trialNormalizedCoactivity{condI}{sessJ}(isnan(trialNormalizedCoactivity{condI}{sessJ})) = 0;
    end
end

end