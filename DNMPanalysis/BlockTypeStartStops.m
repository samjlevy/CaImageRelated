function [sStarts, sStops, tStarts, tStops] = BlockTypeStartStops(block_type,sessType)

sStarts = [];
sStops = [];
tStarts = [];
tStops = [];

if isempty(sessType)
    disp('assuming this is a DNMP session')
    sessType = 1;
end

switch sessType
    case 1
        switch block_type
            case 'stem_only'
                sStarts =  'Start on maze (start of Forced';
                sStops = 'ForcedChoiceEnter';
                tStarts = 'Lift barrier (start of free choice)';
                tStops = 'FreeChoiceEnter';
            case 'arm_min' %choice made through reward get
                sStarts =  'Start on maze (start of Forced';
                sStops = 'ForcedChoiceEnter';
                tStarts = 'Lift barrier (start of free choice)';
                tStops = 'FreeChoiceEnter';
            case 'whole_arm'
                sStarts =  'Forced Choice';
                sStops = 'Forced Reward';
                tStarts = 'Free Choice';
                tStops = 'Free Reward';
            case 'delay'
                sStarts = 'Enter Delay';
                sStops = 'Lift barrier (start of free choice)';
            case 'cage'
                sStarts = 'Start in homecage';
                sStops = 'Leave homecage';
            case 'on_maze'
                sStarts = 'Start on maze (start of Forced';
                sStops = 'Leave maze';
        end
    case 2
        switch block_type
            case 'stem_only'
                sStarts =  'Start on maze (start of Forced';
                sStops = 'ChoiceEnter';
            case 'stem_arm' %choice made through reward get
                sStarts =   'Start on maze (start of Forced';
                sStops = 'Reward';
            case 'stem_extended'
                sStarts =   'Start on maze (start of Forced';
                sStops = 'Choice leave';
            case 'whole_lap'
                sStarts =   'Start on maze (start of Forced';
                sStops = 'Leave maze';
            case 'side_arm'
                sStarts =   'Choice leave';
                sStops = 'Reward';
            case 'delay'
                sStarts =   'Enter Delay';
                sStops = 'Leave maze';
            case 'cage'
                sStarts =   'Start in homecage';
                sStops = 'Leave homecage';
            case 'on_maze'
                sStarts =   'Start on maze (start of Forced';
                sStops = 'Leave maze';
        end
end

end