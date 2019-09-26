function [behTable,areaX,areaY,areasWanted,behLabels] = ParseAlternationBehavior1(xAVI,yAVI,v0)

areasWanted = { 'delay area', 'reward left', 'reward right', 'choice area'};%, 'delay enter left', 'delay enter right'

areaPoly = []; areaX = []; areaY = [];

pp = figure('Position',[503 122 928 740]);
for awI = 1:length(areasWanted)
    doneDraw = 0;
    while doneDraw==0
        hold off
        imagesc(v0)
        title(['Please draw outline for ' areasWanted{awI}])
        [areaPoly{awI},areaX{awI},areaY{awI}] = roipoly;
        hold on
        plot(areaX{awI},areaY{awI},'r')
        dd = questdlg('Was this good?','Good area','Yes','No','Yes');
        if strcmpi(dd,'Yes'); doneDraw=1; end
    end
end
close(pp);

%ParseOut
%listdlg('Which of these divides laps?',areasWanted)
sequence = {[1];[4];[2 3]};
seqID = zeros(1,length(xAVI));
for sI=1:length(sequence)
    for ssI = 1:length(sequence{sI})
        [inArea,~] = inpolygon(xAVI,yAVI,areaX{sequence{sI}(ssI)},areaY{sequence{sI}(ssI)});
        seqID(inArea) = sI;
    end
end
    
frameNums = 1:length(xAVI);

inSeq = unique(seqID(seqID>0));

locSeq = seqID(seqID>0); %only the frames where in one of our areas
frameSeq = frameNums(seqID>0); %Those frame numbers

%
[uniqueSeq,epochs] = filterSeqToUnique(seqID);
epochs(uniqueSeq==0,:) = [];
uniqueSeq(uniqueSeq==0) = [];
[uniqueSeq2,epochs2] = filterSeqToUnique(uniqueSeq);

locSeqChanges = diff([uniqueSeq2(1) uniqueSeq2]);
posLapStarts = [1 find(locSeqChanges == (min(inSeq)-max(inSeq)))];
    
%Sliding Window
[epochs3] = slidingWindowMatch(uniqueSeq2,[1 2 3]); %epochs 3 has good laps

goodLapSequences = [];
for eeeI = 1:size(epochs3,1)
    goodLapSequences = [goodLapSequences; ...
        epochs(epochs2(epochs3(eeeI,1),1)) epochs(epochs2(epochs3(eeeI,2),2),2)]; %index all the way back
end
%These go from [enter delay area     leave reward area]

%Filter back to Lap information
numLaps = size(goodLapSequences,1);
for lapI = 1:numLaps
    if lapI==1
        lastDel = 1;
    else
        lastDel = behTable(lapI-1,end);
    end
    
    framesLS =lastDel:goodLapSequences(lapI,2);
        lapStart = framesLS(find(seqID(framesLS)==1,1,'last'));
    framesCE = lapStart:goodLapSequences(lapI,2);
        choiceEnter = framesCE(find(seqID(framesCE)==2,1,'first'));%lapStart-1 + 
    framesLC = choiceEnter:goodLapSequences(lapI,2);
        leaveChoice = framesLC(find(diff(seqID(framesLC)==2)==-1,1,'first'));%choiceEnter-1 + 
    framesER = leaveChoice:goodLapSequences(lapI,2);
        enterReward = framesER(find(seqID(framesER)==3,1,'first'));%leaveChoice-1 + 
    framesLR = enterReward:goodLapSequences(lapI,2);
        leaveReward = framesLR(find(diff(seqID(framesLR)==3)==-1,1,'first'));%enterReward-1 + 
    headingHome = goodLapSequences(lapI,2);
    if isempty(leaveReward)
        if sum(seqID(enterReward:headingHome)==0)==0
            leaveReward=headingHome;
        end
    end
    %{
        if lapI <numLaps
            leaveReward = enterReward-1 + find(seqID(enterReward:goodLapSequences(lapI+1,1))==0,1,'first');
        elseif lapI==numLaps
            leaveReward = find(seqID==3,1,'last');
        end
    end 
    %}
    delayEnter = headingHome-1 + find(seqID(headingHome:end)==1,1,'first');
    
    behTable(lapI,1:8) = [lastDel lapStart choiceEnter leaveChoice enterReward leaveReward headingHome delayEnter];
    
end
    
behLabels = {'LastDelayEnter','LapStart','ChoiceEnter','ChoiceLeave','RewardStart','RewardLeave','TowardsDelay','DelayEnter'};
end