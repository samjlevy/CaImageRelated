function [onMazeFinal,behTable] = PreProcParseOnMazeBehavior(xAVI,yAVI,v0,obj)
disp('parsing on mazeBehavior')
aviSR = obj.FrameRate;
%Find epochs of missing points based on expected plus maze behavior
ff = figure;
imagesc(v0);
title('Draw boundary for maze center')
figure(ff);
[~,centerX,centerY,] = roipoly;
close(ff);

nStartLocs = 2;
for slI = 1:nStartLocs
    ff = figure; imagesc(v0); title(['Draw boundary for start area ' num2str(slI)])
    [~,startX{slI},startY{slI}] = roipoly; %#ok<AGROW>
    close(ff);
end

nEndLocs = 2;
for elI = 1:nEndLocs
    ff = figure; imagesc(v0); title(['Draw boundary for end area ' num2str(elI)])
    [~,endX{elI},endY{elI}] = roipoly; %#ok<AGROW>
    close(ff);
end

pedsX = []; pedsY = [];
getped = input('Draw a pedestel region? (y/n) >>','s');
if strcmpi(getped,'y')
     ff = figure; imagesc(v0); title('Draw boundary for Pedestal')
    [~,pedsX,pedsY] = roipoly; 
    close(ff);
    onPedestal = inpolygon(xAVI,yAVI,pedsX,pedsY);
    ontoPed = find(diff([0; onPedestal; 0]) == 1);
    offPed = find(diff([0; onPedestal; 0]) == -1) -1;
end

disp('Now parsing maze center - arm end epochs')
minCenterDur = 2;

inCenter = inpolygon(xAVI,yAVI,centerX,centerY);
%enterCenter = find(diff(inCenter) == 1);
%leaveCenter = find(diff(inCenter) == -1)+1; %This may be a problem, needs to be consistend w/ arm entries to handle uncut flickers
%New version, finds first and last frame in epochs
%inCenter = [0; inCenter; 0]; 
enterCenter = find(diff([0; inCenter; 0]) == 1);
leaveCenter = find(diff([0; inCenter; 0]) == -1) -1;

if size(enterCenter,1) == 1
    enterCenter = enterCenter';
end
if size(leaveCenter,1) == 1
    leaveCenter = leaveCenter';
end

outEpochs = [leaveCenter(1:end-1) enterCenter(2:end)];
outDurations = diff(outEpochs,1,2);

badEpochs = outDurations <= minCenterDur; %unlikely to be real

enterCenter(logical([0; badEpochs])) = [];
leaveCenter(logical([badEpochs; 0])) = [];

%offMazeMin = 10;  maybe this is causing problems?
offMazeMin = 0; %Minimum number of frames an entrance is separated from an exit to be considered real
%onMazeMin = 20;

behaviorMarker = inCenter;
behBoundsX = [startX, endX];
behBoundsY = [startY, endY];
bbsStartsEnds = [1*ones(1,nStartLocs) 2*ones(1,nEndLocs)];

for bbxI = 1:length(bbsStartsEnds)
    inHere = inpolygon(xAVI,yAVI,behBoundsX{bbxI},behBoundsY{bbxI});
    behaviorMarker = behaviorMarker+(1+bbxI)*inHere;
end
%behaviorMarker = behaviorMarker';

%Get entries/exits of maze arm ends, refine by duration
%leaveArmEnd = find(diff([0; behaviorMarker]>1) == -1); %laeHold = leaveArmEnd;
%enterArmEnd = find(diff([0; behaviorMarker]>1) == 1);  %  eaeHold = enterArmEnd;    
allEnters = []; allLeaves = []; markerE = []; markerL = [];
for aeK = 1:length(bbsStartsEnds)
    armEnters = find(diff([0; behaviorMarker; 0]==(aeK+1)) == 1);
    armLeaves = find(diff([0; behaviorMarker; 0]==(aeK+1)) == -1) -1;
    
    allEnters = [allEnters; armEnters];
    allLeaves = [allLeaves; armLeaves];
    markerE = [markerE; aeK*ones(size(armEnters,1),size(armEnters,2))]; %For sanity check
    markerL = [markerL; aeK*ones(size(armLeaves,1),size(armLeaves,2))];
