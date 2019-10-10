function [start_stop_struct, include_struct, exclude_struct, pooled, correct, lapNumber]...
    = GetBlockAlternationBehavior( behaviorTable, block_type, sessionLength)
%Returns frame numbers for what block you want, asking for what type of
%timestamps
%[frames, txt] = xlsread(xls_file, 1);

includeBlank = false(1, sessionLength);

%Get epoch boundaries
switch block_type
    case 'stem_only'
        %[ forced_starts ] = CondExcelParseout( frames, txt, 'Start on maze (start of Forced', 0 );
        %[5 forced_stops ] = CondExcelParseout( frames, txt, 'ForcedChoiceEnter', 0 );
        %[ free_starts ] = CondExcelParseout( frames, txt, 'Lift barrier (start of free choice)', 0);
        %[ free_stops ] = CondExcelParseout( frames, txt, 'FreeChoiceEnter', 0 );
    case 'stem_arm' %Start maze through reward
        %[ forced_starts ] = CondExcelParseout( frames, txt, 'Start on maze (start of Forced', 0 );
        %[ forced_stops ] = CondExcelParseout( frames, txt, 'Forced Reward', 0 );
        %[ free_starts ] = CondExcelParseout( frames, txt, 'Lift barrier (start of free choice)', 0);
        %[ free_stops ] = CondExcelParseout( frames, txt, 'Free Reward', 0 );
    case 'stem_extended'
        %[ forced_starts ] = CondExcelParseout( frames, txt, 'Start on maze (start of Forced', 0 );
        %[ forced_stops ] = CondExcelParseout( frames, txt, 'Forced Choice', 0 );
        %[ free_starts ] = CondExcelParseout( frames, txt, 'Lift barrier (start of free choice)', 0);
        %[ free_stops ] = CondExcelParseout( frames, txt, 'Free Choice', 0);
    case 'whole_lap'
        starts = behaviorTable.LapStart;
        stops = behaviorTable.DelayEnter;
    case 'side_arm'
        %[ forced_starts ] = CondExcelParseout( frames, txt, 'Forced Choice', 0 );
        %[ forced_stops ] = CondExcelParseout( frames, txt, 'Forced Reward', 0 );
        %[ free_starts ] = CondExcelParseout( frames, txt, 'Free Choice', 0);
        %[ free_stops ] = CondExcelParseout( frames, txt, 'Free Reward', 0 );
    case 'choice_bit'
        %[ forced_starts ] = CondExcelParseout( frames, txt, 'ForcedChoiceEnter', 0 );
        %[ forced_stops ] = CondExcelParseout( frames, txt, 'Forced Choice', 0 );
        %[ free_starts ] = CondExcelParseout( frames, txt, 'FreeChoiceEnter', 0);
        %[ free_stops ] = CondExcelParseout( frames, txt, 'Free Choice', 0 );
    case 'lap_end'
        %[ forced_starts ] = CondExcelParseout( frames, txt, 'Forced Reward', 0 );
        %[ forced_stops ] = CondExcelParseout( frames, txt, 'Enter Delay', 0 );
        %[ free_starts ] = CondExcelParseout( frames, txt, 'Free Reward', 0);
        %[ free_stops ] = CondExcelParseout( frames, txt, 'Leave Maze', 0 );
    case 'delay'
        %[ starts ] = CondExcelParseout( frames, txt, 'Enter Delay', 0);
        %[ stops ] = CondExcelParseout( frames, txt, 'Lift barrier (start of free choice)', 0);
    case 'cage'
        %[ starts ] = CondExcelParseout( frames, txt, 'Start in homecage', 0);
        %[ stops ] = CondExcelParseout( frames, txt, 'Leave homecage', 0);
    case 'on_maze'
        %[ starts ] = CondExcelParseout( frames, txt, 'Start on maze (start of Forced', 0);
        %[ stops ] = CondExcelParseout( frames, txt, 'Leave maze');
end

mazes = unique(behaviorTable.MazeID);
numMazes = length(mazes);
altDirections = {'left','right'};

leftLaps = strcmpi(behaviorTable.TurnDir,'l') | strcmpi(behaviorTable.TurnDir,'left');
rightLaps = strcmpi(behaviorTable.TurnDir,'r') | strcmpi(behaviorTable.TurnDir,'right');
%Make include/exclude arrays
switch block_type
    case {'stem_only', 'arm_min', 'whole_arm', 'stem_extended','whole_lap','side_arm','stem_arm'}
        for tt = 1:numMazes
            leftLapsMaze{tt} = behaviorTable.MazeID==mazes(tt) & leftLaps;
            rightLapsMaze{tt} = behaviorTable.MazeID==mazes(tt) & rightLaps;

            condNames{1+2*(tt-1)} = [altDirections{1} num2str(mazes(tt))];
            condNames{2+2*(tt-1)} = [altDirections{2} num2str(mazes(tt))];

            start_stop_struct.(condNames{1+2*(tt-1)}) = [starts(leftLapsMaze{tt}), stops(leftLapsMaze{tt})];
            start_stop_struct.(condNames{2+2*(tt-1)}) = [starts(rightLapsMaze{tt}), stops(rightLapsMaze{tt})];

            lapNumber.(condNames{1+2*(tt-1)}) = behaviorTable.TrialNum(leftLapsMaze{tt});
            lapNumber.(condNames{2+2*(tt-1)}) = behaviorTable.TrialNum(rightLapsMaze{tt});

            correct.all = logical(behaviorTable.TrialCorrect);
            correct.(condNames{1+2*(tt-1)}) = logical(behaviorTable.TrialCorrect(leftLapsMaze{tt}));
            correct.(condNames{2+2*(tt-1)}) = logical(behaviorTable.TrialCorrect(rightLapsMaze{tt}));

            include_struct.(condNames{1+2*(tt-1)}) = includeBlank;
            for ll = 1:size(start_stop_struct.(condNames{1+2*(tt-1)}),1)
                 include_struct.(condNames{1+2*(tt-1)})...
                     (start_stop_struct.(condNames{1+2*(tt-1)})(ll,1):start_stop_struct.(condNames{1+2*(tt-1)})(ll,2)) = true;
            end
            include_struct.(condNames{2+2*(tt-1)}) = includeBlank;
            for rr = 1:size(start_stop_struct.(condNames{2+2*(tt-1)}),1)
                 include_struct.(condNames{2+2*(tt-1)})...
                     (start_stop_struct.(condNames{2+2*(tt-1)})(rr,1):start_stop_struct.(condNames{2+2*(tt-1)})(rr,2)) = true;
            end


        end

    case {'delay'}
        disp('Delay not working yet')
    case {'cage', 'on_maze'}
        disp('Cage, on maze not working yet')
end

exclude_struct = [];
pooled = [];
%pooled = PoolDNMPbehavior(start_stop_struct, include_struct);


end