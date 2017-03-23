%% Maybe better to step back and do the calcs from the beginning
% from DNMP_parse_trials
correctOnlyFlag=1; %right now pulls out correct trials, doesn't yet segregate 
%incorrect trials for their own analysis

xls_sheet_num=1;
xls_bonus_sheet_num=1;

folderUse='D:\bits160831\';
%folderUse='C:\MasterData\InUse\Polaris_160831\';

xls_path=fullfile(folderUse,'DNMPsheet.xlsx');
xls_bonus_path=fullfile(folderUse,'DNMPbonus.xlsx');

[frames, txt] = xlsread(xls_path, xls_sheet_num);
[bonusFrames, bonusTxt] = xlsread(xls_bonus_path, xls_bonus_sheet_num);

pos_file_fullpath=fullfile(folderUse,'Pos.mat');%NOT pos_align
load(pos_file_fullpath,'time_interp','AVItime_interp')
% pos_data = importdata(DVT_fullpath);

load(fullfile(folderUse,'Pos_align.mat'),'x_adj_cm','y_adj_cm',...
    'FT','FToffset','FToffsetRear');

%% Adjust for FToffset
%Should check the results by plotting things 
longFrames = frames(:,2:end); 
longBrainFrames = AVI_to_brain_frame(longFrames(:), AVItime_interp);
longBrainOffset = longBrainFrames - FToffset + 2;
longBrainOffset(longBrainOffset<1) = 1; 
longBrainOffset(longBrainOffset>length(x_adj_cm)) = length(x_adj_cm);
frames(:,2:end) = reshape(longBrainOffset,[size(frames,1),size(frames,2)-1]);

longBonusFrames = bonusFrames(:,2:end); 
longBonusBrainFrames = AVI_to_brain_frame(longBonusFrames(:), AVItime_interp);
longBonusBrainOffset = longBonusBrainFrames - FToffset + 2;
longBonusBrainOffset(longBonusBrainOffset<1) = 1; 
longBonusBrainOffset(longBonusBrainOffset>length(x_adj_cm)) = length(x_adj_cm);
bonusFrames(:,2:end) =...
    reshape(longBonusBrainOffset, [size(bonusFrames,1), size(bonusFrames,2)-1]);

disp('Using cheater edge trimming')
%% parse spreadsheets
num_brain_frames = length(AVItime_interp);
columnLabel = {'Start on maze (start of Forced', 'Lift barrier (start of free choice)',...
               'Leave maze', 'Start in homecage', 'Leave homecage',...
               'Forced Trial Type (L/R)', 'Free Trial Choice (L/R)',...
               'Enter Delay', 'Forced Choice', 'Free Choice',...  
               'Forced Reward', 'Free Reward'};
[ framesLabelIndex ] = ConditionalExcellParseout( txt, columnLabel);
blocks = frames(:,1);
forced_start = frames(:,2);
free_start = frames(:,3);
leave_maze = frames(:,4);
cage_start = frames(:,5);
cage_leave = frames(2:end,6);
delay_start = bonusFrames(:,2);
delay_end = free_start;
forced_end = delay_start;
free_end = leave_maze;

  
%% logicals for lap type
right_trials_forced = strcmpi(txt(2:end,7),'R');
    delay_following_r = right_trials_forced;
right_trials_free = strcmpi(txt(2:end,8),'R');
    cage_following_r = right_trials_free;
left_trials_forced = strcmpi(txt(2:end,7),'L'); 
    delay_following_l = left_trials_forced;
left_trials_free = strcmpi(txt(2:end,8),'L');
    cage_following_l = left_trials_free;
correct_trials = right_trials_forced & left_trials_free | ...
    left_trials_forced & right_trials_free;

%% get some frame numbers 
if correctOnlyFlag==0
    correct_trials(:)=1;
end

forced_r_start = forced_start(right_trials_forced & correct_trials);
forced_r_end = forced_end(right_trials_forced & correct_trials);
forced_l_start = forced_start(left_trials_forced & correct_trials);
forced_l_end = forced_end(left_trials_forced & correct_trials);
free_r_start = free_start(right_trials_free & correct_trials);
free_r_end = free_end(right_trials_free & correct_trials);
free_l_start = free_start(left_trials_free & correct_trials);
free_l_end = free_end(left_trials_free & correct_trials);
delay_afterl_start = delay_start(left_trials_forced & correct_trials);
delay_afterl_end = delay_end(left_trials_forced & correct_trials);
delay_afterr_start = delay_start(right_trials_forced & correct_trials);
delay_afterr_end = delay_end(right_trials_forced & correct_trials);
%cage epochs too
%also need reward get
%%
blockTypes={'forced r', 'free r', 'forced l',  'free l'};
            %'delay after r', 'delay after l', 'choice after r', 'choice after l'}; 

blocksLeft=[-1 -1 1 1];%0 1 0 0]; %1 = left, -1 = r, 0 = don't use
blocksForced=[1 -1 1 -1];%0 0 0 0]; %not sure how to handle these 
    %1 = forced, -1 = unforced, 0 = don't use