end
aa = [markerE, markerL];
[enterArmEnd,enterSortInds] = sort(allEnters);
[leaveArmEnd,leaveSortInds] = sort(allLeaves);
markerEsorted = markerE(enterSortInds);
markerLsorted = markerL(leaveSortInds);
bb = [markerEsorted markerLsorted];
if sum(diff(bb,1,2)==0) ~= size(bb,1)
    disp('error: entry and end did not align properly')
    keyboard
end

%Eliminate out of center that doesn't include other arms;
%This could mean a center epoch includes time out of the center, but it
%should help to link onmaze time together
cbI = 1;
while cbI < length(enterCenter)
    armHere = sum(behaviorMarker(leaveCenter(cbI):enterCenter(cbI+1)) > 1);
    if any(pedsX)
        pedHere = sum(onPedestal(leaveCenter(cbI):enterCenter(cbI+1)));
        armHere = armHere + pedHere;
    end
    switch armHere > 0
        case 0
            leaveCenter(cbI) = [];
            enterCenter(cbI+1) = [];
        case 1
            cbI = cbI+1;
        otherwise
            disp('switch error')
            keyboard
    end
end

%Delete too short off maze epochs
%with off maze min set to zero, this does nothing
%might want to exclude since pairing same arm in on and off
%{
offMazeEpochs = [enterArmEnd(2:end) leaveArmEnd(1:end-1)];
outArmDurations = diff(fliplr(offMazeEpochs),1,2);
badArmEpochs = outArmDurations < offMazeMin; %unlikely to be real
offMazeEpochs(badArmEpochs,:) = [];

leaveArmEnd = [offMazeEpochs(:,2); leaveArmEnd(end)];
enterArmEnd = [enterArmEnd(1); offMazeEpochs(:,1)];
%}
%{
outArmMin = 10;
offMazeEpochs = [leaveArmEnd(1:end-1) enterArmEnd(2:end)];
offMazeSame = markerLsorted(1:end-1)==markerEsorted(2:end);
outArmDurations = diff(offMazeEpochs,1,2);
badArmEpochs = outArmDurations < outArmMin;
offMazeEpochs(badArmEpochs & offMazeSame,:) = [];

enterArmEnd = [enterArmEnd(1); offMazeEpochs(:,2)];
leaveArmEnd = [offMazeEpochs(:,1); leaveArmEnd(end)];
%}

%Eliminate pedestal jitter that doesn't have on maze
if any(pedsX)
cbK = 1;
while cbK < length(ontoPed)
    armHere = sum(behaviorMarker(offPed(cbK):ontoPed(cbK+1)) > 1);
    centerHere = sum(inCenter(offPed(cbK):ontoPed(cbK+1)) > 1);
    otherHere = armHere + centerHere;
    switch otherHere > 0
        case 0
            offPed(cbK) = [];
            ontoPed(cbK+1) = [];
        case 1
            cbK = cbK+1;
        otherwise
            disp('switch error')
            keyboard
    end
end
end
%Eliminate ped epochs too short
%{
outPedMin = 10;
offPedEpochs = [offPed(1:end-1) ontoPed(2:end)];
offPedDurations = diff(offPedEpochs,1,2);
badPedEpochs = outPedDurations < outArmMin;
offPedEpochs(badPedEpochs,:) = [];
%}

