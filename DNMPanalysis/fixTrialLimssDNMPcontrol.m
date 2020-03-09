Pix2Cm = 0.0874;
RoomStr = '201a - 2015';
anchor_path = 'G:\SLIDE\Processed Data\Bellatrix\Bellatrix_160831';
xlims = [8 38];
mouseI = 4;
sessHere = FFsessions{mouseI};

for sessI = 1:length(sessHere)
cd(sessHere{sessI})
%Load all the shit for position correction
load('Pos.mat', 'xAVI', 'yAVI')
avis = ls('*.avi');
if size(avis,1)==1
    aviFile = avis;
else
    [fileF, folderF] = uigetfile('*.AVI','select avi to use');
    aviFile = fullfile(folderF,fileF);
end
obj = VideoReader(aviFile);

try
finalXL = ls('*_Finalized.xlsx');
firstXL = [finalXL(1:end-15) '.xlsx'];
sss = readtable(firstXL);
catch
    [fileF, folderF] = uigetfile('*.xlsx','select first excel to use');
    firstXL = fullfile(folderF,fileF);
    sss = readtable(firstXL);
end

%for each lap, manual correct from start on maze - 10 : start on maze
ff = figure('Position',[461 100 1086 786]); axis
for lapI = 1:height(sss)
    fGood = 0;
    while fGood == 0
        frameBounds = [];
        lbs = sss.StartOnMaze_startOfForced_(lapI);
        frameBounds = [frameBounds, (lbs-10):lbs];
        framesFix = fliplr(frameBounds);
        
        
        for ffI = 1:length(framesFix)
            frameI = framesFix(ffI);
            aviSR = obj.FrameRate;
            obj.CurrentTime = (frameI-1)/aviSR;
            frameHere = readFrame(obj);
            imagesc(ff.Children,frameHere)
            title(['Frame ' num2str(frameI) ', lap ' num2str(lapI) '/' num2str(height(sss))])
            if(xAVI(frameI)~=0 && yAVI(frameI)~=0)
                hold on
                plot(xAVI(frameI),yAVI(frameI),'or','MarkerFaceColor','r')
                hold off
            end
            [xAVI(frameI),yAVI(frameI)] = ginput(1);
            hold on;
            plot(xAVI(frameI),yAVI(frameI),'og','MarkerFaceColor','g')
            hold off
        end

        fff = lower(input('Was this good? (y/n) >>','s'));
        if strcmpi(fff,'y')
            fGood = 1;
        end
    end
end
close(ff);
save('Pos.mat','xAVI','yAVI','-append')

%Remake aligned data
rm = str2double(input('Remake adjusted positions? (0/1):','s'));
if rm==1
JustFToffset
AlignImagingToTracking2_SL
AlignPositions2_SL(anchor_path, cd, RoomStr) %Should be updated to load existing anchors
end

%load adjusted-2
adjTwoFile = ls('*Adjusted-2.xlsx');
ttt = readtable(adjTwoFile);
load('Pos_align.mat','x_adj_cm','y_adj_cm')

