function [trialNormalizedCoactivity,totalNormalizedCoactivity,pctTrialsActive,trialCoactiveAboveBaseline,totalCoactiveAboveBaseline,chanceCoactive] = ...
    findingEnsemblesNotes3(trialbytrial,boundary,condPairs)

numConds = length(trialbytrial);
if isempty(condPairs); condPairs = [1:numConds]'; end
numCondPairs = size(condPairs,1);
sessHere = unique(trialbytrial(1).sessID);
totalSess = max(sessHere); % this way to handle missing sess and keep organization
numCells = size(trialbytrial(1).trialPSAbool{1},1);

if ~isempty(boundary)
if isstruct(boundary)
    bdd = boundary;
    boundary = cell(numConds,1);
    [boundary{:}] = deal(bdd);
end
end

for condI = 1:numConds
    if isempty(boundary)
        condFires{condI} = cellfun(@(x) sum(x,2)>0,trialbytrial(condI).trialPSAbool,'UniformOutput',false);
    else
        [ptsInBound,ptsOnBound] = cellfun(@(x,y) inpolygon(x,y,boundary{condI}.X,boundary{condI}.Y),...
            trialbytrial(condI).trialsX,trialbytrial(condI).trialsY,'UniformOutput',false);
        ptsUse = cellfun(@(x,y) x | y,ptsInBound,ptsOnBound,'UniformOutput',false);

        condFires{condI} = cellfun(@(x,y) sum(x(:,y),2)>0,trialbytrial(condI).trialPSAbool,ptsUse,'UniformOutput',false);
    end
end

numTrials = zeros(numCondPairs,max(sessHere));
for cpI=1:numCondPairs
    for sessJ = 1:length(sessHere)
        sessI = sessHere(sessJ);
        activeHere = [];
        for condJ = 1:size(condPairs,2)
            condI = condPairs(cpI,condJ);

            trialsHere = trialbytrial(condI).sessID==sessI;
            numTrials(cpI,sessI) = numTrials(cpI,sessI) + sum(trialsHere);

            activeHere = [activeHere, cell2mat([condFires{condI}(trialsHere)]')];
            %trialReliability(:,sessHere(sessI),cpI) = sum(activeHere,2)/numTrials;
            %trialReliability(:,sessHere(sessI),cpI) = trialReliability(:,sessHere(sessI),cpI)+sum(activeHere,2);

        end
        
        % Gets number of trials coactive
        numTrialsH = numTrials(cpI,sessI);
        cellsCoactive  = zeros(numCells,numCells);
        for trialI = 1:numTrialsH
            cellsCoactiveHere = activeHere(:,trialI) & activeHere(:,trialI)';
            cellsCoactive = cellsCoactive + cellsCoactiveHere;
            %numTrialsActive{condI}{sessI} = numTrialsActive{condI}{sessI}+cellFiresAtAll{trialI}(:);
        end

        numTrialsActive{sessI,cpI} = sum(activeHere,2);
        pctTrialsActive{sessI,cpI} = numTrialsActive{sessI,cpI}/numTrialsH; % Same as trialReli?
        I = logical(eye(numCells));
        cellsCoactive(I) = 0;
        
        trialNormalizedCoactivity{sessI,cpI} = cellsCoactive ./ repmat(numTrialsActive{sessI,cpI}(:),1,numCells);
        trialNormalizedCoactivity{sessI,cpI}(isnan(trialNormalizedCoactivity{sessI,cpI})) = 0;
        
        totalNormalizedCoactivity{sessI,cpI} = cellsCoactive / numTrialsH;
        
        chanceCoactive{sessI,cpI} = pctTrialsActive{sessI,cpI}(:) .* pctTrialsActive{sessI,cpI}(:)';
        
        trialCoactiveAboveBaseline{sessI,cpI} = (trialNormalizedCoactivity{sessI,cpI} > chanceCoactive{sessI,cpI})...
            & (trialNormalizedCoactivity{sessI,cpI}>0);
        totalCoactiveAboveBaseline{sessI,cpI} = (totalNormalizedCoactivity{sessI,cpI} > chanceCoactive{sessI,cpI})...
            & (totalNormalizedCoactivity{sessI,cpI} > 0);
    end
end

end