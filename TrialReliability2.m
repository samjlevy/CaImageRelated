function [dayUse,trialReliability,threshAndConsec,cellTrials] = TrialReliability2(trialbytrial,boundary,lapPctThresh, consecLapThresh,condPairs)

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

trialReliability = zeros(numCells,totalSess,numCondPairs);
enoughConsec = false(numCells,totalSess,numCondPairs);

[maxConsec, enoughConsecR] = ConsecutiveLaps(trialbytrial,consecLapThresh,[],[]);
numTrials = zeros(numCondPairs,length(sessHere));
for cpI=1:numCondPairs
    for condJ = 1:size(condPairs,2)
        condI = condPairs(cpI,condJ);
        if isempty(boundary)
            condFires = cellfun(@(x) sum(x,2)>0,trialbytrial(condI).trialPSAbool,'UniformOutput',false);
        else
        % Get pts in bounds
            [ptsInBound,ptsOnBound] = cellfun(@(x,y) inpolygon(x,y,boundary{cpI}.X,boundary{cpI}.Y),...
                trialbytrial(condI).trialsX,trialbytrial(condI).trialsY,'UniformOutput',false);
            %{
            xx = trialbytrial(condI).trialsX{1};
            yy = trialbytrial(condI).trialsY{1};
            bx = boundary{cpI}.X;
            by = boundary{cpI}.Y;
            ptt = inin | onon;
            plot(xx(ptt),yy(ptt),'*')
            %}
            ptsUse = cellfun(@(x,y) x | y,ptsInBound,ptsOnBound,'UniformOutput',false);

            condFires = cellfun(@(x,y) sum(x(:,y),2)>0,trialbytrial(condI).trialPSAbool,ptsUse,'UniformOutput',false);
        end


        for sessI = 1:length(sessHere)
            trialsHere = trialbytrial(condI).sessID==sessHere(sessI);
            numTrials(cpI,sessI) = numTrials(cpI,sessI) + sum(trialsHere);
try
            activeHere = cell2mat([condFires(trialsHere)]');
catch
    keyboard
end
            %trialReliability(:,sessHere(sessI),cpI) = sum(activeHere,2)/numTrials;
            trialReliability(:,sessHere(sessI),cpI) = trialReliability(:,sessHere(sessI),cpI)+sum(activeHere,2);

            % Consec here...
            %enoughConsec(:,sessHere(sessI),cpI) = enoughConsecR{cpI}(:,sessI);
            enoughConsec(:,sessHere(sessI),cpI) = enoughConsec(:,sessHere(sessI),cpI) + enoughConsecR{condI}(:,sessI);
        end
        
    end
end
cellTrials = trialReliability;
for cpI=1:numCondPairs
    for sessI = 1:length(sessHere)
        trialReliability(:,sessHere(sessI),cpI) = trialReliability(:,sessHere(sessI),cpI)/numTrials(cpI,sessI);
    end
end
enoughConsec = enoughConsec > 0;

aboveThresh = trialReliability > lapPctThresh;
threshAndConsec = aboveThresh & enoughConsec;

dayUse = sum(threshAndConsec,3) > 0;


end