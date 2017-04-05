function DNMPplaceFields1(varargin)
%Varargin could include MD struct. This version is meant to run on the
%current directory, nothing fancy
RoomStr = '201a - 2015';
load 'Pos_align.mat'
load('FinalOutput.mat','PSAbool')

xls_file = dir('*BrainTime.xlsx');
[frames, txt] = xlsread(xls_file.name, 1);

[stem_frame_bouds, stem_include, stem_exclude] =...
    GetBlockDNMPbehavior( frames, txt, 'stem_only', length(x));
[~, ~, maze_exclude] =...
    GetBlockDNMPbehavior( frames, txt, 'on_maze', length(x));
on_maze_exclude = maze_exclude.exclude;
save exclude_frames.mat on_maze_exclude

neuron_input = 'FinalOutput.mat';
cmperbin = 0.25;
minspeed = 7;
NumShuffles = 10; % For starters

save_names = {'PlaceMaps_forced_left025bins.mat', 'PlaceMaps_free_left025bins.mat',...
              'PlaceMaps_forced_right025bins.mat', 'PlaceMaps_free_right025bins.mat',...
              'PlaceMaps_on_maze025bins.mat'};
name_append = {'forced_l', 'forced_r', 'free_l', 'free_r', 'on_maze'};

for k=1:length(save_names)-1
CalculatePlacefields(RoomStr,'exclude_frames_raw',stem_exclude.(name_append{k}),...
                'alt_inputs',neuron_input,'man_savename',save_names{k},...
                'half_window',0,'minspeed',minspeed,'cmperbin',cmperbin,...
                'NumShuffles',NumShuffles,'calc_half',1);
end            

k=5;
CalculatePlacefields(RoomStr,'exclude_frames_raw',on_maze_exclude,...
                'alt_inputs',neuron_input,'man_savename',save_names{k},...
                'half_window',0,'minspeed',minspeed,'cmperbin',cmperbin,...
                'NumShuffles',NumShuffles,'calc_half',1);

for k = 1:length(save_names)
    disp(['Running PFstats for ' name_append{k} ' session.'])
    PFstats(0, 'alt_file_use', save_names{k}, ['_' name_append{k}])
end