function [fixedEpochs, reporter, epochs] = FindBadLapsWrapper(pos_file,xls_file,editSection,sessionType)
%Edit section describes which part of the maze we're editing; Stem_only and whole_arm are most common 

if ~exist('sessionType','var')
    sessionType = 1; %DNMP
end
load(pos_file,'x_adj_cm','y_adj_cm')

sessionLength = length(x_adj_cm);

[frames, txt] = xlsread(xls_file, 1);

%Trial directions, column numbers for spreadsheet editing; probably an
%inefficient way to do this
switch sessionType
    case 1
        [bounds, ~, ~, ~, ~] = ...
            GetBlockDNMPbehavior2( xls_file, editSection, sessionLength);
        [sStarts, sStops, tStarts, tStops] = BlockTypeStartStops(editSection,1);
        %sStarts = sort([bounds.study_l(:,1); bounds.study_r(:,1)]);
        %sStops = sort([bounds.study_l(:,2); bounds.study_r(:,2)]);
        %tStarts = sort([bounds.test_l(:,1); bounds.test_r(:,1)]);
        %tStops = sort([bounds.test_l(:,2); bounds.test_r(:,2)]);
        [~, FoScol] = CondExcelParseout(frames, txt, sStarts, 0);%forced_starts
        [~, FrScol] = CondExcelParseout(frames, txt, tStarts, 0);%free_starts
        [~, FoEcol] = CondExcelParseout(frames, txt, sStops, 0);%forced_stem_ends
        [~, FrEcol] = CondExcelParseout(frames, txt, tStops, 0);%free_stem_ends
        
        [right_forced, left_forced, right_free, left_free] = DNMPtrialDirections(frames, txt);
    case 2
        [bounds, ~, ~, ~] =...
            GetBlockForcedUnforcedBhvr2( xls_file, editSection, sessionLength);
        [sStarts, sStops, ~, ~] = BlockTypeStartStops(editSection,2);
        
        [~, FoScol] = CondExcelParseout(frames, txt, sStarts, 0);%forced_starts
        [~, FoEcol] = CondExcelParseout(frames, txt, sStops, 0);%forced_stem_ends
        FrScol = FoScol;
        FrEcol = FoEcol;
        
        [right_forced, left_forced, right_free, left_free] = ForcedUnforcedtrialDirections(frames, txt);
end 

epochs(1).starts = bounds.study_l(:,1);
epochs(1).stops = bounds.study_l(:,2);
epochs(2).starts = bounds.study_r(:,1);
epochs(2).stops = bounds.study_r(:,2);
epochs(3).starts = bounds.test_l(:,1);
epochs(3).stops = bounds.test_l(:,2);
epochs(4).starts = bounds.test_r(:,1);
epochs(4).stops = bounds.test_r(:,2);

for aa = 1:4
    [fixedEpochs{aa}, reporter{aa}] = FindBadLaps(x_adj_cm, y_adj_cm, epochs(aa));
end

adjustedFrames = frames;

%this could be generalized at all
adjustedFrames(right_forced, FoScol) = fixedEpochs{1,2}.starts;
adjustedFrames(right_forced, FoEcol) = fixedEpochs{1,2}.stops;

adjustedFrames(left_forced, FoScol) = fixedEpochs{1,1}.starts;
adjustedFrames(left_forced, FoEcol) = fixedEpochs{1,1}.stops;

adjustedFrames(right_free, FrScol) = fixedEpochs{1,4}.starts; %does this index correctly? depends on if right_free is logical
adjustedFrames(right_free, FrEcol) = fixedEpochs{1,4}.stops;

adjustedFrames(left_free, FrScol) = fixedEpochs{1,3}.starts;
adjustedFrames(left_free, FrEcol) = fixedEpochs{1,3}.stops;

[newAll] = CombineForExcel(adjustedFrames, txt);

saveName = [xls_file(1:end-5) '-2.xlsx'];
xlswrite(saveName, newAll);
disp('saved corrected sheet')

%{
        
[right_forced, left_forced, right_free, left_free] = DNMPtrialDirections(frames, txt);

forced_r_stem = [forced_starts(right_forced), forced_stem_ends(right_forced)];
forced_l_stem = [forced_starts(left_forced), forced_stem_ends(left_forced)];
free_r_stem = [free_starts(right_free), free_stem_ends(right_free)];
free_l_stem = [free_starts(left_free), free_stem_ends(left_free)];

if sum(forced_stem_ends)==0
    [forced_stem_ends, FoEcol] = CondExcelParseout(frames, txt, 'Forced Stem End', 0);
end

if sum(free_stem_ends)==0
    [free_stem_ends, FrEcol] = CondExcelParseout(frames, txt, 'Free Stem End', 0);
end
%}
end