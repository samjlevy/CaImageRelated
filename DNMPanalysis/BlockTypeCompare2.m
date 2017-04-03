% Pass 2 at comparing by block types, RSA, etc. 

%list of sessions that only have one tracking and can be run now:
filesToRun = [20 28 29 30 31 34 35 37 39 40 41]; 

columnLabels = {'Start on maze (start of Forced', 'Lift barrier (start of free choice)',...
               'Leave maze', 'Start in homecage', 'Leave homecage',...
               'Forced Trial Type (L/R)', 'Free Trial Choice (L/R)',...
               'Enter Delay', 'Forced Choice', 'Free Choice',...  
               'Forced Reward', 'Free Reward', 'ForcedChoiceEnter', 'FreeChoiceEnter'};

for session = 1:length(SessionsToRun)
    cd(MD(SessionsToRun(session)).Location)
    [ ~, ~, ~ ] = JustFToffset;
    xlsFiles = dir('*DNMPsheet.xlsx');
    ParsedFramesToBrainFrames ( xlsFiles.name )
end

load('Pos_brain.mat')
load('FinalOutput.mat', 'PSAbool')
xls_file = dir('*BrainTime.xlsx');
[frames, txt] = xlsread(fullfile(xls_file.folder,xls_file.name), 1);
%% Stem Only:
%Get Trial timestamps
forced_starts = CondExcelParseout(frames, txt, 'Start on maze (start of Forced', 0);
forced_stem_ends = CondExcelParseout(frames, txt, 'ForcedChoiceEnter', 0);
free_starts = CondExcelParseout(frames, txt, 'Lift barrier (start of free choice)', 0);
free_stem_ends = CondExcelParseout(frames, txt, 'FreeChoiceEnter', 0);

%Trial directions
forced_direction = CondExcelParseout(frames, txt, 'Forced Trial Type (L/R)', 1);
right_forced = strcmpi(forced_direction,'R');
left_forced = strcmpi(forced_direction,'L');
free_direction = CondExcelParseout(frames, txt, 'Free Trial Choice (L/R)', 1);
right_free = strcmpi(free_direction,'R');
left_free = strcmpi(free_direction,'L');

%Good lap timestamps (video too short, FT too short, etc.)
tooLong = frames >= FTuseIndices(end);
GoodLaps = any(tooLong,2) == 0;
correct_trials = right_forced & left_free | ...
    left_forced & right_free;
allGood = GoodLaps & correct_trials;

%Plot of FT sorted this way
forced_r_stem = [forced_starts(allGood & right_forced), forced_stem_ends(allGood & right_forced)];
forced_l_stem = [forced_starts(allGood & left_forced), forced_stem_ends(allGood & left_forced)];
free_r_stem = [free_starts(allGood & right_free), free_stem_ends(allGood & right_free)];
free_l_stem = [free_starts(allGood & left_free), free_stem_ends(allGood & left_free)];
[ FoRindices, FoRedges ] = BlockOfFTindices( forced_r_stem(:,1), forced_r_stem(:,2));
[ FoLindices, FoLedges ] = BlockOfFTindices( forced_l_stem(:,1), forced_l_stem(:,2));
[ FrRindices, FrRedges ] = BlockOfFTindices( free_r_stem(:,1), free_r_stem(:,2));
[ FrLindices, FrLedges ] = BlockOfFTindices( free_l_stem(:,1), free_l_stem(:,2));

blockedFTstem = PSAbool(:,[FoRindices, FrRindices, FoLindices, FrLindices]);  
blockedFTstemEdges = [1 FoRedges(end)];
blockedFTstemEdges = [blockedFTstemEdges blockedFTstemEdges(end)+FrRedges(end)];
blockedFTstemEdges = [blockedFTstemEdges blockedFTstemEdges(end)+FoLedges(end)]; 
blockedFTstemEdges = [blockedFTstemEdges blockedFTstemEdges(end)+FrLedges(end)];

[ hits ] = HitsThisBlock (starts, stops, FT);
totalHits = sum(hits,2);




%% Demo figs
figure; imagesc(PSAbool); title('Raw Data, with stem time indicated')
for trial = find(allGood)
    hold on
    plot( [forced_starts(trial) forced_starts(trial)], [0 size(PSAbool,1)],'g' )
    plot( [forced_stem_ends(trial) forced_stem_ends(trial)], [0 size(PSAbool,1)],'r' )
    plot( [free_starts(trial) free_starts(trial)], [0 size(PSAbool,1)],'m' )
    plot( [free_stem_ends(trial) free_stem_ends(trial)], [0 size(PSAbool,1)],'y' )
end    
    
figure;
plot (brainX, brainY, '.k','MarkerSize',3)
hold on
plot( brainX(forced_starts(allGood)), brainY(forced_starts(allGood)), '.g','MarkerSize',15)
plot( brainX(forced_stem_ends(allGood)), brainY(forced_stem_ends(allGood)), '.r','MarkerSize',15)
plot( brainX(free_starts(allGood)), brainY(free_starts(allGood)), '.m','MarkerSize',15)
plot( brainX(free_stem_ends(allGood)), brainY(free_stem_ends(allGood)), '.y','MarkerSize',15)
title('X/Y positions, with stem time indicated')

stemFig=figure; imagesc(blockedFTstem); title('Stem Data only, sorted')
stemFig.Children.XTick = ceil(diff(blockedFTstemEdges,1)/2) + blockedFTstemEdges(1:4); 
stemFig.Children.XTickLabel = {'Forced Right', 'Free Right', 'Forced Left', 'Free Left'};
for edge=2:5
hold on    
plot([blockedFTstemEdges(edge) blockedFTstemEdges(edge)], [0 size(PSAbool,1)],'g')
end


Need:
      forced stem l/r
      forced to reward l/r
      forced to delay l/r
      delay following l/r
      free stem l/r
      free arm l/r
      cage following l/r
      correct/wrong 1/0 vector
      
Selectivity for forced/free
Selectivity for l/r