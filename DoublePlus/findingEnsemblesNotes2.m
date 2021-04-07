function [trialNormalizedCoactivity,numTrialsActive,pctTrialsActive] = findingEnsemblesNotes2(trialbytrial,condPairs)

% use dayornum to choose between sessNumber or sessID

numConds = length(trialbytrial);
if isempty(condPairs)
    condPairs = [1:numConds]';
end
numCondPairs = size(condPairs,1);
sessHere = unique(trialbytrial(1).sessID);
numSess = length(sessHere);

%sessNumsHere = unique(trialbytrial(1).sessNumber);
%numSesses = unique(sessNumsHere);

numCells = size(trialbytrial(1).trialPSAbool{1},1);

for cpI = 1:numCondPairs
    
    for sessJ = 1:length(sessHere)
        %numTrialsActive{condI}{sessI} = [];
        cellsCoactive = zeros(numCells,numCells);
        sessI = sessHere(sessJ);
        for condJ = 1:size(condPairs,2)
            condI = condPairs(cpI,condJ);
            trialsHere = (trialbytrial(condI).sessID == sessI);
            numTrials = sum(trialsHere);
        
            cellFiresAtAll = cellfun(@(x) sum(x,2)>0,[trialbytrial(condI).trialPSAbool(trialsHere)],'UniformOutput',false);
        
            %cellsCoactive = zeros(numCells,numCells);
            for trialI = 1:numTrials
                cellsCoactiveHere = cellFiresAtAll{trialI}(:) & cellFiresAtAll{trialI}(:)';
                cellsCoactive = cellsCoactive + cellsCoactiveHere;
                %numTrialsActive{condI}{sessI} = numTrialsActive{condI}{sessI}+cellFiresAtAll{trialI}(:);
            end
        end
        I = logical(eye(numCells));
        numTrialsActive{sessI,cpI} = cellsCoactive(I);
        pctTrialsActive{sessI,cpI} = numTrialsActive{sessI,cpI}/numTrials;
        
        cellsCoactive(I) = 0;
        
        trialNormalizedCoactivity{sessI,cpI} = cellsCoactive ./ repmat(numTrialsActive{sessI,cpI}(:),1,numCells);
        
        trialNormalizedCoactivity{sessI,cpI}(isnan(trialNormalizedCoactivity{sessI,cpI})) = 0;
    end
end

end