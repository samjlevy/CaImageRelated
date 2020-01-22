function [onMazeFinal,behTable] = ParsePlusMazeBehavior2(posLEDfile,posAnchoredFile)
%THis function is designed to parse out plus maze behavior given good
%position data
%Assumes you will have PositionChecker open to validate possible bad trials

disp('parsing on mazeBehavior')
load(posLEDfile,'onMaze')
load(posAnchoredFile,'x_adj_cm','y_adj_cm','epochs','posAnchorIdeal','rewardXadj','rewardYadj')
%load(idealAnchorFile)
numEpochs = size(epochs,1);

%Define generous arm regions3
overZero = posAnchorIdeal(:,1)>0;
centerDim = min(posAnchorIdeal(overZero,1));
centerBuffer = 5;
centerDim = centerDim + 5;
centerBounds = [-centerDim, -centerDim;...
                -centerDim, centerDim;...
                centerDim, centerDim;...
                centerDim, -centerDim];
armDim = max(posAnchorIdeal(:,1));
armBuffer = 200;
armDim = armDim + armBuffer;
armBounds = {[-centerDim,centerDim;...
                -armDim, armDim;...
                armDim, armDim;...
                centerDim, centerDim];... 
                [centerDim, centerDim;...
                armDim, armDim;...
                armDim, -armDim;...
                centerDim, -centerDim];...
                [-centerDim,-centerDim;...
                -armDim, -armDim;...
                armDim, -armDim;...
                centerDim, -centerDim];...
                [-centerDim, centerDim;...
                -armDim, armDim;...
                -armDim, -armDim;...
                -centerDim, -centerDim]};
armLabels = {'north','east','south','west'};

%Do all sequences, then break into epochs
lapBoundary  = 'onMaze';
switch lapBoundary
    case 'onMaze'
        onMazeStarts = [];
        onMazeStops = [];
        if any(onMaze)
            onMazeStarts = find(diff(onMaze,1,1)==1)+1;
            onMazeStops = find(diff(onMaze,1,1)==-1);
        end
    case 'pedestal'
        
    case 'knownStartStop'
        
end
    
%Possible to somehow to multiple lap boundaries? Some how integrate them...
seqID = zeros(1,length(x_adj_cm));
sequence = {centerBounds,armBounds{:}};
for sI = 1:length(sequence)
    [inArea,~] = inpolygon(x_adj_cm,y_adj_cm,sequence{sI}(:,1),sequence{sI}(:,2));
    seqID(inArea) = sI;
end

%For each on maze epoch, get the sequence of regions the mouse is in the maze
flickerThresh = 5; %number of consecutive frames can jump back and forth between regions
for omI = 1:length(onMazeStarts)
    framesHere = onMazeStarts(omI):onMazeStops(omI);
    seqHere = seqID(framesHere);

    %getStartStop for each region transition
    [uniqueSeq,seqEpochs] = filterSeqToUnique(seqHere);
    seqDurs = diff(seqEpochs,1,2);
    
    %any that are <= flicker thresh get cut,
    tooShort = seqDurs<=flickerThresh;
    uniqueSeq(tooShort) = [];
    seqEpochs(tooShort,:) = [];
    
    %{
    if sum(uniqueSeq==1)<1
        disp(['This sequence does not have a maze middle bit, frames ' num2str([framesHere(1) framesHere(end)])])
        
        keepS = input('Keep it (y/n)?>> ','s');
        if strcmpi(keepS,'n')
            uniqueSeq = [];
        end
    end
    %}
    
    if any(uniqueSeq)
        trialSeqs{omI} = uniqueSeq;
        trialSeqEpochs{omI} = framesHere(seqEpochs);
    else
        keyboard
    end
end

frameStartBuffer = 10;
rewardRadius = 2;
rewardGetAdjust = 0;
endsInMid = [];
for trialI = 80:length(trialSeqs)
    %Get the arm id where the animal finished
    
    lastArm = trialSeqs{trialI}(end)-1; %-1 bc have mid + 4 arms
    lastArmInd = length(trialSeqs{trialI});
    if lastArm==1 || lastArm==0
        disp('Mouse ends in the middle?')
        %keyboard
        disp('Assuming last arm entry')
        trialSeqUse = trialSeqs{trialI}(trialSeqs{trialI}>1);
        lastArm = trialSeqUse(end)-1;
        lastArmInd = find(trialSeqs{trialI}>1,1,'last');
        endsInMid = [endsInMid; trialI];
    end
    
    %Get which epoch/maze/reward marker set to use
    frameLook = trialSeqEpochs{trialI}(1,1)+frameStartBuffer;
    thisEpoch = find((frameLook > epochs(:,1)) & (frameLook < epochs(:,2)));
    
    %Get the first frame where the animal is within range of the reward zone
    lastFrames = trialSeqEpochs{trialI}(lastArmInd,1):trialSeqEpochs{trialI}(lastArmInd,2);
    lastDistances = hypot(rewardXadj{thisEpoch}(lastArm) - x_adj_cm(lastFrames),...
                          rewardYadj{thisEpoch}(lastArm) - y_adj_cm(lastFrames));
    withinRad = lastDistances < rewardRadius;
    rewardEnterFrame = lastFrames(find(withinRad,1,'first'));
    if isempty(rewardEnterFrame)
        disp('No reward entry')
        %keyboard
        
        figfig=figure; plot(x_adj_cm(logical(onMaze)),y_adj_cm(logical(onMaze)),'.')
        hold on
        plot(x_adj_cm(lastFrames),y_adj_cm(lastFrames),'.r')
        plot(rewardXadj{thisEpoch}(lastArm),rewardYadj{thisEpoch}(lastArm),'*m')
        [xx,yy] = ginput(1);
        ptpt = findclosest2D(x_adj_cm(lastFrames),y_adj_cm(lastFrames),xx,yy);
        plot(x_adj_cm(lastFrames(ptpt)),y_adj_cm(lastFrames(ptpt)),'*c')
        plot(x_adj_cm(lastFrames(1:ptpt)),y_adj_cm(lastFrames(1:ptpt)),'.c')
        
        keepGoing = 0;
        while keepGoing==0 
            keepGoing = str2double(input('keep going?','s')); 
            if keepGoing==5
                keyboard
            end
        end
        
        close(figfig);
        rewardEnterFrame = lastFrames(ptpt);
        
    end
       
    %Adjust forward some number of frames
    rewardEnterFrame = rewardEnterFrame + rewardGetAdjust;
    
    %trial start is first frame here, last is the adjusted forwards
    trialBounds{trialI} = [frameLook rewardEnterFrame];
    trialEpoch(trialI,1) = thisEpoch;
end
        
save('plusMazeBehavior.mat','trialEpoch','trialBounds','trialSeqs','trialSeqEpochs')    
    
    
end