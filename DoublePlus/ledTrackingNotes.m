pos_data = importdata('M11072118001.DVT');
pos_data2 = importdata('M11072118001-01.DVT');

obj = VideoReader('M11072118001.AVI');
aviSR = obj.FrameRate;
nFrames = obj.Duration*aviSR;  
frameSize = [obj.Height obj.Width];

%Get a background frame
h1 = implay('M11072118001.AVI');
v0 = readFrame(obj);

v0r = double(v0(:,:,1) - v0(:,:,3));
%v0g = double(v0(:,:,2) - v0(:,:,3));
v0g = double(v0(:,:,2));  

%Find the onmaze area
figure; imagesc(v0)
[BW,xi2,yi2] = roipoly;

v0g = v0g.*BW;
v0r = v0r.*BW;

nBrightPoints = 5;
    
%Get frames with mouse on the maze, ideally throughout the session
nTestFrames = 8;
tfEdges = linspace(1,nFrames,nTestFrames+1);
%Look at the brightness value for red and green leds
for tfI = 1:nTestFrames
    %Get the random frame
    mouseInFrame = 0;
    while mouseInFrame == 0
        rFrameNum = randi(round(tfEdges(tfI+1) - (tfEdges(tfI)-1))) + tfEdges(tfI);
        obj.CurrentTime = (rFrameNum-1)/aviSR;
        uFrame = readFrame(obj);
        gg = figure; imagesc(uFrame)
        ss = input('Is the mouse somewhere good in this frame? (y/n) >>','s')
        if strcmpi(ss,'y')
            mouseInFrame=1;
        end
        close(gg);
    end
    gg = figure; imagesc(uFrame)
    
    %Strip down frames, find max green and red
    uFrameR = double(uFrame(:,:,1) - uFrame(:,:,2)).*BW;
    uFrameG = double(uFrame(:,:,2)).*BW;
    %uFrameR = double(uFrame(:,:,1) - uFrame(:,:,3)).*BW;
    %uFrameG = double(uFrame(:,:,2) - uFrame(:,:,3)).*BW;
    
    %rfRsub = rFrameR - v0g;  
    rfRsub = uFrameR - v0r; rfRsub(rfRsub < 0) = 0;
    rfGsub = uFrameG - v0g; rfGsub(rfGsub < 0) = 0;
    
    rfGsub = uFrameG.*rfGsub;
    rfRsub = uFrameR.*rfRsub;
    
    %rfRsub = rfRsub - rfGsub;
    %rfRsub(rfRsub < 0) = 0;
    
    %Find the 5 reddest points in the subtraction frame, see which is brightest 
    [sortedRsubVals, sortOrderRsub] = sort(rfRsub(:),'descend');
    allIndR = sortOrderRsub(1:nBrightPoints);
    %figure; imagesc(uFrame); hold on; [ploty, plotx] = ind2sub(frameSize,allIndR); plot(plotx,ploty,'*c')
    
    %If there are 2 blobs, get the bigger one
    redBlobs = zeros(frameSize); redBlobs(allIndR) = 1; 
    redMaxBlobs = bwconncomp(redBlobs);
    [~,biggerRblob] = max(cell2mat(cellfun(@length,redMaxBlobs.PixelIdxList,'UniformOutput',false)));
    allIndR = redMaxBlobs.PixelIdxList{biggerRblob};

    %Find the 5 greenest points in the subtraction frame, see which is brightest 
    [sortedGsubVals, sortOrderGsub] = sort(rfGsub(:),'descend');
    allIndG = sortOrderGsub(1:nBrightPoints);
    %figure; imagesc(uFrame); hold on; [ploty, plotx] = ind2sub(frameSize,allIndG); plot(plotx,ploty,'*m')
    
    %If there are 2 blobs, get the bigger one
    greenBlobs = zeros(frameSize); greenBlobs(allIndG) = 1; 
    greenMaxBlobs = bwconncomp(greenBlobs);
    [~,biggerGblob] = max(cell2mat(cellfun(@length,greenMaxBlobs.PixelIdxList,'UniformOutput',false)));
    allIndG = greenMaxBlobs.PixelIdxList{biggerGblob};
    
        
    %grayFrame = rgb2gray(uFrame);    
    %[~,maxRedInd] = max(grayFrame(allIndR)); %Brightest red point in BW frame
    %[Rrind,Rcind] = ind2sub(frameSize,allIndR(maxRedInd));
    
    %Green done just by getting the most green
    %[~,maxGreenInd] = max(rfGsub(:));
    %[Grind,Gcind] = ind2sub(frameSize,maxGreenInd);
  
    %Check it's ok, if not do it manually
    [Rrind,Rcind] = ind2sub(frameSize,allIndR);
    redGood = 0;
    while redGood==0
        redF = figure; imagesc(uFrame); title(['Red Frame number ' num2str(rFrameNum)]); hold on
        plot(Rcind,Rrind,'og'); plot(Rcind,Rrind,'.g')
        sss = input('is this good?','s');
        if strcmpi(sss,'y')
            redGood = 1;
        elseif strcmpi(sss,'n')
            doneZoom = input('type Y when done zooming in for manual at pixel level','s');
            for pnR = 1:nBrightPoints
                [xx,yy] = ginput(1);
                Rcind(pnR) = round(xx); Rrind(pnR) = round(yy);
                plot(Rcind(pnR),Rrind(pnR),'og');plot(Rcind(pnR),Rrind(pnR),'.g')
            end
        end
        close(redF);
    end      
    
    greenGood = 0;
    [Grind,Gcind] = ind2sub(frameSize,allIndG);
    while greenGood==0
        greenF = figure; imagesc(uFrame); title(['Green Frame number ' num2str(rFrameNum)]); hold on
        plot(Gcind,Grind,'or'); plot(Gcind,Grind,'.r')
        sss = input('is this good?','s');
        if strcmpi(sss,'y')
            greenGood = 1;
        elseif strcmpi(sss,'n')
            doneZoom = input('type Y when done zooming in for manual at pixel level','s');
            for pnG = 1:nBrightPoints
                [xx,yy] = ginput(1);
                Gcind(pnG) = round(xx); Grind(pnG) = round(yy);
                plot(Gcind(pnG),Rrind(pnG),'or');plot(Gcind(pnG),Grind(pnG),'.r')
            end
        end
        close(greenF);
    end             
    
    close(gg);
    
    Rbrightness{tfI,1} = rfRsub(allIndR); 
    Gbrightness{tfI,1} = rfGsub(allIndG); 
    
    calibrateFrames(tfI,1) = rFrameNum;
    
    for uh = 1:length(Rrind)
        howRed{tfI,1}(uh,1) = double(uFrame(Rrind(uh),Rcind(uh),1));
        howGreen{tfI,1}(uh,1) = double(uFrame(Grind(uh),Gcind(uh),2));
    end