trial_block_inds=cell(1,4);
trial_block_inds{1,1}=[forced_r_start, forced_r_end];
trial_block_inds{1,2}=[free_r_start, free_r_end];
trial_block_inds{1,3}=[forced_l_start, forced_l_end];
trial_block_inds{1,4}=[free_l_start, free_l_end];
    


%% Get some cell activity vectors
%% All cell activity
BFTindices=[];
for blockNum=1:length(blockTypes)
    blockStart(blockNum)=length(BFTindices)+1;
    for trialNum=1:size(trial_block_inds{1,blockNum},1)
        theseInds = trial_block_inds{1,blockNum}(trialNum,1):...
           trial_block_inds{1,blockNum}(trialNum,2);
        BFTindices=[BFTindices, theseInds];
    end
    blockEnd(blockNum)=length(BFTindices);
end
%Need to trim frames ends for this to work

BlockedFT = FT(:,BFTindices);
    
%% Number of times a cell fired on a trial, also as probability
BlockedFThits = cell(1,4);
BlockedFTprob = cell(1,4);
for blockNum = 1:length(blockTypes)
   hitsHolder = zeros(size(FT,1),1);
   for trialNum = 1:size(trial_block_inds{1,blockNum},1) 
       theseInds = trial_block_inds{1,blockNum}(trialNum,1):...
           trial_block_inds{1,blockNum}(trialNum,2);
       hitsHolder = hitsHolder+any(FT(:,theseInds),2);
   end
   BlockedFThits{1,blockNum} = hitsHolder;
   BlockedFTprob{1,blockNum} = hitsHolder/size(trial_block_inds{1,blockNum},1);
end
%Should look something like the place field

%%
%Idea:  LRselectivity = (hitsLeft-hitsRight)/totalHits
%       STselectivity = (hitsStudy-hitsTest)/totalHits

probLeft = []; probForced = [];
for blockInd=1:length(blocksLeft)       
    probLeft = [probLeft, blocksLeft(blockInd)*BlockedFTprob{1,blockInd}];    
    probForced = [probForced, blocksForced(blockInd)*BlockedFTprob{1,blockInd}];
end
LRselectivity = mean(probLeft,2);
STselectivity = mean(probForced,2);
histogram(LRselectivity(LRselectivity~=0),30)
figure; histogram(STselectivity(STselectivity~=0),30)

%% Threshold for selectivity, leave a batch unsorted
LRthresh=0.02; %left positive, right neg
STthresh=0.01; %forced positive, free neg
LeftStudySelective = find(LRselectivity > LRthresh & STselectivity > STthresh);
RightStudySelective = find(LRselectivity < -LRthresh & STselectivity > STthresh);
LeftTestSelective = find(LRselectivity > LRthresh & STselectivity < -STthresh);
RightTestSelective = find(LRselectivity < -LRthresh & STselectivity < -STthresh);
everythingElse = find( (LRselectivity < LRthresh & LRselectivity > -LRthresh)...
    | (STselectivity < STthresh & STselectivity > -STthresh) );

SortedBlockedFT = [BlockedFT(RightStudySelective,:);...
                   BlockedFT(RightTestSelective,:);...
                   BlockedFT(LeftStudySelective,:);...
                   BlockedFT(LeftTestSelective,:);...
                   BlockedFT(everythingElse,:)];

SortedFT=    [FT(RightStudySelective,:);...
              FT(RightTestSelective,:);...
              FT(LeftStudySelective,:);...
              FT(LeftTestSelective,:);...
              FT(everythingElse,:)];          
          
%%
sortedFig=figure; imagesc(SortedBlockedFT)
hold on
for block=1:length(blockEnd)-1
    plot([blockEnd(block) blockEnd(block)],[1 size(FT,1)],'r')
end
heights = length(RightStudySelective);
heights = [heights; heights(end)+length(RightTestSelective)];
heights = [heights; heights(end)+length(LeftStudySelective)];
heights = [heights; heights(end)+length(LeftTestSelective)];
for type=1:4
    plot([0 size(SortedBlockedFT,2)],[heights(type) heights(type)],'g')
end    
plotBlocks=[0 blockEnd];
newXticks=plotBlocks(1:end-1)+round(diff(plotBlocks)/2);
sortedFig.Children.XTick=newXticks;
sortedFig.Children.XTickLabel=blockTypes;  

sortedFTfig=figure; imagesc(SortedFT)
hold on
for type=1:4
    plot([0 size(SortedFT,2)],[heights(type) heights(type)],'g')
end    


