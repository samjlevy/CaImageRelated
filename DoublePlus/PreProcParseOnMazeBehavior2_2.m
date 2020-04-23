function [onMazeFinal] = PreProcParseOnMazeBehavior2_2(xAVI,yAVI,v0,obj)
%THis function is designed to parse out plus maze behavior, but handles
%data that doesn't have good onmaze time yet

disp('parsing on mazeBehavior')
if ischar(obj)
    obj = VideoReader(obj);
end
aviSR = obj.FrameRate;

%Find epochs of missing points based on expected plus maze behavior
ff = figure('Position',[562 183 821 682]);
imagesc(v0);
title('Draw boundary for maze center')
figure(ff);
[~,centerX,centerY,] = roipoly;
close(ff);

nMazeEnds = str2double(input('How many possible start/end locations are there?','s'));
for slI = 1:nMazeEnds
    ff = figure('Position',[562 183 821 682]); imagesc(v0); title(['Draw boundary for start area ' num2str(slI)])
    [~,endX{slI},endY{slI}] = roipoly; %#ok<AGROW>
    close(ff);
end

pedExist = strcmpi(input('Is there a pedestal (or equivalent) between-trial area? (y/n)>> ','s'),'y');
if pedExist
    ff = figure('Position',[562 183 821 682]); imagesc(v0); title(['Draw pedestal area'])
    [~,pedsX,pedsY] = roipoly; %#ok<AGROW>
    close(ff);
end

ff = figure('Position',[562 183 821 682]); imagesc(v0); title(['Draw Maze Boundary'])
[~,mazeX,mazeY] = roipoly;
close(ff);

disp('Now parsing maze center - arm end epochs')
minCenterDur = 2;

ff = figure('Position',[562 183 821 682]); imagesc(v0); hold on
velGood = 0;
while velGood==0
    for pt = 1:2
        title(['Getting a velocity limit: click ' num2str(pt) ' of 2 points for max dist between frames'])
        [velX(pt),velY(pt)] = ginput(1);
        plot(velX(pt),velY(pt),'.r')
    end
    plot(velX,velY,'Color',[1 1 1])
    
    velLim = hypot(abs(diff(velX)),abs(diff(velY)));
    title(['Velocity limit is now: ' num2str(velLim)])
    velGood = str2double(strcmpi(input('Is this velocity limit good or redo? (y/n)>> ','s'),'y'));
end
        
veloc = hypot(diff(xAVI),diff(yAVI));
highVeloc = veloc > velLim;
highVel = [0; highVeloc(:)] | [highVeloc(:); 0]; %Don't know which frame is the bad one
lowVel = ~highVel;

%Get each maze epoch; mark each with a diff number
inCenter = inpolygon(xAVI,yAVI,centerX,centerY);
enterCenter = find(diff([0; inCenter(:); 0]) == 1);
leaveCenter = find(diff([0; inCenter(:); 0]) == -1) -1;

onPedestal = false(length(xAVI),1); 
enterPed = [];
leavePed = [];
if pedExist
	onPedestal = inpolygon(xAVI,yAVI,pedsX,pedsY);
    enterPedestal = find(diff([0; onPedestal(:); 0]) == 1);
    leavePedestal = find(diff([0; onPedestal(:); 0]) == -1) -1;
end

behaviorMarker = double(inCenter);
behaviorMarker(onPedestal) = 2;
for bbxI = 1:length(endX)
    inHere = inpolygon(xAVI,yAVI,endX{bbxI},endY{bbxI});
    behaviorMarker(inHere) = bbxI+2;
end

%Filter out highVelocity frames
behaviorMarker(highVel) = 0;

%Core sequence filtering operation
bmFrames = 1:length(behaviorMarker);
bmFrames(behaviorMarker==0) = [];
behaviorMarker(behaviorMarker==0) = [];
bmFrames(behaviorMarker==0) = [];
[uniqueSeq,epochs] = filterSeqToUnique(behaviorMarker); 
epochs(uniqueSeq==0,:) = [];
%uniqueSeq(uniqueSeq==0) = []; %Already deleted 0s

