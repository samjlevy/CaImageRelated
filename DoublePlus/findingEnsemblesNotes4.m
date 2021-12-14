function [coactivityScore,numTrialsActive,numTrialsCoactive,numTotalTrials] = ...
    findingEnsemblesNotes4(trialbytrial,boundary,condPairs,shuffleLaps,sessRun)

numConds = length(trialbytrial);
if isempty(condPairs); condPairs = [1:numConds]'; end
numCondPairs = size(condPairs,1);
if isempty(sessRun)
    sessHere = unique(trialbytrial(1).sessID);
else
    sessHere = sessRun;
end

totalSess = max(sessHere); % this way to handle missing sess and keep organization
numCells = size(trialbytrial(1).trialPSAbool{1},1);

if ~isempty(boundary)
if isstruct(boundary)
    bdd = boundary;
    boundary = cell(numConds,1);
    [boundary{:}] = deal(bdd);
end
end

% Get a binary vector of whether each cell fired each lap
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
        
        if any(trialsHere)
        % Here is where we can shuffle which trials each cells is active on
        if shuffleLaps == true
            for cellI = 1:numCells
                newOrder = randPerm(size(activeHere,2));
                activeHere(cellI,:) = activeHere(cellI,newOrder);
            end
        end
        
        % Gets number of trials coactive, vector against self
        numTrialsH = numTrials(cpI,sessI);
        Nab  = zeros(numCells,numCells);
        
        for trialI = 1:numTrialsH
            cellsCoactiveHere = activeHere(:,trialI) * activeHere(:,trialI)';
            Nab = Nab + cellsCoactiveHere;
            %numTrialsActive{condI}{sessI} = numTrialsActive{condI}{sessI}+cellFiresAtAll{trialI}(:);
        end
        %}
        
% This seems to work and can cut 0.3s per run... 
% Nnvm, in practice like 40% slower...
        %{
        activeHereThree = reshape(activeHere,numCells,1,numTrialsH);
        activeHereThreeT = permute(activeHereThree,[2 1 3]);
        aaa = activeHereThree .* activeHereThreeT;
        Nab  = sum(aaa,3);
        %}
        numTrialsActive{sessI,cpI} = sum(activeHere,2);
        pctTrialsActive{sessI,cpI} = numTrialsActive{sessI,cpI}/numTrialsH; % Same as trialReli?
        I = logical(eye(numCells));
        Nab(I) = 0; % Number of trials this pair of cells is coactive
        
        % Mari's coactivity formula
        %{
        Nevents = 10;
        Na = 9;
        Nb = 3;
        Nab = 0:min([Na Nb]);
        
        for ii = 1:numel(Nab)
        Z(ii) = (Nab(ii) - (Na*Nb)/Nevents) / sqrt( (Na*Nb*(Nevents-Na)*(Nevents-Nb)) / ((Nevents^2)*(Nevents-1)) );
        end
        %}
        
        Nevents = numTrialsH;
        Na = numTrialsActive{sessI,cpI}(:);
        Nb = Na';
        %{
        Nab = [2, 2, 1; 2, 5, 4; 1, 4, 9]
        Na = [2; 5; 9]; Nb = Na';
        Nevents = 20;
        
        Na = 10;
        Nb = 10; 
        Nab = 10;
        %}
        
        %Z
        coactivityScore{cpI,sessI} = (Nab - ((Na(:)*Nb(:)') / Nevents)) ./ sqrt( (Na(:)*Nb(:)').*((Nevents-Na(:))*(Nevents-Nb(:)')) / ...
                                                        (Nevents*Nevents*(Nevents-1)) );
        numTrialsActive{cpI,sessI} = Na;
        numTrialsCoactive{cpI,sessI} = Nab;
        numTotalTrials(cpI,sessI) = Nevents;
        end
        
    end
end


end