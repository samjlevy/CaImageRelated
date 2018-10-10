function ParseDoublePlusBehavior(sessType)

load Pos_align.mat x_adj_cm y_adj_cm TrackingUse

%should do a check on length of nan epochs

[armBounds, centerBoundary, endBounds] = MakeDoublePlusBehaviorBounds;

%will need to look for trials that are excessively long to id bad laps, 
%but this would work best if we can translate back to video time
%fps_brainimage = 20;
%Look at tracking use for frames to look at


%Find epochs through the center
inCenter = inpolygon(x_adj_cm,y_adj_cm,centerBoundary(:,1),centerBoundary(:,2));
%figure; plot(x_adj_cm,y_adj_cm,'.k'); hold on; plot(x_adj_cm(inCenter),y_adj_cm(inCenter),'.r')

%Find epochs on start arms
onNorth = inpolygon(x_adj_cm,y_adj_cm,endBounds.north(:,1),endBounds.north(:,2));
onSouth = inpolygon(x_adj_cm,y_adj_cm,endBounds.south(:,1),endBounds.south(:,2));

%Find epochs on end arms
onEast = inpolygon(x_adj_cm,y_adj_cm,endBounds.east(:,1),endBounds.east(:,2));
onWest = inpolygon(x_adj_cm,y_adj_cm,endBounds.west(:,1),endBounds.west(:,2));

onMaze = ~isnan(x_adj_cm);
ontoMaze = find(diff([0 onMaze 0]) == 1);
offMaze = find(diff([0 onMaze 0]) == -1) -1; 
if length(ontoMaze) ~= length(offMaze)
    disp('error, not the same number of maze entries and exits')
    keyboard
end

offEs = [offMaze(1:end-1)' ontoMaze(2:end)'];
for oeI = 1:size(offEs)
    numOffMaze = sum(onMaze(offEs(oeI,1)-10:offEs(oeI,2)+10)==0);
    if numOffMaze<100
        disp('Error: found a short off maze epoch. What do you want to do?')
        keyboard
    end
end

locInds = {1 'center'; 2 'north'; 3 'south'; 4 'east'; 5 'west'};
armOrCent = inCenter + onNorth*2 + onSouth*3 + onEast*4 + onWest*5;
intoCent = find(diff([0 armOrCent==1 0]) == 1);
outCent = find(diff([0 armOrCent==1 0]) == -1) -1;
if length(intoCent) ~= length(outCent)
    disp('error, not the same number of center entries and exits')
    keyboard
end

intoStart = find(diff([0 (armOrCent==2 | armOrCent==3) 0]) == 1);
outStart = find(diff([0 (armOrCent==2 | armOrCent==3) 0]) == -1) -1;
if length(intoStart) ~= length(outStart)
    disp('error, not the same number of start entries and exits')
    keyboard
end
%intoNorth = find(diff([0 (armOrCent==2 | armOrCent==3) 0]) == 1);
%outStart = find(diff([0 (armOrCent==2 | armOrCent==3) 0]) == -1) -1;


intoEnd = find(diff([0 (armOrCent==4 | armOrCent==5) 0]) == 1);
outEnd = find(diff([0 (armOrCent==4 | armOrCent==5) 0]) == -1) -1;
if length(intoEnd) ~= length(outEnd)
    disp('error, not the same number of end entries and exits')
    keyboard
end