%% Get duration
BlockedDurations = cell(1,4);
BlockedDurationsZscore = cell(1,4);
zerosNeeded = zeros(size(FT,1),1);
trialEnds = 0;
for blockNum = 1:length(blockTypes)
    BigDurations = zeros(size(FT,1),size(trial_block_inds{1,blockNum},1));
    disp(['Block ' num2str(blockNum)])
    %dursHolder = zeros(size(FT,1),1);
    for trialNum = 1:size(trial_block_inds{1,blockNum},1)
        disp(['Trial ' num2str(trialNum)])
        theseInds = trial_block_inds{1,blockNum}(trialNum,1):...
           trial_block_inds{1,blockNum}(trialNum,2);
        duration = zeros(size(FT,1),1);
        for cell = 1:size(FT,1)
            traceBit = [0 FT(cell,theseInds) 0]; 
            transientStarts = find(diff(traceBit)==1);
            transientEnds = find(diff(traceBit)==-1);
            if any(transientStarts) && any(transientEnds)...
                    && length(transientStarts)==length(transientEnds)
                duration(cell) = sum(transientEnds - transientStarts);
            end    
        end
        BigDurations(:,trialNum) = duration;
    end
    BlockedDurations{1,blockNum} = BigDurations;
    BlockedDurationsZscore{1,blockNum} = zscore(BigDurations,[],2); 
end

%% Similarity matrix
coefMat=zeros(4,4); pMat=zeros(4,4); checkMat=zeros(4,4);
for blockType=1:4
    for compBlock=1:4
        [r,p]=corrcoef(BlockedDurationsZscore{1,blockType}(1:max(heights),:),...
                       BlockedDurationsZscore{1,compBlock}(1:max(heights),:));
        coefMat(blockType,compBlock)=r(1,2);
        pMat(blockType,compBlock)=p(1,2);
        checkMat(blockType,compBlock)=blockType*compBlock;
    end
end

for blockType=1:4
    for compBlock=1:4
        [r,p]=corrcoef(mean(BlockedDurations{1,blockType},2),...
                       mean(BlockedDurations{1,compBlock},2));
        coefMat(blockType,compBlock)=r(1,2);
        pMat(blockType,compBlock)=p(1,2);
        checkMat(blockType,compBlock)=blockType*compBlock;
    end
end
%{
%% Similarity by percentile rank difference


%vertical shuffle of cells:
    %breakdown by correct/incorrect
    

%need to handle when uneven number


%z score all of these? yes
output = zscore(input,[],2); %this is how Sam did it


%statistical significance: shuffle trials into new blocks
shuffleInd=randperm(length(BFTindices));
allStarts %cell array? whatever format used for each individual block type
allStops
for trialNum=1:length(allStarts)
    useInds = allStarts(shuffleInd(trialNum)):allStops(shuffleInds(trialNum));
    BFTshuffleInds=[BFTshuddleInds, useInds];
end



% correlation of block by block: representational similarity analysis
[r,p] = corrcoef(x,y)


%% Old stuff
%%All brain frames of each type
%{
inc_forced_l=[]; inc_free_l=[];
inc_forced_r=[]; inc_free_r=[];
num_blocks = size(frames,1);
for j=1:num_blocks
    if left_trials_forced(j) == 1
        inc_forced_l = [inc_forced_l, forced_start(j):forced_end(j)];
    elseif right_trials_forced(j) == 1
        inc_forced_r = [inc_forced_r, forced_start(j):forced_end(j)];
    end
    
    if left_trials_free(j) == 1
        inc_free_l = [inc_free_l, free_start(j):free_end(j)];
    elseif right_trials_free(j) == 1
        inc_free_r = [inc_free_r, free_start(j):free_end(j)];
    end
end


%fix for FToffset
    % take raw/non-aligned frame inidices that aligned with FT from
    % ProcOut.mat file and align to aligned position/FT data.
    exclude_frames_raw=inc_free_r;
    exclude_frames=[];
    exclude_aligned = exclude_frames_raw - FToffset + 2;
    exclude_aligned = exclude_aligned(exclude_aligned > 0); 
% Get rid of any negative values 
(corresponding to times before the mouse was on the maze)
    exclude_frames = [exclude_frames, exclude_aligned]; 
% concatenate to exclude_frames 
    exclude_frames = exclude_frames(exclude_frames <= length(x_adj_cm));
%sometimes come up with frames longer than FT
figure;
plot(x_adj_cm,y_adj_cm,'.k')
hold on
plot(x_adj_cm(exclude_frames),y_adj_cm(exclude_frames),'.r')
%}


%convert to brain frames (shouldn't need this anymore
%{
forced_start = AVI_to_brain_frame(forced_start, AVItime_interp);
forced_end = AVI_to_brain_frame(delay_start, AVItime_interp);
free_start = AVI_to_brain_frame(free_start, AVItime_interp);
free_end = AVI_to_brain_frame(leave_maze, AVItime_interp);
cage_start = AVI_to_brain_frame(cage_start, AVItime_interp);
cage_leave = AVI_to_brain_frame(cage_leave, AVItime_interp);
    if length(cage_leave)==length(cage_start)-1
        cage_start(end) = []; end
delay_start = AVI_to_brain_frame(delay_start, AVItime_interp);
delay_end = free_start;
%}
%}