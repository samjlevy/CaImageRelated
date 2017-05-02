function [start_stop_struct, include_struct, exclude_struct, pooled] = GetBlockForcedUnforcedBhvr( xls_file, block_type, sessionLength)
%Returns frame numbers for what block you want, asking for what type of
%timestamps
[frames, txt] = xlsread(xls_file, 1);

includeBlank = zeros(1, sessionLength);

[right_forced, left_forced, right_free, left_free] = DNMPtrialDirections(frames, txt);

%Get epoch boundaries
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

%Make include/exclude arrays
switch block_type
    case {'stem_only', 'arm_min', 'whole_arm'}
        start_stop_struct.forced_r = [forced_starts(right_forced), forced_stops(right_forced)];
        start_stop_struct.free_r = [free_starts(right_free), free_stops(right_free)];
        start_stop_struct.forced_l = [forced_starts(left_forced), forced_stops(left_forced)];
        start_stop_struct.free_l = [free_starts(left_free), free_stops(left_free)];
        
        include_struct.forced_r = includeBlank;
        for aa = 1:length(start_stop_struct.forced_r)
            include_struct.forced_r(start_stop_struct.forced_r(aa,1):start_stop_struct.forced_r(aa,2)) = 1;
            include_struct.forced_r = logical(include_struct.forced_r);
            exclude_struct.forced_r = double(include_struct.forced_r == 0);
        end 
        include_struct.free_r = includeBlank;
        for bb = 1:length(start_stop_struct.free_r)
            include_struct.free_r(start_stop_struct.free_r(bb,1):start_stop_struct.free_r(bb,2)) = 1;
            include_struct.free_r = logical(include_struct.free_r);
            exclude_struct.free_r = double(include_struct.free_r == 0);
        end 
        include_struct.forced_l = includeBlank;
        for cc = 1:length(start_stop_struct.forced_l)
            include_struct.forced_l(start_stop_struct.forced_l(cc,1):start_stop_struct.forced_l(cc,2)) = 1;
            include_struct.forced_l = logical(include_struct.forced_l);
            exclude_struct.forced_l = double(include_struct.forced_l == 0);
        end
        include_struct.free_l = includeBlank;
        for dd = 1:length(start_stop_struct.free_l)
            include_struct.free_l(start_stop_struct.free_l(dd,1):start_stop_struct.free_l(dd,2)) = 1;
            include_struct.free_l = logical(include_struct.free_l);
            exclude_struct.free_l = double(include_struct.free_l == 0);
        end 
        
    pooled = PoolDNMPbehavior(start_stop_struct, include_struct);    
    
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
        
    pooled = [];    
end



end