%armIDs = 3:2+length(endX);
%usArm = sum(uniqueSeq==armIDs',1)>0; %These entries are arms
%usArm = uniqueSeq > 2;

%Possible lap bounds include
%Get sequences arm-center-arm until either 
bmCentPedArm = uniqueSeq; 
bmCentPedArm(uniqueSeq > 2) = 3; %All arms marked 3
[acaEpochs,acaInSeq] = slidingWindowMatch(bmCentPedArm,[3 1 3]); %arm-center-arm

%Extend epochs where mouse "escaped" to center before retrieval"
[acpEpochs,acpInSeq] = slidingWindowMatch(bmCentPedArm,[3 1 2]); %arm-center-pedestal
onMazeSeq = acaInSeq | acpInSeq;
onMazeEpochs = [acaEpochs; acpEpochs];
isAcp = [false(1,size(acaEpochs,1)), true(1,size(acpEpochs,1))];

manApprove = strcmpi(input('Want to approve all center passes? (y/n)>> ','s'),'y');
if manApprove
    openNN = strcmpi(input('Recommended to open positionChecker. Do it? (y/n)>> ','s'),'y');
    if openNN
        PositionChecker
    end
end
onMazeFinal = false(size(xAVI));
onMazeEpochsFinal = [];
for epochI = 1:size(onMazeEpochs,1)
    omes = onMazeEpochs(epochI,:);
    lStart = bmFrames(epochs(omes(1),1))
    lEnd = bmFrames(epochs(omes(2),2))
    if isAcp(epochI)
        lEnd = bmFrames(epochs(mean(omes),2));
    end
    
    skipE = false;
    if manApprove
        middleHere = bmFrames(epochs(mean(omes),:));

        stretchCheck = middleHere(1):middleHere(2);
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
            skipE = true;
        end

        close(orFrame); close(usrApp);
    end
    
    if skipE==false
        onMazeFinal(lStart:lEnd) = true;
        %onMazeEpochsFinal = [onMazeEpochsFinal; lStart lEnd];
    end
end

mazeOns = find(diff([0; onMazeFinal])==1);
mazeOffs = find(diff([onMazeFinal; 0])==-1);
onMazeEpochsFinal = [mazeOns, mazeOffs];

%Verify off too
appOm = strcmpi(input('Do you want to approve off-maze epochs? (y/n)>> ','s'),'y');
if appOm
    omEpochs = [ [1;onMazeEpochsFinal(:,2)], [onMazeEpochsFinal(:,1);length(xAVI)] ];

    cpI = 1;
    while cpI <size(omEpochs,1)+1
        stOm = NaN;
        stretchCheck = omEpochs(cpI,1):omEpochs(cpI,2);
        
        doneOnMaze = 0;
        while doneOnMaze==0
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
            title(['Is this segment off the maze?  midFrame= ' num2str(midFrameN) ' (y/n) (input)'])
            ss = 'g';
            while (strcmpi(ss,'y') + strcmpi(ss,'n'))==0
                ss = input('Is this segment off the maze? (y/n) >>','s');
                if strcmpi(ss,'y'); doneOnMaze=1; end
            end

            if strcmpi(ss,'n')
                disp(['Stretch begins at ' num2str(stretchCheck(1)) ', ends at ' num2str(stretchCheck(end))])
                mStart = str2double(input('What frame does this onMaze epoch start?>>','s'));
                mStop = str2double(input('What frame does this onMaze epoch stops?>>','s'));
                stretchView = mStart:mStop;
                midFrameInd = ceil(length(stretchView)/2);
                midFrameN = stretchView(midFrameInd);
                obj.CurrentTime = (midFrameN-1)/aviSR;
                midFrame = readFrame(obj);
                forFrame = figure('Position',[422 462 560 420]); imagesc(midFrame); title(['Middle frame ' num2str(midFrameN)])
                fusrApp = figure('Position',[1004 459 560 420]);
                imagesc(midFrame); hold on;
                plot(xAVI(stretchView(1:midFrameInd-1)),yAVI(stretchView(1:midFrameInd-1)),'og')
                plot(xAVI(stretchView(midFrameInd+1:end)),yAVI(stretchView(midFrameInd+1:end)),'or')
                plot(xAVI(midFrameN),yAVI(midFrameN),'*y')
                title(['Does this look ok?  midFrame= ' num2str(midFrameN) ' (y/n) (input)'])
                tt = input('Does this look ok? (y/n)>> ','s');
                if strcmpi(tt,'y')
                    onMazeFinal(mStart:mStop) = true;
                    close(forFrame); close(fusrApp);
                    goodF = sum(stretchCheck(:)==[mStart:mStop],2)==1;
                    stretchCheck(goodF) = [];
                    if isempty(stretchCheck)
                        keyboard
                        doneOnMaze=1;
                    end
                else
                    keyboard;
                end
            end
            close(orFrame); close(usrApp);
        end

        cpI = cpI + 1;
    end
end
    
save beh.mat onMazeFinal 
end