end

RbrightThresh = mean(Rbrightness) - std(Rbrightness); %Use in sub frame
GbrightThresh = mean(Gbrightness) - std(Gbrightness); %Use in sub frame

gMeans = cell2mat(cellfun(@mean,howGreen,'UniformOutput',false));
rMeans = cell2mat(cellfun(@mean,howRed,'UniformOutput',false));

howGreenThresh = mean(gMeans) - 2*std(gMeans); %Use in raw frame
howRedThresh =  mean(rMeans) - 2*std(rMeans); %Use in raw frame

testFrames = 2610:3600;
testFrames = 2610:2700;

scnsz = [1600 900];
figSize = [scnsz(1)/4 scnsz(2)/4-100 frameSize(2)*1.25 frameSize(1)*1.25];
posMethod = 'subtractOnly';
rawColorThresh = 1;
testFig = figure('Position',figSize);
for frameI = 1:length(testFrames)
    frameGet = testFrames(frameI);
    obj.CurrentTime = (frameGet - 1) / aviSR;
    uFrame = readFrame(obj);
    imagesc(uFrame); hold on
    %switch posMethod
    %    case 'subtractOnly'
            titleStr = ['Frame # ' num2str(frameGet) ', subtraction method'];
            
            uFrameR = double(uFrame(:,:,1) - uFrame(:,:,2)).*BW;
            uFrameG = double(uFrame(:,:,2)).*BW;
    
            rfRsub = uFrameR - v0r; rfRsub(rfRsub < 0) = 0;
            rfGsub = uFrameG - v0g; rfGsub(rfGsub < 0) = 0;
    
            rfRsub = uFrameR.*rfRsub;
            rfGsub = uFrameG.*rfGsub;
            
            if rawColorThresh == 1
                ufRthreshed = uFrame(:,:,1) > howRedThresh;
                ufGthreshed = uFrame(:,:,2) > howGreenThresh;
                
                rfRsub = rfRsub.*ufRthreshed;
                rfGsub = rfGsub.*ufGthreshed;
                
                titleStr = [titleStr ', threshed'];
            end
    
            title(titleStr)
            
            %Find the 5 reddest points in the subtraction frame, see which is brightest 
            [sortedRsubVals, sortOrderRsub] = sort(rfRsub(:),'descend');
            allIndR = sortOrderRsub(1:nBrightPoints);
    
            if rawColorThresh == 1
                allIndR(rfRsub(allIndR) == 0) = [];
            end
            
            %Get the biggest blob
            redBlobs = zeros(frameSize); redBlobs(allIndR) = 1; 
            redMaxBlobs = bwconncomp(redBlobs);
            [~,biggerRblob] = max(cell2mat(cellfun(@length,redMaxBlobs.PixelIdxList,'UniformOutput',false)));
            
            if any(biggerRblob)
                allIndR = redMaxBlobs.PixelIdxList{biggerRblob};

                %Convert to X/Y
                [redRowAll,redColAll] = ind2sub(frameSize,allIndR);
                redY = mean(redRowAll); redX = mean(redColAll);
            else
                redY = NaN; redX = NaN;
            end
                
            %Find the 5 greenest points in the subtraction frame, see which is brightest 
            [sortedGsubVals, sortOrderGsub] = sort(rfGsub(:),'descend');
            allIndG = sortOrderGsub(1:nBrightPoints);
            
            if rawColorThresh == 1
                allIndG(rfGsub(allIndG) == 0) = [];
            end
            
            %Get the biggest blob
            greenBlobs = zeros(frameSize); greenBlobs(allIndG) = 1; 
            greenMaxBlobs = bwconncomp(greenBlobs);
            [~,biggerGblob] = max(cell2mat(cellfun(@length,greenMaxBlobs.PixelIdxList,'UniformOutput',false)));
            
            if any(biggerGblob)
                allIndG = greenMaxBlobs.PixelIdxList{biggerGblob};
            
               %Convert to X/Y
               [greenRowAll,greenColAll] = ind2sub(frameSize,allIndG);
               greenY = mean(greenRowAll); greenX = mean(greenColAll);
            else
                greenY = NaN; greenX = NaN;
            end
            
            try 
                plot(redX, redY,'*c')
            catch
                disp(['Could not plot red frame ' num2str(frameGet)])
            end
            
            try 
                plot(greenX, greenY,'*m')
            catch
                disp(['Could not plot green frame ' num2str(frameGet)])
            end
            
            redXlong(frameI) = redX;
            redYlong(frameI) = redY;
            
            greenXlong(frameI) = greenX;
            greenYlong(frameI) = greenY;
            
        %case 'threshed'
        
    
    %end
    
    pause(0.200)