%{
probablyOnMaze = zeros(length(xAVI),1);
for ceI = 1:length(enterCenter)
    probablyOnMaze(enterCenter(ceI):leaveCenter(ceI)) = 1;
end
for aeI = 1:length(enterArmEnd)
    probablyOnMaze(enterArmEnd(aeI):leaveArmEnd(aeI)) = 1;
end
%}
%{
realOnMazeDur = 0;
for ii = 1:size(handCoded,1)
    realOnMazeDur = realOnMazeDur + handCoded(ii,2) - handCoded(ii,1) + 1;
end
%}
%Get user approval for center passes
cpI = 1;
while cpI <length(enterCenter)+1
    stretchCheck = enterCenter(cpI):leaveCenter(cpI);
    midFrameInd = ceil(length(stretchCheck)/2);
    midFrameN = stretchCheck(midFrameInd);
    obj.CurrentTime = (midFrameN-1)/aviSR;
    midFrame = readFrame(obj);
    orFrame = figure('Position',[422 462 560 420]); imagesc(midFrame); title(['Middle frame ' num2str(midFrameN)])
    usrApp = figure('Position',[1004 459 560 420]);
    imagesc(midFrame); hold on;
    plot(xAVI(stretchCheck(1:midFrameInd-1)),yAVI(stretchCheck(1:midFrameInd-1)),'og')
    plot(xAVI(stretchCheck(midFrameInd+1:end)),yAVI(stretchCheck(midFrameInd+1:end)),'or')
    plot(xAVI(midFrameN),yAVI(midFrameN),'*y')
    title(['Is this segment on the maze?  midFrame= ' num2str(midFrameN) ' (y/n) (input)'])
    ss = 'g';
    while (strcmpi(ss,'y') + strcmpi(ss,'n'))==0
        ss = input('Is this segment on the maze? (y/n) >>','s');
    end
             
    if strcmpi(ss,'n')
        enterCenter(cpI) = [];
        leaveCenter(cpI) = [];
        cpI = cpI - 1;
    end
    
    close(orFrame); close(usrApp);
    cpI = cpI + 1;
end


%Check for leaveCenter - enterCenter where there's only one arm entry and
%exit
disp('Building behavior table')
behTable = [zeros(length(enterCenter),2) enterCenter leaveCenter zeros(length(enterCenter),2)];
behTable(1,1) = enterArmEnd(1);
behTable(1,2) = leaveArmEnd(1);
possibleBadMazeExit = zeros(length(enterCenter),1);
possibleBadMazeEntry = zeros(length(enterCenter),1);
ceJstart = 1;
if ceJstart~=1
    disp('warning: not starting at first index')
    keyboard
