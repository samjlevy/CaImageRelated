function [fixedEpochs, reporter, epochs] = FindBadLapsWrapper(pos_file,xls_file)

load(pos_file,'x_adj_cm','y_adj_cm')

[frames, txt] = xlsread(xls_file, 1);

[forced_starts, FoScol] = CondExcelParseout(frames, txt, 'Start on maze (start of Forced', 0);
[free_starts, FrScol] = CondExcelParseout(frames, txt, 'Lift barrier (start of free choice)', 0);

[forced_stem_ends, FoEcol] = CondExcelParseout(frames, txt, 'ForcedChoiceEnter', 0);
if sum(forced_stem_ends)==0
    [forced_stem_ends, FoEcol] = CondExcelParseout(frames, txt, 'Forced Stem End', 0);
end
[free_stem_ends, FrEcol] = CondExcelParseout(frames, txt, 'FreeChoiceEnter', 0);
if sum(free_stem_ends)==0
    [free_stem_ends, FrEcol] = CondExcelParseout(frames, txt, 'Free Stem End', 0);
end

%Trial directions
[right_forced, left_forced, right_free, left_free] = DNMPtrialDirections(frames, txt);

forced_r_stem = [forced_starts(right_forced), forced_stem_ends(right_forced)];
forced_l_stem = [forced_starts(left_forced), forced_stem_ends(left_forced)];
free_r_stem = [free_starts(right_free), free_stem_ends(right_free)];
free_l_stem = [free_starts(left_free), free_stem_ends(left_free)];

epochs(1).starts = forced_l_stem(:,1);
epochs(1).stops = forced_l_stem(:,2);
epochs(2).starts = forced_r_stem(:,1);
epochs(2).stops = forced_r_stem(:,2);
epochs(3).starts = free_l_stem(:,1);
epochs(3).stops = free_l_stem(:,2);
epochs(4).starts = free_r_stem(:,1);
epochs(4).stops = free_r_stem(:,2);

for aa = 1:4
    [fixedEpochs{aa}, reporter{aa}] = FindBadLaps(x_adj_cm, y_adj_cm, epochs(aa));
end

adjustedFrames = frames;

%this could be generalized at all
adjustedFrames(right_forced, FoScol) = fixedEpochs{1,2}.starts;
adjustedFrames(right_forced, FoEcol) = fixedEpochs{1,2}.stops;

adjustedFrames(left_forced, FoScol) = fixedEpochs{1,1}.starts;
adjustedFrames(left_forced, FoEcol) = fixedEpochs{1,1}.stops;

adjustedFrames(right_free, FrScol) = fixedEpochs{1,4}.starts;
adjustedFrames(right_free, FrEcol) = fixedEpochs{1,4}.stops;

adjustedFrames(left_free, FrScol) = fixedEpochs{1,3}.starts;
adjustedFrames(left_free, FrEcol) = fixedEpochs{1,3}.stops;

[newAll] = CombineForExcel(adjustedFrames, txt);

saveName = [xls_file(1:end-5) '-2.xlsx'];
xlswrite(saveName, newAll);
disp('saved corrected sheet')
end