end




threshFig = figure('Position',[250 300 1550 475]);
ax1 = subplot(1,3,1); ax2 = subplot(1,3,2); ax3 = subplot(1,3,3);
ax1.Position = [0.025 0.05 0.28 0.9];
ax2.Position = [0.35 0.05 0.28 0.9];
ax3.Position = [0.7 0.05 0.28 0.9];
title(ax1,'Raw Frame'); title(ax2,'Red Thresh'); title(ax3,'Green Thresh')

for frameI = 1:length(testFrames)
    frameGet = testFrames(frameI);
    obj.CurrentTime = (frameGet - 1) / aviSR;
    uFrame = readFrame(obj);
    
    redFrame = uFrame(:,:,1);
    greenFrame = uFrame(:,:,2);
    
    redThreshed = redFrame > howRedThresh;
    greenThreshed = greenFrame > howGreenThresh;
    
    imagesc(ax1,uFrame)
    imagesc(ax2,redThreshed)
    imagesc(ax3,greenThreshed)
    
    pause(5)
end
    
    
    
    
    

%use that to get and idea of the range to expect

%test it on another 10 frames, get user approval

%if user says bad, raise the threshold

%Then i guess just run it on the whole session

%Next, we'll have to compare to existing DVT files



%Seems like 30 pixels might be ok for max jump between frames


%BoneYard
obj.CurrentTime = (2800-1)/aviSR;
tframe = readFrame(obj);
rminb = double(tframe(:,:,1) - tframe(:,:,3)); 

gminb = double(tframe(:,:,2) - tframe(:,:,3));

subg = gminb.*BW - v0g;
subg(subg<0) = 0;

colMax = max(subg,[],1);
rowMax = max(subg,[],2);
[~,cind] = max(colMax);
[~,rind] = max(rowMax);


    %[~,Rcind] = max(max(rfRsub,[],1));
    %[~,Rrind] = max(max(rfRsub,[],2));
    
    %[~,Gcind] = max(max(rfGsub,[],1));
    %[~,Grind] = max(max(rfGsub,[],2));
    
    %rfRtemp = rfRsub;
    %for bpI = 1:brightPoints
    %    [hMaxR(bpI),allIndR(bpI)] = max(rfRtemp(:));
    %    [ii(bpI),jj(bpI)] = ind2sub(frameSize,allIndR(bpI));
    %    rfRtemp(ii(bpI),jj(bpI)) = 0;
    %end