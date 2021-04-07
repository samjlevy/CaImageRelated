function GetRewardLimits

mazes = {'turnSmall','placeSmall','turnBig','placeBig'};
rewardLocs = {'East','West'};
startLocs = {'North','South'};

for mazeI = 1:length(mazes)
    if mazeI == 1
        load('F:\DoublePlus\smallPosAnchor.mat','posAnchorIdeal')
    elseif mazeI == 3
        load('F:\DoublePlus\mainPosAnchor.mat','posAnchorIdeal')
    end
    
    doThing = true;
    if mazeI == 4
       doThing = false;
       if strcmpi(input('Is this mouse a 2-maze animal? (y/n) >> ','s'),'y')
           doThing = true;
       end
    end
    
    if doThing == true
       
    disp(['Open folder with avi file for ' mazes{mazeI}])
    [gFile,gFolder] = uigetfile('*.AVI','Select video');
    cd(gFolder)
    
    PositionChecker;
    
    disp(['Folder is ' gFolder])
    
    posFile = dir('*PosLED_temp.mat');
    if length(posFile)~=1
        [pFile,pFolder] = uigetfile('*.mat','Select position file');
    elseif length(posFile)==1
        pFile = posFile.name;
    end
    load(pFile,'xAVI','yAVI','onMaze')
    
    disp(['Using this positions file: ' pFile])
    
    for sI = 1:length(startLocs)
        thisOnMaze = false;
        while thisOnMaze == false
            startFrame(sI) = str2double(input([...
                'Please enter on maze frame numer for START on arm: ' startLocs{sI} ': '],'s'));
            thisOnMaze = onMaze(startFrame(sI));
        end
        %startPosX(sI) = xAVI(startFrame(sI));
        %startPosY(sI) = yAVI(startFrame(sI));
    end
    
    for rI = 1:length(rewardLocs)
        thisOnMaze = false;
        while thisOnMaze == false
            rewardFrame(rI) = str2double(input([...
                'Please enter on maze frame numer for REWARD on arm: ' rewardLocs{rI} ': '],'s'));
            thisOnMaze = onMaze(startFrame(rI));
        end
        %rewardPosX(rI) = xAVI(rewardFrame(rI));
        %rewardPosY(rI) = yAVI(rewardFrame(rI));
    end
    
    disp('Select position anchored file')
    
    %[~,paDir] = uigetdir('Take us to directory with anchored pos');
    [paFile,paDir] = uigetfile('*.mat','Select position anchored file');
    cd(paDir)
    
    %{
    ppFile = dir('posAnchored.mat');
    if length(ppFile)~=1
        [paFile,pFolder] = uigetfile('*.mat','Select position file');
    elseif length(ppFile)==1 
        paFile = ppFile.name;
    end
    %}
    load(paFile,'x_adj_cm','y_adj_cm')
    
    startXadj{mazeI} = x_adj_cm(startFrame);
    startYadj{mazeI} = y_adj_cm(startFrame);
    rewardXadj{mazeI} = x_adj_cm(rewardFrame);
    rewardYadj{mazeI} = y_adj_cm(rewardFrame);
    
    
    %obj = VideoReader(avi_filepath);
    %aviSR = obj.FrameRate;
    %obj.CurrentTime = (bkgFrameNum-1)/obj.FrameRate;
    %backgroundImage = readFrame(obj);
    
    %tform = fitgeotrans([xAnchor(:) yAnchor(:)],posAnchorIdeal,'affine');
    %[x_adj_cm(epochFrames), y_adj_cm(epochFrames)] = transformPointsForward(tform,xAVI(epochFrames),yAVI(epochFrames));
    
    sisis = input('Close pos checker (any inpu)>>','s');
    end    
    
    
    
end

disp('Show us this mouse"s main folder')

[mDir] = uigetdir;
cd(mDir)
        
save('adjustedRewardLocations.mat','startXadj','startYadj','rewardXadj',...
            'rewardYadj','mazes','rewardLocs','startLocs') 
end  
%{
fileNums = {'180618','180620','180624','180626'}
for ii = 1:4
    startFrame = ppNums([1:2] + 4*(ii-1),1);
    rewardFrame = ppNums([3:4] + 4*(ii-1),1);
    cd(['F:\DoublePlus\Pandora\Pandora_' fileNums{ii}])

    load('posAnchored.mat','x_adj_cm','y_adj_cm')
    
    startXadj{mazeI} = x_adj_cm(startFrame);
    startYadj{mazeI} = y_adj_cm(startFrame);
    rewardXadj{mazeI} = x_adj_cm(rewardFrame);
    rewardYadj{mazeI} = y_adj_cm(rewardFrame);
end
%}