zeroBlank = zeros(1,length(x_adj_cm));
lapNumber = 1;
lapParsed = [];
for omI = 1:length(ontoMaze)
    %Get end and center entries and exits this onMaze epoch
    startStart = intoStart(intoStart >= ontoMaze(omI) & intoStart <= offMaze(omI));
    endStart = outStart(outStart >= ontoMaze(omI) & outStart <= offMaze(omI));
    
    startCent = intoCent(intoCent >= ontoMaze(omI) & intoCent <= offMaze(omI));
    endCent = outCent(outCent >= ontoMaze(omI) & outCent <= offMaze(omI));
    
    startEnd = intoEnd(intoEnd >= ontoMaze(omI) & intoEnd <= offMaze(omI));
    endEnd = outEnd(outEnd >= ontoMaze(omI) & outEnd <= offMaze(omI));
    
    %Parse this all out
    %if isempty(startStart) || isempty(endStart) || isempty(startCent) || isempty(endCent)...
    %        || isempty(startEnd) || isempty(endEnd)
    %    keyboard
    %end
    
    %Do the parseing
    try
        lapStruct = OrganizeSequence(startStart,endStart,startCent,endCent,startEnd,endEnd,armOrCent);
    catch
        keyboard
    end
    
    try
        lapStruct = IdentifyLocations(lapStruct, armOrCent, locInds);
    catch
        keyboard
    end
    
    try
        lapStruct = IdentifyLapType(lapStruct,sessType,locInds);
    catch
        keyboard
    end
    
    %Put it in the struct
    sFields = fieldnames(lapStruct);
    for sfI = 1:length(sFields)
        lapParsed(omI).(sFields{sfI}) = lapStruct.(sFields{sfI});
    end
    
    if length(lapStruct.order.allDetail) ~= 3
        omI
        keyboard
        %approxFrame = round(lapStruct.startMaze*(30/20) + TrackingUse(1) - 1)
        %approxFrame = round(lapStruct.enterMid*(30/20) + TrackingUse(1) - 1)
        %approxFrame = round(offMaze(omI)*(30/20) + TrackingUse(1) - 1)
        %figure; plot(x_adj_cm,y_adj_cm,'.k'); hold on
        %plot(x_adj_cm(lapStruct.startMaze(1):lapStruct.leaveMaze(end)),y_adj_cm(lapStruct.startMaze(1):lapStruct.leaveMaze(end)),'.m')
        %plot(x_adj_cm(lapStruct.endLap(ii):lapStruct.leaveMaze(ii)),y_adj_cm(lapStruct.endLap(ii):lapStruct.leaveMaze(ii)),'.g')
        %plot(x_adj_cm(lapStruct.leaveMaze(ii):lapStruct.endLap(ii+1)),y_adj_cm(lapStruct.leaveMaze(ii):lapStruct.endLap(ii+1)),'.y')
    end
    
end

saveNow = input('save this? (y/n)>> ','s');
if strcmpi(saveNow,'y')
    save('behaviorStruct.mat','lapParsed')
    disp('done, saved')
else
    disp('done, not saved')
end

end

function evalAndCheckOffMaze(bStart,bEnd)

bStart = 61104;
bEnd = 61597;

bStart = 8255
bEnd = 8692

load('PosLED_temp.mat', 'onMaze')
numOffmaze = sum(onMaze(bStart:bEnd)==0)

approxFrame = round(ans*(30/20) + TrackingUse(1) - 1)
onMaze(bStart:bEnd)=0;
onMaze = double(onMaze);
%clear bStart bEnd
save('PosLED_temp.mat','onMaze','-append')
onMaze = logical(onMaze);
save('PosScaled.mat','onMaze','-append')

PosScaledToPosAlign

ParseDoublePlusBehavior('turn')

end
function lapStruct = IdentifyLapType(lapStruct,sessType,locInds)

to = lapStruct.order.all;
if length(to)==3
    if mean(to == [1 2 3])==1
    %lap is good
        lapStruct.goodSequence = 1;
    else
        lapStruct.goodSequence = 0;
    end
else
    lapStruct.goodSequence = 0;
end
  
lapStruct.isCorrect = 0;
if lapStruct.goodSequence==1
    od = lapStruct.order.allDetail;
    switch sessType
        case 'turn'
            if strcmpi(locInds{od(1),2},'south') && strcmpi(locInds{od(3),2},'east') ||...
                    strcmpi(locInds{od(1),2},'north') && strcmpi(locInds{od(3),2},'west')
                lapStruct.isCorrect = 1;
            end
        case 'place'
            if strcmpi(locInds{od(1),2},'south') && strcmpi(locInds{od(3),2},'east') ||...
                    strcmpi(locInds{od(1),2},'north') && strcmpi(locInds{od(3),2},'east')
                lapStruct.isCorrect = 1;
            end
    end
end

end

