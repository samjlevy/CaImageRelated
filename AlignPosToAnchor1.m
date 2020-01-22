function AlignPosToAnchor1(ledPath,anchorPath)

%posLedPath = 'C:\Users\Sam\Desktop\marble19_190818\Marble19_190818_PosLED_temp.mat';
%anchorPath = 'C:\Users\Sam\Desktop\AddTmaze\MazeAlignmentTemplate.mat';

if isempty(ledPath)
ledPathFile = ls(fullfile(posLedPath,'*PosLED_temp.mat'));
disp(['using ' ledPathFile'])
end

load(ledPathFile,'xAVI','yAVI','avi_filepath','DVTtime','v0')
load(anchorPath,'posAnchorIdeal')

numFrames = length(xAVI);
%How many instances are we aligning? (For multiple mazes in 1 video)
numEpochs = str2double(input('How many epochs on different mazes are there? >> ','s'));

try
obj = VideoReader(avi_filepath);
catch
    [ff,ll] = uigetfile(['Please locate the file ' avi_filepath]);
    avi_filepath = fullfile(ll,ff);    
end
h1 = implay(avi_filepath);

%For each instance: 
% what are the frame number for this maze epoch?
whichMaze = zeros(1,numFrames);
for epochI = 1:numEpochs
    eStart(epochI) = str2double(input(['Enter start frame number for epoch ' num2str(epochI) ' >>'],'s'));
    eEnd(epochI) = str2double(input(['Enter end frame number for epoch ' num2str(epochI) ' >>'],'s'));
    
    epochs(epochI,:) = [eStart(epochI) eEnd(epochI)];
    whichMaze(eStart(epochI):eEnd(epochI)) = epochI;
end
try
close(h1)
end

%Get an image to align to.
oldImage = v0;
if ~iscell(v0)
    v0 = cell(numEpochs,1);
    [v0{:}] = deal(oldImage);
else
    v0 = oldImage;
end

x_adj_cm = nan(1,numFrames);
y_adj_cm = nan(1,numFrames);
obj = VideoReader(avi_filepath);
for epochI = 1:numEpochs
    doneAligning = 0;
    while doneAligning == 0
    epochFrames = eStart(epochI):eEnd(epochI);
    disp(['Please get a background image for epoch ' num2str(epochI) ...
        ', frames between ' num2str(eStart(epochI)) ' and ' num2str(eEnd(epochI))])
    [v0{epochI}] = AdjustWithBackgroundImage(avi_filepath, obj, v0{epochI});
    
    templateImage = figure('Position',[290 234 560 420]); %plot(posAnchorIdeal(:,1),posAnchorIdeal(:,2),'o','MarkerEdgeColor','r','MarkerSize',8)
    title('Target find the equivalent of the purple asterisk in reference image')
    ylim([min(posAnchorIdeal(:,2))-5 max(posAnchorIdeal(:,2))+5])
    xlim([min(posAnchorIdeal(:,1))-5 max(posAnchorIdeal(:,1))+5])
    posImage = figure('Position',[909 235 560 420]); imagesc(v0{epochI})
    hold on
    title('Click here to set the anchor')
    
    %Get anchor pts for these:
    xAnchor = []; yAnchor = [];
    for anchorI = 1:size(posAnchorIdeal,1)
        %Highlight the point to get in the template image
        %Highlight older points in one color, pts to get in another
        figure(templateImage);
        hold off
        plot(posAnchorIdeal(anchorI,1),posAnchorIdeal(anchorI,2),'m*','MarkerSize',8)
        ylim([min(posAnchorIdeal(:,2))-5 max(posAnchorIdeal(:,2))+5])
        xlim([min(posAnchorIdeal(:,1))-5 max(posAnchorIdeal(:,1))+5])
        hold on
        if anchorI>1
        plot(posAnchorIdeal(1:anchorI-1,1),posAnchorIdeal(1:anchorI-1,2),'o','MarkerFaceColor','g','MarkerSize',8)
        end
        if anchorI<size(posAnchorIdeal,1)
        plot(posAnchorIdeal(anchorI+1:end,1),posAnchorIdeal(anchorI+1:end,2),'o','MarkerEdgeColor','r','MarkerSize',8)
        end
        
        %Ask for the same point on the background image
        figure(posImage);
        [xAnchor(anchorI),yAnchor(anchorI)] = ginput(1);
        plot(xAnchor(anchorI),yAnchor(anchorI),'r+')
    end
    
    
    tform = fitgeotrans([xAnchor(:) yAnchor(:)],posAnchorIdeal,'affine');
    [x_adj_cm(epochFrames), y_adj_cm(epochFrames)] = transformPointsForward(tform,xAVI(epochFrames),yAVI(epochFrames));
    
    anchors{epochI} = [xAnchor(:) yAnchor(:)];
    goodAlign = questdlg('Was this alignment good?','Good alignment','Yes','No','Yes');
    if strcmpi(goodAlign,'Yes')
        doneAligning = 1;
    end
    close(templateImage);
    close(posImage);
    end
end

%savePath = strsplit(posLedPath,'\');
%savePath = fullfile(savePath{1:end-1});
savePath = ledPath;
save(fullfile(savePath,'posAnchored.mat'),'v0','x_adj_cm','y_adj_cm','xAnchor','anchors',...
    'whichMaze','epochs','xAVI','yAVI','DVTtime','posAnchorIdeal')

end



