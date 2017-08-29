function [LRsel, STsel, eachsel] = LRSTselectivity(trialbytrial)

allnames = {trialbytrial(:).name};
studyC = find(cell2mat(cellfun(@(x) ~isempty(strfind(x,'study')),allnames,'UniformOutput',false)));
testC = find(cell2mat(cellfun(@(x) ~isempty(strfind(x,'test')),allnames,'UniformOutput',false)));
leftC = find(cell2mat(cellfun(@(x) ~isempty(strfind(x,'_l')),allnames,'UniformOutput',false)));
rightC = find(cell2mat(cellfun(@(x) ~isempty(strfind(x,'_r')),allnames,'UniformOutput',false)));

numLaps = cell(length(trialbytrial),1);
lapHits = cell(length(trialbytrial),1);
lapSpikes = cell(length(trialbytrial),1);
goodSpikes = cell(length(trialbytrial),1);

for condType = 1:length(trialbytrial)
    for sess = 1:max(trialbytrial(condType).sessID)
        hitsThisCond = [];
        spikesThisCond = [];
        thisLaps = find(trialbytrial(condType).sessID == sess);
        for lap = 1:length(thisLaps)
            thisLap = thisLaps(lap);
            hitsThisCond = [hitsThisCond,...
                any(trialbytrial(condType).trialPSAbool{thisLap},2)];
            spikesThisCond = [spikesThisCond, sum(trialbytrial(condType).trialPSAbool{thisLap},2)];
        end
         
        numLaps{condType}(1,sess) = length(thisLaps);
        lapHits{condType}(:,sess) = sum(hitsThisCond,2);
        lapSpikes{condType}(:,sess) = sum(spikesThisCond,2);
        
        goodSpikes{condType}(:,sess) = sum(spikesThisCond,2)./sum(hitsThisCond,2);
    end
end

leftHits = lapHits{leftC(1)} + lapHits{leftC(2)};
rightHits = lapHits{rightC(1)} + lapHits{rightC(2)};
studyHits = lapHits{studyC(1)} + lapHits{studyC(2)};
testHits = lapHits{testC(1)} + lapHits{testC(2)};

leftSpikes = lapSpikes{leftC(1)} + lapSpikes{leftC(2)};
rightSpikes = lapSpikes{rightC(1)} + lapSpikes{rightC(2)};
studySpikes = lapSpikes{studyC(1)} + lapSpikes{studyC(2)};
testSpikes = lapSpikes{testC(1)} + lapSpikes{testC(2)};

LRsel.hits = (rightHits - leftHits) ./ (rightHits + leftHits);
LRsel.spikes = (rightSpikes - leftSpikes) ./ (rightSpikes + leftSpikes);

STsel.hits = (testHits - studyHits) ./ (testHits + studyHits);
STsel.spikes = (testSpikes - studySpikes) ./ (testSpikes + studySpikes);


end