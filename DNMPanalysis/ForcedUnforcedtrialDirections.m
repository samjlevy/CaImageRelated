function [right_forced, left_forced, right_free, left_free] = ForcedUnforcedtrialDirections(frames, txt)

forced_unforced = CondExcelParseout(frames, txt, 'Trial Type (FORCED/FREE)', 1);
trial_direction = CondExcelParseout(frames, txt, 'Trial Dir (L/R)', 1);

forced_trials = strcmpi(forced_unforced,'FORCED');
free_trials = strcmpi(forced_unforced,'FREE');

right_trials = strcmpi(trial_direction,'R');
left_trials = strcmpi(trial_direction,'L');

right_forced = forced_trials & right_trials;
left_forced = forced_trials & left_trials;
right_free = free_trials & right_trials; 
left_free = free_trials & left_trials;
end