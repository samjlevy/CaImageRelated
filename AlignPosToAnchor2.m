function AlignPosToAnchor2(ledPath,anchorPath)
% Assumes 1 epoch

%posLedPath = 'C:\Users\Sam\Desktop\marble19_190818\Marble19_190818_PosLED_temp.mat';
%anchorPath = 'C:\Users\Sam\Desktop\AddTmaze\MazeAlignmentTemplate.mat';

ledPathFile = ledPath;
if isempty(ledPath)
posLedPath = cd;
ledPathFile = ls(fullfile(posLedPath,'*PosLED_temp.mat'));
disp(['using ' ledPathFile])
end

load(ledPathFile,'xAVI','yAVI','avi_filepath','DVTtime','v0','onMaze')
load(anchorPath,'posAnchorIdeal')

numFrames = length(xAVI);
%How many instances are we aligning? (For multiple mazes in 1 video)
lfile = ledPathFile;
load(lfile,'onMaze')
eStart = find(onMaze,1,'first');
eEnd = find(onMaze,1,'last');
whichMaze = ones(1,numFrames);
epochs = [eStart eEnd];

%Get an image to align to.
oldImage = v0;
if ~iscell(v0)
    v0 = cell(1,1);
    [v0{:}] = deal(oldImage);
else
    v0 = oldImage;
end

x_adj_cm = nan(1,numFrames);
y_adj_cm = nan(1,numFrames);

doneAligning = 0;
while doneAligning == 0
    epochFrames = eStart:eEnd;
    disp(['Please get a background image for frames between ' num2str(eStart) ' and ' num2str(eEnd)])
    voFig = figure; imagesc(v0{1});
    useload = questdlg('Use v0, load v0, or remake?','Where v0?','Use','Load','Remake','Use');
    switch useload
        case 'Use'
            
        case 'Load'
            [ff,ll] = uigetfile(['Please locate the file ' lfile]);
            lfile = fullfile(ll,ff);
            aa = load(lfile,'v0');
            v0{epochI} = aa.v0;
            imagesc(v0{1});
    end
    adjGood = questdlg('Good or adjust?','Adjust','Good','Adjust','Good');
    close(voFig);
    if strcmpi(adjGood,'Adjust')
        if isempty(obj)
            obj = VideoReader(avi_filepath);
        end
        [v0{epochI}] = AdjustWithBackgroundImage(avi_filepath, obj, v0{epochI});
    end
    
    templateImage = figure('Position',[290 234 560 420]); %plot(posAnchorIdeal(:,1),posAnchorIdeal(:,2),'o','MarkerEdgeColor','r','MarkerSize',8)
    title('Target find the equivalent of the purple asterisk in reference image')
    ylim([min(posAnchorIdeal(:,2))-5 max(posAnchorIdeal(:,2))+5])
    xlim([min(posAnchorIdeal(:,1))-5 max(posAnchorIdeal(:,1))+5])
    posImage = figure('Position',[909 235 560 420]); imagesc(v0{1})
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
    
    anchors{1} = [xAnchor(:) yAnchor(:)];
    goodAlign = questdlg('Was this alignment good?','Good alignment','Yes','No','Yes');
    if strcmpi(goodAlign,'Yes')
        doneAligning = 1;
    end
    close(templateImage);
    close(posImage);
end

savePath = strsplit(ledPathFile,'\');
if length(savePath)==1
    savePath = cd;
else
    savePath = fullfile(savePath{1:end-1});
end
save(fullfile(savePath,'posAnchored.mat'),'v0','x_adj_cm','y_adj_cm','xAnchor','yAnchor','anchors',...
    'whichMaze','epochs','xAVI','yAVI','DVTtime','posAnchorIdeal','onMaze')

end



