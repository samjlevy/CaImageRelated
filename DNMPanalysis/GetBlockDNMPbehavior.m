function [start_stop_struct, include_struct, exclude_struct] = GetBlockDNMPbehavior( frames, txt, block_type, sessionLength)
%Returns frame numbers for what block you want, asking for what type of
%timestamps
includeBlank = zeros(1, sessionLength);

[right_forced, left_forced, right_free, left_free] = DNMPtrialDirections(frames, txt);

switch block_type
    case 'stem_only'
        [ forced_starts ] = CondExcelParseout( frames, txt, 'Start on maze (start of Forced', 0 );
        [ forced_stops ] = CondExcelParseout( frames, txt, 'ForcedChoiceEnter', 0 );
        [ free_starts ] = CondExcelParseout( frames, txt, 'Lift barrier (start of free choice)', 0);
        [ free_stops ] = CondExcelParseout( frames, txt, 'FreeChoiceEnter', 0 );
    case 'arm_min' %choice made through reward get
        [ forced_starts ] = CondExcelParseout( frames, txt, 'Start on maze (start of Forced', 0 );
        [ forced_stops ] = CondExcelParseout( frames, txt, 'ForcedChoiceEnter', 0 );
        [ free_starts ] = CondExcelParseout( frames, txt, 'Lift barrier (start of free choice)', 0);
        [ free_stops ] = CondExcelParseout( frames, txt, 'FreeChoiceEnter', 0 );
    case 'whole_arm'
        [ forced_starts ] = CondExcelParseout( frames, txt, 'Forced Choice', 0 );
        [ forced_stops ] = CondExcelParseout( frames, txt, 'Forced Reward', 0 );
        [ free_starts ] = CondExcelParseout( frames, txt, 'Free Choice', 0);
        [ free_stops ] = CondExcelParseout( frames, txt, 'Forced Reward', 0 );
    case 'delay'
        [ starts ] = CondExcelParseout( frames, txt, 'Enter Delay', 0);
        [ stops ] = CondExcelParseout( frames, txt, 'Lift barrier (start of free choice)', 0);
    case 'cage'
        [ starts ] = CondExcelParseout( frames, txt, 'Start in homecage', 0);
        [ stops ] = CondExcelParseout( frames, txt, 'Leave homecage', 0);
    case 'on_maze'
        [ starts ] = CondExcelParseout( frames, txt, 'Start on maze (start of Forced', 0);
        [ stops ] = CondExcelParseout( frames, txt, 'Leave maze');
end

switch block_type
    case {'stem_only', 'arm_min', 'whole_arm'}
        start_stop_struct.forced_r_start = forced_starts(right_forced);
        start_stop_struct.forced_r_stop = forced_stops(right_forced);
        start_stop_struct.free_r_start = free_starts(right_free);
        start_stop_struct.free_r_stop = free_stops(right_free);
        start_stop_struct.forced_l_start = forced_starts(left_forced);
        start_stop_struct.forced_l_stop = forced_stops(left_forced);
        start_stop_struct.free_l_start = free_starts(left_free);
        start_stop_struct.free_l_stop = free_stops(left_free);
        
        include_struct.forced_r = includeBlank;
        for aa = 1:length(start_stop_struct.forced_r_start)
            include_struct.forced_r(start_stop_struct.forced_r_start(aa):start_stop_struct.forced_r_stop(aa)) = 1;
            include_struct.forced_r = logical(include_struct.forced_r);
            exclude_struct.forced_r = double(include_struct.forced_r == 0);
        end 
        include_struct.free_r = includeBlank;
        for bb = 1:length(start_stop_struct.free_r_start)
            include_struct.free_r(start_stop_struct.free_r_start(bb):start_stop_struct.free_r_stop(bb)) = 1;
            include_struct.free_r = logical(include_struct.free_r);
            exclude_struct.free_r = double(include_struct.free_r == 0);
        end 
        include_struct.forced_l = includeBlank;
        for cc = 1:length(start_stop_struct.forced_l_start)
            include_struct.forced_l(start_stop_struct.forced_l_start(cc):start_stop_struct.forced_l_stop(cc)) = 1;
            include_struct.forced_l = logical(include_struct.forced_l);
            exclude_struct.forced_l = double(include_struct.forced_l == 0);
        end
        include_struct.free_l = includeBlank;
        for dd = 1:length(start_stop_struct.free_l_start)
            include_struct.free_l(start_stop_struct.free_l_start(dd):start_stop_struct.free_l_stop(dd)) = 1;
            include_struct.free_l = logical(include_struct.free_l);
            exclude_struct.free_l = double(include_struct.free_l == 0);
        end 
        
    case {'delay', 'cage', 'on_maze'}
        start_stop_struct.starts = starts;
        start_stop_struct.stops = stops;
        
        include_struct.free_l = includeBlank;
        for ee = 1:length(starts)
            if ~isnan(start_stop_struct.starts(ee)) && ~isnan(start_stop_struct.stops(ee))
            include_struct.include(start_stop_struct.starts(ee):start_stop_struct.stops(ee)) = 1;
            include_struct.include = logical(include_struct.include);
            exclude_struct.exclude = double(include_struct.include == 0);
            end
        end
end


end