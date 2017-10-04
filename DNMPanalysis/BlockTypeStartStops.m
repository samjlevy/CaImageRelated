function [sStarts, sStops, tStarts, tStops] = BlockTypeStartStops(block_type)

sStarts = [];
sStops = [];
tStarts = [];
tStops = [];

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

end