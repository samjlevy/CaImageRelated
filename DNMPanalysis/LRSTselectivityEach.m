function [MIhits, MIspikes] = LRSTselectivityEach(trialbytrial)
%This is identical in operation to LRSTselectivity, but it produces a
%Modulation Index score for each cell, based on the formula for
%phase-amplitude coupling in Tort et al 2010.

numPhaseBins = 4;

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
leftTestSpikes = lapSpikes{leftTest};
rightTestSpikes = lapSpikes{rightTest};

%Left Study, Right Study, Left Test, Right Test
binAmpHits(:,:,1) = leftStudyHits; binAmpHits(:,:,2) = rightStudyHits;
binAmpHits(:,:,3) = leftTestHits; binAmpHits(:,:,4) = rightTestHits;
binAmpHitsNorm = binAmpHits./sum(binAmpHits,3);

binAmpSpikes(:,:,1) = leftStudySpikes; binAmpSpikes(:,:,2) = rightStudySpikes; 
binAmpSpikes(:,:,3) = leftTestSpikes; binAmpSpikes(:,:,4) = rightTestSpikes;
binAmpSpikesNorm = binAmpSpikes./sum(binAmpSpikes,3);



From here needs updating
%KL distance
logAmpHits=log2(binAmpHits);
ShannonH =-sum(binAmpHits(logAmpHits~=-Inf).*logAmpHits(logAmpHits~=-Inf)); 
DklHits = log2(numPhaseBins)-ShannonH;

MIhits=DklHits/log2(numPhaseBins);


logAmpSpikes=log2(binAmpSpikes);
ShannonH =-sum(binAmpSpikes(logAmpSpikes~=-Inf).*logAmpSpikes(logAmpSpikes~=-Inf)); 
DklSpikes = log2(numPhaseBins)-ShannonH;

MIspikes=DklSpikes/log2(numPhaseBins);

end