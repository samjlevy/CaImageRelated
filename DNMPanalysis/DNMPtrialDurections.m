function [right_forced, left_forced, right_free, left_free] = DNMPtrialDurections(frames, txt)

forced_direction = CondExcelParseout(frames, txt, 'Forced Trial Type (L/R)', 1);
right_forced = strcmpi(forced_direction,'R');
left_forced = strcmpi(forced_direction,'L');
free_direction = CondExcelParseout(frames, txt, 'Free Trial Choice (L/R)', 1);
right_free = strcmpi(free_direction,'R');
left_free = strcmpi(free_direction,'L');

end