end
%ceJstart = ceJ+1
for ceJ = ceJstart:(length(leaveCenter)-1)
    %Get the arm entries and exits surrounding the current center epoch
    armEntries = enterArmEnd(enterArmEnd > leaveCenter(ceJ) & enterArmEnd < enterCenter(ceJ+1));
    armLeavings = leaveArmEnd(leaveArmEnd > leaveCenter(ceJ) & leaveArmEnd < enterCenter(ceJ+1));
    
    %if we have a pedestal, use that to limit
    onPedLim = length(xAVI)+1;
    offPedLim = 0;
    if any(pedsX)
        pedEntries = ontoPed(ontoPed > leaveCenter(ceJ) & ontoPed < enterCenter(ceJ+1));
        pedLeavings = offPed(offPed > leaveCenter(ceJ) & offPed < enterCenter(ceJ+1));
        
        if any(pedEntries)
            onPedLim = pedEntries(1);
        end
        if any(pedLeavings)
            offPedLim = pedLeavings(end);
        end
    end
    armEntries((armEntries > onPedLim) & (armEntries < offPedLim)) = [];
    armLeavings((armLeavings > onPedLim) & (armLeavings < offPedLim)) = [];
    
    if length(armEntries) ~= length(armLeavings)
        disp('not the same number as entries and exits here, error somewhere')
        keyboard
    end
    
    switch length(armEntries)
        case 2
            behTable(ceJ,5) = armEntries(1);
            behTable(ceJ,6) = armLeavings(1);

            if behTable(ceJ+1,2) == 0
                behTable(ceJ+1,2) = armLeavings(2);
            end
            if behTable(ceJ+1,1) == 0
                behTable(ceJ+1,1) = armEntries(2);
            end
        case 1 %Either mouse is carried through the maze to the start of the next trial, or 
               %Mouse was allowed to correct his mistake, or
               %Mouse was carried off the maze through the center at the end of a trial
            behTable(ceJ,5) = armEntries;
            behTable(ceJ,6) = armLeavings;
            
            behTable(ceJ+1,1) = armEntries;
            behTable(ceJ+1,2) = armLeavings;
            
            possibleBadMazeExit(ceJ) = 1;
            possibleBadMazeEntry(ceJ+1) = 1;
        case 0
            %Won't happen
            %keyboard
            disp('No arm entries here')
            behTable(ceJ,5) = NaN;
            behTable(ceJ,6) = NaN;
            
            behTable(ceJ+1,1) = NaN;
            behTable(ceJ+1,2) = NaN;
        otherwise
            %Figure out if any are the same as the first and last, and assume they go with that one
            %If they are all the same, could up to the first and last one
            %with each, we'll have to sort out overlap to find off maze later
            %This will skip points that are not the same (can't jump from
            %one arm to another without going through middle
            armEndInds = 1:length(armEntries);
            
            whichArmEnds = [];
            for aeI = 1:length(armEntries)
                whichArmEnds(aeI) = mode(behaviorMarker(armEntries(aeI):armLeavings(aeI))); %#ok<AGROW>
            end
            
            switch any(pedsX)
                case 0
                    sameAsFirst = whichArmEnds(2:end-1) == whichArmEnds(1);
                    sameAsLast = whichArmEnds(2:end-1) == whichArmEnds(end);

                    sharedFirstLast =  sum([sameAsFirst; sameAsLast],1)==2; %#ok<NASGU>

                    changesFromStart = find(diff([whichArmEnds(1:end-1)==whichArmEnds(1) 0])==-1);
                    changesFromEnd = find(diff([0 whichArmEnds(2:end)==whichArmEnds(end)])==1)+1;
                    %changesFromStart = find(diff([whichArmEnds(1:end-1)==whichArmEnds(1) 0])==-1,1,'first');
                    %changesFromEnd = find(diff([0 whichArmEnds(2:end)==whichArmEnds(end)])==1,1,'last')+1;
                case 1
                    armEndPrePed = armEntries<onPedLim;
                    armEndPostPed = armEntries>offPedLim;
                    
                    sharedFirstLast = sum([armEndPrePed armEndPostPed],2)==2;
                    if sum(sharedFirstLast) > 0
                        disp('Some how a shared first and last either side of a pedestal epoch. What?')
                        keyboard
                        
                        cbI = 1;
                        while cbI < length(armEntries)-1
                            otherHere = sum(behaviorMarker((armLeavings(cbI)+1):(armEntries(cbI+1)-1)) > 0);
                            switch otherHere > 0
                                case 0
                                    armLeavings(cbI) = [];
                                    armEntries(cbI+1) = [];
                                case 1
                                    cbI = cbI+1;    
                                otherwise
                                    disp('switch error')
                                    keyboard
                            end
                        end
                    end
                    
                    armEndInds = 1:length(armEntries);
                    whichArmEnds = [];
                    for aeI = 1:length(armEntries)
                        whichArmEnds(aeI) = mode(behaviorMarker(armEntries(aeI):armLeavings(aeI))); %#ok<AGROW>
                    end
                    armEndPrePed = armEntries<onPedLim;
                    armEndPostPed = armEntries>offPedLim;
                    
                    waeStart = whichArmEnds; waeStart = waeStart.*armEndPrePed';
                    changesFromStart = find(diff([waeStart(1:end-1)==waeStart(1) 0])==-1);
                    waeEnd = whichArmEnds; waeEnd = waeEnd.*armEndPostPed';
                    changesFromEnd = find(diff([0 waeEnd(2:end)==waeEnd(end)])==1)+1;
            end
                  
            if length(changesFromStart)~=1 || length(changesFromEnd)~=1
                if changesFromStart(end) < changesFromEnd(1)
                    changesFromStart = changesFromStart(end);
                    changesFromEnd = changesFromEnd(1);
                end
            end
               
            
            if length(changesFromStart)==1 && length(changesFromEnd)==1
                armEndsStart = armEndInds(1:changesFromStart);
                armEndsEnd = armEndInds(changesFromEnd:end);
                
                posFirst = [armEntries(armEndsStart) armLeavings(armEndsStart)];
                posLast = [armEntries(armEndsEnd) armLeavings(armEndsEnd)];
                
                behTable(ceJ,5) = posFirst(1,1);
                behTable(ceJ,6) = posFirst(end,2);
                
                behTable(ceJ+1,1) = posLast(1,1);
                behTable(ceJ+1,2) = posLast(end,2);
            else
                disp('Wrong num changes from start or end')
                keyboard
                %probably just take first in changes from start, last in changes from end
                %see commented out modification for ^^          and          ^^
            end     
    end  
%figure; imagesc(v0); hold on; plot(xAVI(behaviorMarker==5),yAVI(behaviorMarker==5),'.g')    
end
%Fill in last row
armEntries = enterArmEnd(enterArmEnd > leaveCenter(length(leaveCenter)));
armLeavings = leaveArmEnd(leaveArmEnd > leaveCenter(length(leaveCenter)));
if any(armEntries)
    behTable(length(leaveCenter),5) = armEntries(1);
    behTable(length(leaveCenter),6) = armLeavings(end);
else %probably carried through center? 
    keyboard
    behTable(length(leaveCenter),5) = NaN;
    behTable(length(leaveCenter),6) = NaN;
end

disp('Getting user input to refine off-maze time')
%Get user input on overlapped segments, check if mouse is on the maze
for ceK = 1:size(behTable,1)-1
    if behTable(ceK,5) == behTable(ceK+1,1) %|| behTable(ceK,6) == behTable(ceK+1,2)
        segsComp = [4 5; 2 3];
        for segI = 1:2
             stretchCheck = behTable(ceK+(segI-1),segsComp(segI,1)):behTable(ceK+(segI-1),segsComp(segI,2));
             midFrameInd = round(length(stretchCheck)/2);
             midFrameN = stretchCheck(midFrameInd);
             obj.CurrentTime = (midFrameN-1)/aviSR;
             midFrame = readFrame(obj);
             orFrame = figure('Position',[422 462 560 420]); imagesc(midFrame);
             usrApp = figure('Position',[1004 459 560 420]);%('Position',mcfOriginalSize);
             imagesc(midFrame); hold on
             plot(xAVI(stretchCheck(1:midFrameInd-1)),yAVI(stretchCheck(1:midFrameInd-1)),'og')
             plot(xAVI(stretchCheck(midFrameInd+1:end)),yAVI(stretchCheck(midFrameInd+1:end)),'or')
             plot(xAVI(midFrameN),yAVI(midFrameN),'*y')
             title(['Is this segment on the maze?  midFrame= ' num2str(midFrameN) ' (y/n) (input)'])
             ss = 'g';
             while (strcmpi(ss,'y') + strcmpi(ss,'n'))==0
                ss = input('Is this segment on the maze? (y/n) >>','s');
             end
             
             segsDel = [5 6; 1 2];
             if strcmpi(ss,'n')
                behTable(ceK+(segI-1),segsDel(segI,1)) = NaN;
                behTable(ceK+(segI-1),segsDel(segI,2)) = NaN;
                %Do the same thing for the segment preceeding this middle chunk
             end
             
             close(orFrame); close(usrApp);
        end  
    end
end

disp('Final refinement of behavior')
%parse this all out into onmaze time
onMazeTable = behTable(:,[1 6]);
onMazeTableEditor = behTable(:,[2 6]);
%if theres a nan, delete the lap
%if there are still repeats but no nans, it's an ongoing lap, 
%    can delete for onmaze and just get the first enter through last leave
nanRows = isnan(onMazeTableEditor(:,1)) | isnan(onMazeTableEditor(:,2)); 
onMazeTable(nanRows,:) = [];
onMazeTableEditor(nanRows,:) = [];

%Find instances where there are shared entries across a lap (ongoing on maze)
lookmatches = [onMazeTableEditor(1:end-1,2) onMazeTableEditor(2:end,1)];
matchedInd = lookmatches(:,1) == lookmatches(:,2);

lookmatches(matchedInd,:) = []; %#ok<NASGU>

onMazeReArr = [onMazeTable(1:end-1,2) onMazeTable(2:end,1)];
onMazeReArr(matchedInd,:) = [];

onMazeFinal = [[onMazeTable(1,1); onMazeReArr(:,2)], [onMazeReArr(:,1); onMazeTable(end,2)]];

%save beh.mat onMazeFinal behTable onMazeTable
end