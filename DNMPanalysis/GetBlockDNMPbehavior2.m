function [start_stop_struct, include_struct, exclude_struct, pooled, correct, lapNumber]...
    = GetBlockDNMPbehavior2( frames, txt, block_type, sessionLength)
%Returns frame numbers for what block you want, asking for what type of
%timestamps
%[frames, txt] = xlsread(xls_file, 1);

includeBlank = zeros(1, sessionLength);

[right_forced, left_forced, right_free, left_free] = DNMPtrialDirections(frames, txt);
%[sStarts, sStops, tStarts, tStops] = BlockTypeStartStops(block_type)

%Get epoch boundaries
switch block_type
    case 'stem_only'
        [ forced_starts ] = CondExcelParseout( frames, txt, 'Start on maze (start of Forced', 0 );
        [ forced_stops ] = CondExcelParseout( frames, txt, 'ForcedChoiceEnter', 0 );
        [ free_starts ] = CondExcelParseout( frames, txt, 'Lift barrier (start of free choice)', 0);
        [ free_stops ] = CondExcelParseout( frames, txt, 'FreeChoiceEnter', 0 );
    case 'stem_arm' %Start maze through reward
        [ forced_starts ] = CondExcelParseout( frames, txt, 'Start on maze (start of Forced', 0 );
        [ forced_stops ] = CondExcelParseout( frames, txt, 'Forced Reward', 0 );
        [ free_starts ] = CondExcelParseout( frames, txt, 'Lift barrier (start of free choice)', 0);
        [ free_stops ] = CondExcelParseout( frames, txt, 'Free Reward', 0 );
    case 'stem_extended'
        [ forced_starts ] = CondExcelParseout( frames, txt, 'Start on maze (start of Forced', 0 );
        [ forced_stops ] = CondExcelParseout( frames, txt, 'Forced Choice', 0 );
        [ free_starts ] = CondExcelParseout( frames, txt, 'Lift barrier (start of free choice)', 0);
        [ free_stops ] = CondExcelParseout( frames, txt, 'Free Choice', 0);
    case 'whole_lap'
        [ forced_starts ] = CondExcelParseout( frames, txt, 'Start on maze (start of Forced', 0 );
        [ forced_stops ] = CondExcelParseout( frames, txt, 'Enter Delay', 0 );
        [ free_starts ] = CondExcelParseout( frames, txt, 'Lift barrier (start of free choice)', 0);
        [ free_stops ] = CondExcelParseout( frames, txt, 'Leave Maze', 0 );
    case 'side_arm'
        [ forced_starts ] = CondExcelParseout( frames, txt, 'Forced Choice', 0 );
        [ forced_stops ] = CondExcelParseout( frames, txt, 'Forced Reward', 0 );
        [ free_starts ] = CondExcelParseout( frames, txt, 'Free Choice', 0);
        [ free_stops ] = CondExcelParseout( frames, txt, 'Free Reward', 0 );
    case 'choice_bit'
        [ forced_starts ] = CondExcelParseout( frames, txt, 'ForcedChoiceEnter', 0 );
        [ forced_stops ] = CondExcelParseout( frames, txt, 'Forced Choice', 0 );
        [ free_starts ] = CondExcelParseout( frames, txt, 'FreeChoiceEnter', 0);
        [ free_stops ] = CondExcelParseout( frames, txt, 'Free Choice', 0 );
    case 'lap_end'
        [ forced_starts ] = CondExcelParseout( frames, txt, 'Forced Reward', 0 );
        [ forced_stops ] = CondExcelParseout( frames, txt, 'Enter Delay', 0 );
        [ free_starts ] = CondExcelParseout( frames, txt, 'Free Reward', 0);
        [ free_stops ] = CondExcelParseout( frames, txt, 'Leave Maze', 0 );
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
    case {'stem_only', 'arm_min', 'whole_arm', 'stem_extended','whole_lap','side_arm','stem_arm'}
        start_stop_struct.study_l = [forced_starts(left_forced), forced_stops(left_forced)];
        start_stop_struct.study_r = [forced_starts(right_forced), forced_stops(right_forced)];
        start_stop_struct.test_l = [free_starts(left_free), free_stops(left_free)];
        start_stop_struct.test_r = [free_starts(right_free), free_stops(right_free)];
        
        lapNumber.study_l = frames(left_forced,1);
        lapNumber.study_r = frames(right_forced,1);
        lapNumber.test_l = frames(left_free,1);
        lapNumber.test_r = frames(right_free,1);
        
        correct.all = (left_forced & right_free) | (right_forced & left_free);
        correct.study_l = correct.all(left_forced);
        correct.study_r = correct.all(right_forced);
        correct.test_l = correct.all(left_free);
        correct.test_r = correct.all(right_free);
        
        include_struct.study_r = includeBlank;
        correct.include.study_r = includeBlank;
        for aa = 1:length(start_stop_struct.study_r)
            include_struct.study_r(start_stop_struct.study_r(aa,1):start_stop_struct.study_r(aa,2)) = 1;
            include_struct.study_r = logical(include_struct.study_r);
            exclude_struct.study_r = double(include_struct.study_r == 0);
            correct.include.study_r(start_stop_struct.study_r(aa,1):start_stop_struct.study_r(aa,2)) = correct.study_r(aa);
        end 
        include_struct.test_r = includeBlank;
        correct.include.test_r = includeBlank;
        for bb = 1:length(start_stop_struct.test_r)
            include_struct.test_r(start_stop_struct.test_r(bb,1):start_stop_struct.test_r(bb,2)) = 1;
            include_struct.test_r = logical(include_struct.test_r);
            exclude_struct.test_r = double(include_struct.test_r == 0);
            correct.include.test_r(start_stop_struct.test_r(bb,1):start_stop_struct.test_r(bb,2)) = correct.test_r(bb);
        end 
        include_struct.study_l = includeBlank;
        correct.include.study_l = includeBlank;
        for cc = 1:length(start_stop_struct.study_l)
            include_struct.study_l(start_stop_struct.study_l(cc,1):start_stop_struct.study_l(cc,2)) = 1;
            include_struct.study_l = logical(include_struct.study_l);
            exclude_struct.study_l = double(include_struct.study_l == 0);
            correct.include.study_l(start_stop_struct.study_l(cc,1):start_stop_struct.study_l(cc,2)) = correct.study_l(cc);
        end
        include_struct.test_l = includeBlank;
        correct.include.test_l = includeBlank;
        for dd = 1:length(start_stop_struct.test_l)
            include_struct.test_l(start_stop_struct.test_l(dd,1):start_stop_struct.test_l(dd,2)) = 1;
            include_struct.test_l = logical(include_struct.test_l);
            exclude_struct.test_l = double(include_struct.test_l == 0);
            correct.include.test_l(start_stop_struct.test_l(dd,1):start_stop_struct.test_l(dd,2)) = correct.test_l(dd);
        end 
        

        
        pooled = PoolDNMPbehavior(start_stop_struct, include_struct);    
    
    case 'delay'
        start_stop_struct.post_study_r = [starts(left_free), stops(left_free)];
        start_stop_struct.post_study_l = [starts(right_free), stops(right_free)];
        %start_stop_struct.stops_pre_l = 
        %start_stop_struct.stops_pre_r = 
        
        lapNumber.post_study_r = frames(left_free,1);
        lapNumber.post_study_l = frames(right_free,1);
        
        include_struct.post_study_r = includeBlank;
        for dd = 1:length(start_stop_struct.post_study_r)
            include_struct.post_study_r(start_stop_struct.post_study_r(dd,1):start_stop_struct.post_study_r(dd,2)) = 1;
        end    
        include_struct.post_study_r = logical(include_struct.post_study_r);
        exclude_struct.post_study_r = logical(double(include_struct.post_study_r == 0));
        
        include_struct.post_study_l = includeBlank;
        for dd = 1:length(start_stop_struct.post_study_l)
            include_struct.post_study_l(start_stop_struct.post_study_l(dd,1):start_stop_struct.post_study_l(dd,2)) = 1;
        end    
        include_struct.post_study_l = logical(include_struct.post_study_l);
        exclude_struct.post_study_l = logical(double(include_struct.post_study_l == 0));
        
        correct.all = (left_forced & right_free) | (right_forced & left_free);
        correct.post_study_r = correct.all(left_free);
        correct.post_study_l = correct.all(right_free);
        
        pooled = PoolDNMPbehavior(start_stop_struct, include_struct);
        
    case {'cage', 'on_maze'}
        start_stop_struct.starts = starts;
        start_stop_struct.stops = stops;
        
        lapNumber.lap = frames(:,1);
        
        include_struct.test_l = includeBlank;
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