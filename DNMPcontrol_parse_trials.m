function DNMPcontrol_parse_trials(xls_path, xls_sheet_num, pos_file_fullpath)
% DNMP_parse_trials(xls_path, pos_file_fullpath)
%   Saves exclude_frames_raw for running CalculatePlaceFields for different
%   trial type breakdowns.

[frames, txt] = xlsread(xls_path, xls_sheet_num);

num_blocks = size(frames,1);

load(pos_file_fullpath,'time_interp','AVItime_interp')
% pos_data = importdata(DVT_fullpath);

num_brain_frames = length(AVItime_interp);
%% Parse inputs
trials_forced = strcmpi(txt(2:end,6),'FORCED');
trials_free = strcmpi(txt(2:end,6),'FREE');
forced_start = frames(trials_forced,2);
forced_stop = frames(trials_forced,3);
free_start = frames(trials_free,2);
free_stop = frames(trials_free,3);

right_trials = strcmpi(txt(2:end,7),'R');
left_trials = strcmpi(txt(2:end,7),'L');

right_trials_forced_start = frames(trials_forced & right_trials,2);
right_trials_forced_stop = frames(trials_forced & right_trials,3);
left_trials_forced_start = frames(trials_forced & left_trials,2);
left_trials_forced_stop = frames(trials_forced & left_trials,3);
right_trials_free_start = frames(trials_free & right_trials,2);
right_trials_free_stop = frames(trials_free & right_trials,3);
left_trials_free_start = frames(trials_free & left_trials,2);
left_trials_free_stop = frames(trials_free & left_trials,3);

blocks = frames(:,1);
cage_start = frames(:,4);
cage_leave = frames(2:end,5);

correct_trials = ones(size(frames,1),1);

all_trials_start=frames(2:end,2);
all_trials_stop=frames(2:end,3);

% Interp AVIframes to brainframes
on_maze_start = AVI_to_brain_frame(all_trials_start, AVItime_interp);
on_maze_stop = AVI_to_brain_frame(all_trials_stop, AVItime_interp);
forced_start = AVI_to_brain_frame(forced_start, AVItime_interp);
forced_stop = AVI_to_brain_frame(forced_stop, AVItime_interp);
free_start = AVI_to_brain_frame(free_start, AVItime_interp);
free_stop = AVI_to_brain_frame(free_stop, AVItime_interp);
right_trials_forced_start = AVI_to_brain_frame(right_trials_forced_start, AVItime_interp);
right_trials_forced_stop = AVI_to_brain_frame(right_trials_forced_stop, AVItime_interp);
left_trials_forced_start = AVI_to_brain_frame(left_trials_forced_start, AVItime_interp);
left_trials_forced_stop = AVI_to_brain_frame(left_trials_forced_stop, AVItime_interp);
right_trials_free_start = AVI_to_brain_frame(right_trials_free_start, AVItime_interp);
right_trials_free_stop = AVI_to_brain_frame(right_trials_free_stop, AVItime_interp);
left_trials_free_start = AVI_to_brain_frame(left_trials_free_start, AVItime_interp);
left_trials_free_stop = AVI_to_brain_frame(left_trials_free_stop, AVItime_interp);



leave_maze = AVI_to_brain_frame(leave_maze, AVItime_interp);

% keyboard
%% Get all frames to include for each trial type (free, forced, L, R, correct)
inc_free = [];
inc_free_l = [];
inc_free_r = [];
inc_forced = [];
inc_forced_l = [];
inc_forced_r = [];
on_maze = [];
inc_correct = [];%same as on maze

for j = 1:length(on_maze)
    on_maze = [on_maze, on_maze_start(j):on_maze_stop(j)];
end    
inc_correct = on_maze;    
for k=1:length(forced_start)
    inc_forced = [inc_forced, forced_start(k):forced_stop(k)];
end
for l=1:length(free_start)
    inc_free = [inc_free, free_start(l):free_stop(l)];
end
for m=1:length(left_trials_forced_start)
    inc_forced_l = [inc_forced_l, left_trials_forced_start(m):left_trials_forced_stop(m)];
end
for n=1:length(right_trials_forced_start)
    inc_forced_r = [inc_forced_r, right_trials_forced_start(n):right_trials_forced_stop(n)];
end
for o=1:length(right_trials_free_start)
    inc_free_r = [inc_free_r, right_trials_free_start(o):right_trials_free_stop(o)];
end
for p=1:length(right_trials_free_start)
    inc_free_l = [inc_free_l, left_trials_free_start(p):left_trials_free_stop(p)];
end

%% Convert to logicals
forced_log = false(1,num_brain_frames); forced_log(inc_forced) = true;
forced_l_log = false(1,num_brain_frames); forced_l_log(inc_forced_l) = true;
forced_r_log = false(1,num_brain_frames); forced_r_log(inc_forced_r) = true;
free_log = false(1,num_brain_frames); free_log(inc_free) = true;
free_l_log = false(1,num_brain_frames); free_l_log(inc_free_l) = true;
free_r_log = false(1,num_brain_frames); free_r_log(inc_free_r) = true;
correct_log = false(1,num_brain_frames); correct_log(inc_correct) = true;
on_log = false(1,num_brain_frames); on_log(on_maze) = true;
left_log = free_l_log | forced_l_log;
right_log = free_r_log | forced_r_log;

% Get frames to exclude
forced_exclude = find(~forced_log);
forced_l_exclude = find(~forced_l_log);
forced_r_exclude = find(~forced_r_log);
free_exclude = find(~free_log);
free_l_exclude = find(~free_l_log);
free_r_exclude = find(~free_r_log);
correct_exclude = find(~correct_log);
on_maze_exclude = find(~on_log);
left_exclude = find(~left_log);
right_exclude = find(~right_log);

%% Save
save exclude_frames forced_exclude forced_l_exclude forced_r_exclude ...
    free_exclude free_l_exclude free_r_exclude correct_exclude on_maze_exclude ...
    left_exclude right_exclude
end

