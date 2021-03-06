function DNMPplaceFields1(varargin)
%Varargin could include MD struct. This version is meant to run on the
%current directory, nothing fancy
RoomStr = '201a - 2015';
load 'Pos_align.mat'
%load('FinalOutput.mat','PSAbool')
xls_file = dir('*BrainTime_Adjusted.xlsx');
xls_file = xls_file.name;
%[frames, txt] = xlsread(xls_file.name, 1);

[stem_frame_bounds, stem_include, stem_exclude, pooled] =...
    GetBlockDNMPbehavior( xls_file, 'stem_only', length(x_adj_cm));
[~, ~, maze_exclude, ~] =...
    GetBlockDNMPbehavior( xls_file, 'on_maze', length(x_adj_cm));
on_maze_exclude = maze_exclude.exclude;
save exclude_frames.mat on_maze_exclude
save stem_bounds.mat stem_frame_bounds
save stem_include.mat stem_include
save LRFoFrpooled.mat pooled

neuron_input = 'FinalOutput.mat';
cmperbin = 2;
minspeed = 2.25;
NumShuffles = 100; % For starters


mdInd = 1; %Polaris_160831
mdInd = 12; %Polaris_160901

save_append = {'_forced_left_2cm.mat', '_free_left_2cm.mat',...
              '_forced_right_2cm.mat', '_free_right_2cm.mat',...
              '_onmaze_2cm.mat'};
name_append = {'forced_l', 'free_l', 'forced_r', 'free_r', 'on_maze'};

for k=1:length(save_append)-1
MD(mdInd).exclude_frames = stem_exclude.(name_append{k});
PlacefieldsSL(MD(mdInd),'exclude_frames',stem_exclude.(name_append{k}),...
                'aligned',true,'minspeed',minspeed,'cmperbin',cmperbin,...
                'B',NumShuffles);%,'save_append',save_append{k}

PlacefieldStatsSL(MD(mdInd))

movefile('Placefields.mat',strcat('PlaceMaps',save_append{k}))
movefile('PlacefieldStats.mat',strcat('PlaceStats',save_append{k}))
end            

k=5;
PlacefieldsSL(MD(mdInd),'exclude_frames',on_maze_exclude,...
                'aligned',true,'minspeed',minspeed,'cmperbin',cmperbin,...
                'B',NumShuffles);%,'save_append',save_append{k}
PlacefieldStats(MD(mdInd))

movefile('Placefields.mat',strcat('PlaceMaps',save_append{k}))
movefile('PlacefieldStats.mat',strcat('PlaceStats',save_append{k}))


save_append2 = {'_allLeft_2cm.mat', '_allRight_2cm.mat',...
              '_allForced_2cm.mat', '_allFree_2cm.mat'};
name_append2 = {'left', 'right', 'forced', 'free'};
for k=1:length(save_append2)
MD(mdInd).exclude_frames = pooled.exclude.(name_append2{k});
PlacefieldsSL(MD(mdInd),'exclude_frames',pooled.exclude.(name_append2{k}),...
                'aligned',true,'minspeed',minspeed,'cmperbin',cmperbin,...
                'B',NumShuffles);%,'save_append',save_append{k}

PlacefieldStatsSL(MD(mdInd))

movefile('Placefields.mat',strcat('PlaceMaps',save_append2{k}))
movefile('PlacefieldStats.mat',strcat('PlaceStats',save_append2{k}))
end        

