function [lapStruct] = OrganizeSequence(startStart,endStart,startCent,endCent,startEnd,endEnd,armOrCent)

[startStart,endStart] = condenseExtraEpochs(startStart,endStart,armOrCent); %starts=startStart; ends=endStart; startStart=newStart; endStart=newEnd;
[startCent,endCent] = condenseExtraEpochs(startCent,endCent,armOrCent); %starts=startCent; ends=endCent; startCent=newStart; endCent=newEnd;
[startEnd,endEnd] = condenseExtraEpochs(startEnd,endEnd,armOrCent); %starts=startEnd; ends=endEnd; startEnd=newStart; endEnd=newEnd;

startE = [startStart', endStart']; startType = []; 
for sI = 1:length(startStart) 
    bs = armOrCent(startE(sI,1):startE(sI,2));
    startType(sI) = mode(bs(bs>0)); 
end
centE = [startCent', endCent']; centType = []; 
for cI = 1:length(startCent)
    bc = armOrCent(centE(cI,1):centE(cI,2));
    centType(cI) = mode(bc(bc>0)); 
end
endE = [startEnd', endEnd']; endType = []; 
for eI = 1:length(startEnd)
    be = armOrCent(endE(eI,1):endE(eI,2));
    endType(eI) = mode(be(be>0));
end

allPile = [startStart(:); startCent(:); startEnd(:)];
pileMarker = [1*ones(1,length(startStart)), 2*ones(1,length(startCent)), 3*ones(1,length(startEnd))];
detailMarker = [startType centType endType];

[sortedPile,sortOrder] = sort(allPile);

sortedMarker = pileMarker(sortOrder);
pileRanks = tiedrank(allPile);

lapStruct.startMaze = startStart; lapStruct.startLap = endStart;
lapStruct.order.starts = pileRanks(pileMarker==1);
lapStruct.enterMid = startCent; lapStruct.leaveMid = endCent;
lapStruct.order.centers = pileRanks(pileMarker==2);
lapStruct.endLap = startEnd; lapStruct.leaveMaze = endEnd;
lapStruct.order.ends = pileRanks(pileMarker==3);

lapStruct.order.all = sortedMarker;
lapStruct.order.allDetail = detailMarker(sortOrder);
%needs to be checked with something longer
end

function [newStart,newEnd] = condenseExtraEpochs(starts,ends,armOrCent)

if length(starts)>1
    eCheck = [ends(1:end-1)' starts(2:end)'];
    for ssJ = 1:size(eCheck,1)
        anyOther(ssJ) = sum(armOrCent(eCheck(ssJ,1)+1:eCheck(ssJ,2)-1)) > 0;
    end
    startKeep = [true anyOther==1];
    endKeep = [anyOther==1 true];
    
    newStart = starts(startKeep);
    newEnd = ends(endKeep);
else
    newStart = starts;
    newEnd = ends;
end

%{
if length(starts)>1
    for ssI = 1:length(starts)
        whichStart(ssI) = mode(armOrCent(starts(ssI):ends(ssI)));
    end
    for ssJ = 1:length(starts)-1
        anyOther(ssJ) = sum(armOrCent(ends(ssJ)+1:starts(ssJ+1)-1));
    end
    if sum(sum(whichStart==whichStart',1)/length(whichStart))==length(whichStart)
        newStart = starts(1);
        newEnd = ends(end);
    else
        newStart = starts;
        newEnd = ends;
    end
else
    newStart = starts;
    newEnd = ends;
end
%}
end

function lapStruct = IdentifyLocations(lapStruct, armOrCent, locInds)

for cs = 1:length(lapStruct.startMaze)
    behHere = armOrCent(lapStruct.startMaze(cs):lapStruct.startLap(cs));
    labInd = mode(behHere(behHere>0));
    lapStruct.startLabels{cs} = locInds{labInd,2}; 
end
for ce = 1:length(lapStruct.endLap)
    behHere = armOrCent(lapStruct.endLap(ce):lapStruct.endLap(ce));
    labInd = mode(behHere(behHere>0));
    lapStruct.endLabels{ce} = locInds{labInd,2}; 
end

end