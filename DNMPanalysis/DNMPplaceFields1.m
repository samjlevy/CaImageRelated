function DNMPplaceFields1(varargin)
%Varargin could include MD struct. This version is meant to run on the
%current directory, nothing fancy
RoomStr = '201a - 2015';
load 'Pos_align.mat'
%load('FinalOutput.mat','PSAbool')

xls_file = dir('*BrainTime.xlsx');
[frames, txt] = xlsread(xls_file.name, 1);

[stem_frame_bounds, stem_include, stem_exclude] =...
    GetBlockDNMPbehavior( frames, txt, 'stem_only', 58149);
[~, ~, maze_exclude] =...
    GetBlockDNMPbehavior( frames, txt, 'on_maze', 58149);
on_maze_exclude = maze_exclude.exclude;
save exclude_frames.mat on_maze_exclude

neuron_input = 'FinalOutput.mat';
cmperbin = 1;
minspeed = 7;
NumShuffles = 10; % For starters

save_append = {'_forced_left1cmbins.mat', '_free_left1cmbins.mat',...
              '_forced_right1cmbins.mat', '_free_right1cmbins.mat',...
              '_maze1cmbins.mat'};
name_append = {'forced_l', 'free_l', 'forced_r', 'free_r', 'on_maze'};

for k=1:length(save_append)-1
MD(1).exclude_frames = stem_exclude.(name_append{k});
PlacefieldsSL(MD(1),'exclude_frames',stem_exclude.(name_append{k}),...
                'aligned',true,'minspeed',minspeed,'cmperbin',cmperbin,...
                'B',NumShuffles);

PlacefieldStats(MD(1))

movefile('Placefields.mat',strcat('PlaceMaps',save_append{k}))
movefile('PlacefieldStats.mat',strcat('PlaceFieldStats',save_append{k}))
end            

k=5;
PlacefieldsSL(MD(1),'exclude_frames',on_maze_exclude,...
                'aligned',true,'minspeed',minspeed,'cmperbin',cmperbin,...
                'B',NumShuffles);
PlacefieldStats(MD(1))

movefile('Placefields.mat',strcat('PlaceMaps',save_append{k}))
movefile('PlacefieldStats.mat',strcat('PlaceFieldStats',save_append{k}))