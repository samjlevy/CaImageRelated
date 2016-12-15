%%
%From DNMP_Placefields
save_names = {'PlaceMapsv2_forced_025cmbins.mat','PlaceMapsv2_free_025cmbins.mat','PlaceMapsv2_onmaze.mat','PlaceMapsv2_forced.mat','PlaceMapsv2_free.mat',...
     'PlaceMapsv2_forced_left.mat','PlaceMapsv2_forced_right.mat',...
     'PlaceMapsv2_free_left.mat','PlaceMapsv2_free_right.mat'};
name_append = {'forced_025cmbins', 'free_025cmbins','onmaze','forced','free',...
     'forced_left','forced_right',...
     'free_left','free_right'};
exc_frames_type = {'forced_exclude','free_exclude','on_maze_exclude','forced_exclude','free_exclude',...
     'forced_l_exclude','forced_r_exclude','free_l_exclude','free_r_exclude'};

 exc_frames = load('exclude_frames.mat');
 
 k = 6; %forced l exclude
 
 
 room,'exclude_frames_raw',exc_frames.(exc_frames_type{k}),...
                'alt_inputs',neuron_input,'man_savename',save_names{k},...
                'half_window',0,'minspeed',minspeed,'cmperbin',cmperbin,...
                'NumShuffles',NumShuffles,'calc_half',1);
            
%From CalculatePlaceFields

NumNeurons = size(FT,1);

SR = 20;
Pix2Cm = 0.15;

if strcmpi(RoomStr,'201a - 2015')
        Pix2Cm = 0.0874;
        display('Room 201a - 2015');
        end
    
        if ~isempty(pos_align_file) % Load alternate file with aligned position data if specified
        load(pos_align_file)
        end
x = x_adj_cm;
y = y_adj_cm;
pos_align_use = 1;

if ~isempty(exclude_frames_raw)
    % take raw/non-aligned frame inidices that aligned with FT from
    % ProcOut.mat file and align to aligned position/FT data.
    exclude_aligned = exclude_frames_raw - FToffset + 2;
    exclude_aligned = exclude_aligned(exclude_aligned > 0); % Get rid of any negative values (corresponding to times before the mouse was on the maze)
    exclude_frames = [exclude_frames, exclude_aligned]; % concatenate to exclude_frames 
end

% New stuff
forced_l_include=exc_to_inc(exclude_frames,length(x));


diffs=diff(forced_l_include);
starts=find(diffs==1);
starts=starts+1;
ends=find(diffs==-1);

    %sanity check
figure; plot(x(exclude_frames),y(exclude_frames),'.k')
hold on
plot(x(forced_l_include),y(forced_l_include),'.r')
plot(x(starts),y(starts),'.y')
plot(x(ends),y(ends),'.g')


%% Maybe better to step back and do the calcs from the beginning
% from DNMP_parse_trials

xls_sheet_num=1;
xls_bonus_sheet_num=1;

xls_path='C:\MasterData\InUse\Polaris_160831\DNMPsheet.xlsx';
xls_bonus_path='C:\MasterData\InUse\Polaris_160831\DNMPbonus.xlsx';
pos_file_fullpath='C:\MasterData\InUse\Polaris_160831\Pos_align.mat';

[frames, txt] = xlsread(xls_path, xls_sheet_num);
[bonusFrames, bonusTxt] = xlsread(xls_bonus_path, xls_bonus_sheet_num);




load(pos_file_fullpath,'time_interp','AVItime_interp')
% pos_data = importdata(DVT_fullpath);

num_brain_frames = length(AVItime_interp);
blocks = frames(:,1);
forced_start = frames(:,2);
free_start = frames(:,3);
leave_maze = frames(:,4);
%cage_start = frames(:,5);
%cage_leave = frames(2:end,6);
delay_start = bonusFrames(2:end);

right_trials_forced = strcmpi(txt(2:end,7),'R');
right_trials_free = strcmpi(txt(2:end,8),'R');
left_trials_forced = strcmpi(txt(2:end,7),'L');
left_trials_free = strcmpi(txt(2:end,8),'L');
correct_trials = (strcmpi(txt(2:end,7),'R') & strcmpi(txt(2:end,8),'L')) | ...
    (strcmpi(txt(2:end,7),'L') & strcmpi(txt(2:end,8),'R'));


forced_start = AVI_to_brain_frame(forced_start, AVItime_interp);
forced_end = AVI_to_brain_frame(delay_start, AVItime_interp);
free_start = AVI_to_brain_frame(free_start, AVItime_interp);
leave_maze = AVI_to_brain_frame(leave_maze, AVItime_interp);
%if doing it this way, still need to get FT offset, etc. from above

inc_forced_l=[];
inc_forced_r=[];
num_blocks = size(frames,1);
for j=1:num_blocks
    if left_trials_forced(j) == 1
        inc_forced_l = [inc_forced_l, forced_start(j):free_start(j)];
    elseif right_trials_forced(j) == 1
        inc_forced_r = [inc_forced_r, forced_start(j):free_start(j)];
    end
end

%fix for FToffset
    % take raw/non-aligned frame inidices that aligned with FT from
    % ProcOut.mat file and align to aligned position/FT data.
    exclude_aligned = exclude_frames_raw - FToffset + 2;
    exclude_aligned = exclude_aligned(exclude_aligned > 0); % Get rid of any negative values (corresponding to times before the mouse was on the maze)
    exclude_frames = [exclude_frames, exclude_aligned]; % concatenate to exclude_frames 
    


%% And much later, actually plot the stuff
%this is still some pseudocode
blockTypes={'forced_l', 'forced_r', 'free_l', 'free_r','delay','cage_epochs'};
BFTindices=[];
for blockNum=1:length(blockTypes)
    blockStart(blockNum)=length(BFTindices)+1;
    starts this block type %cell array?
    stops this block type
    for trialNum=1:length(starts this block)
        useInds=starts(trialNum):ends(trialNum);
        BFTindices=[BFTindices, useInds];
        BFThits
        BFTprobability
        BFTduration
    end
    blockEnd(blockNum)=length(BFTindices);
end

BlockedFT=FT(:,BFTindices);

% number/length/probability of a transient in a cell on a trial



%statistical significance: shuffle trials into new blocks
shuffleInd=randperm(length(BFTindices));
allStarts %cell array? whatever format used for each individual block type
allStops
for trialNum=1:length(allStarts)
    useInds = allStarts(shuffleInd(trialNum)):allStops(shuffleInds(trialNum));
    BFTshuffleInds=[BFTshuddleInds, useInds];
end
%vertical shuffle of cells:
    %breakdown by correct/incorrect
LRselectivity = hitsLeft/totalHits
STselectivity = hitsStudy/totalHits


% correlation of block by block: representational similarity analysis