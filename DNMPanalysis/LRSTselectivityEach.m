function [LRsel, STsel, eachsel] = LRSTselectivityEach(trialbytrial)

allnames = {trialbytrial(:).name};
studyC = cell2mat(cellfun(@(x) ~isempty(strfind(x,'study')),allnames,'UniformOutput',false));
testC = cell2mat(cellfun(@(x) ~isempty(strfind(x,'test')),allnames,'UniformOutput',false));
leftC = cell2mat(cellfun(@(x) ~isempty(strfind(x,'_l')),allnames,'UniformOutput',false));
rightC = cell2mat(cellfun(@(x) ~isempty(strfind(x,'_r')),allnames,'UniformOutput',false));

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
leftStudy = find(leftC & studyC); 
rightStudy = find(rightC & studyC);
leftTest = find(leftC & testC); 
rightTest = find(rightC & testC);

leftStudyHits = lapHits{leftStudy};
rightStudyHits = lapHits{rightStudy};
leftTestHits = lapHits{leftTest};
rightTestHits = lapHits{rightTest};

leftStudySpikes = lapSpikes{leftStudy};
rightStudySpikes = lapSpikes{rightStudy};
rightStudySpikes = lapSpikes{leftTest};
rightTestSpikes = lapSpikes{rightTest};

%Left Study, Right Study, Left Test, Right Test
binAmpHits = [leftStudyHits rightStudyHits leftTestHits rightTestHits];
binAmpHits = binAmpHits/sum(binAmpHits);

binAmpSpikes = [leftStudySpikes rightStudySpikes leftTestSpikes rightTestSpikes];
binAmpSpikes = binAmpSpikes/sum(binAmpSpikes);


%KL distance
logAmp=log2(binAmp);
ShannonH =-sum(binAmp(logAmp~=-Inf).*logAmp(logAmp~=-Inf)); 
Dkl = log2(numPhaseBins)-ShannonH;

MI=Dkl/log2(numPhaseBins);

end