for lapI = 1:height(ttt) %each lap check we have an x pos before and after lims
    lapInds = ttt.StartOnMaze_startOfForced_(lapI):ttt.ChoiceEnter(lapI);
    xHere = x_adj_cm(lapInds); yHere = y_adj_cm(lapInds);
    haveMinX = any(xHere<=min(xlims));
    haveMaxX = any(xHere>=max(xlims));
    
    if haveMinX==0
        possibleStart = find(x_adj_cm((lapInds(1)-100):lapInds(1)) <= min(xlims),1,'last');
        if any(possibleStart)
            possibleStart = lapInds(1)-100+possibleStart-1;
        end
        
        if any(possibleStart) == 0
            possibleStart = lapInds(1);
        end
        
        % plot, ask for approval, adjust from there
        bl = figure;  title(['Finding a start for lap ' num2str(lapI)])
        notDone = 1;
        possibleEnd = lapInds(end);
        while notDone == 1
            pp = possibleStart:possibleEnd;
            figure(bl); hold off
            set(bl.Children,'Color',[0.8 0.8 0.8]);
            hold on
            plot(bl.Children,x_adj_cm,y_adj_cm,'.k')
            title(['Finding a start for lap ' num2str(lapI)])
            plot(bl.Children,x_adj_cm(pp),y_adj_cm(pp),'.m','MarkerSize',6)
            plot(bl.Children,x_adj_cm(pp([1 end])),y_adj_cm(pp([1 end])),'.y','MarkerSize',6)
            plot(xlims(1)*[1 1],bl.Children.YLim,'r')
            plot(xlims(2)*[1 1],bl.Children.YLim,'r')
            hold off
            adjH = lower(input('Adjust start back/forawrd/done (a/d/m)>>','s'));
            switch adjH
                case 'a'
                    possibleStart = possibleStart - 1;
                case 'd'
                    possibleStart = possibleStart + 1;
                case 'm'
                    notDone = 0;
            end
        end
        lapInds = possibleStart:possibleEnd;
        close(bl);
    end
    
    if haveMaxX==0
        possibleEnd = find(x_adj_cm(lapInds(end):(lapInds(end)+100)) >= max(xlims),1,'first');
        
        if any(possibleEnd)
            possibleEnd = lapInds(end)+possibleEnd-1;
        end
        
        if any(possibleEnd) == 0
            possibleEnd = lapInds(end);
        end
        % plot, ask for approval, adjust from there
        bl = figure; title(['Finding an end for lap ' num2str(lapI)])
        notDone = 1;
        possibleStart = lapInds(1);
        while notDone == 1
            pp = possibleStart:possibleEnd;
            figure(bl); hold off
            set(bl.Children,'Color',[0.8 0.8 0.8]);
            hold on
            plot(bl.Children,x_adj_cm,y_adj_cm,'.k')
            title(['Finding an end for lap ' num2str(lapI)])
            plot(bl.Children,x_adj_cm(pp),y_adj_cm(pp),'.m','MarkerSize',6)
            plot(bl.Children,x_adj_cm(pp([1 end])),y_adj_cm(pp([1 end])),'.y','MarkerSize',6)
            plot(xlims(1)*[1 1],bl.Children.YLim,'r')
            plot(xlims(2)*[1 1],bl.Children.YLim,'r')
            hold off
            adjH = lower(input('Adjust start back/forawrd/done (a/d/m)>>','s'));
            switch adjH
                case 'a'
                    possibleEnd = possibleEnd - 1;
                case 'd'
                    possibleEnd = possibleEnd + 1;
                case 'm'
                    notDone = 0;
            end
        end
        lapInds = possibleStart:possibleEnd;
        close(bl);
    end
    
    ttt.StartOnMaze_startOfForced_(lapI) = lapInds(1);
    ttt.ChoiceEnter(lapI) = lapInds(end);
end

tttCell = table2cell(ttt);
[~,txt] = xlsread(adjTwoFile,1);
coltxt = [txt(1,:)];
tttCell = [coltxt; tttCell];
xlswrite(adjTwoFile,tttCell,1);
DNMPexcelCombiner(cd)
ExcelFinalizer(cd)

disp(['Done with sess ' num2str(sessI) ', ' sessHere{sessI}])
end

%% Fix polaris 160829
%Recording 1: 11252 + 40 frames, ends at   06:55:30.911000 PM, starts at 06:45:09.415000 PM
%Recording 2: 22484 + 39 frames, starts at 06:55:54.232000 PM,   ends at 07:14:40.692000 PM

%54.232-30.911 = 23.3210 seconds deficit
%PSAbool is 33815 frames long = 11252 + 40 + 22484 + 39
%23.3210 s *20 f/s = 446.420 frames add
PSAboolOriginal = PSAbool;
PSAbool = [PSAboolOriginal(:,1:(11252+40)),...
           zeros(size(PSAboolOriginal,1),446),... %added in 446 frames
           PSAboolOriginal(:,(11252+40+1):end)];
ss = fieldnames(NeuronTraces);
NeuronTracesOriginal = NeuronTraces;
for ssI = 1:length(ss)
    NeuronTraces.(ss{ssI}) =...
        [NeuronTracesOriginal.(ss{ssI})(:,1:(11252+40)),...
         zeros(size(PSAboolOriginal,1),446),... %added in 446 frames
         NeuronTracesOriginal.(ss{ssI})(:,(11252+40+1):end)];
end
excludeFrames = [zeros(1,11252+40) ones(1,446) zeros(1,22484 + 39)];

save('FinalOutput.mat','PSAbool','NeuronTraces','-append')
save exlcudeFrames.mat excludeFrames

%% Fix Bellatrix 160829
PSAbool = PSAbool(:,1:35693);
ss = fieldnames(NeuronTraces);
for ssI = 1:length(ss)
    NeuronTraces.(ss{ssI}) =...
        NeuronTraces.(ss{ssI})(:,1:35693);
end
save('FinalOutput.mat','PSAbool','NeuronTraces','-append')