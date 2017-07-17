base_path = 'F:\Bellatrix\Bellatrix_160831';
reg_paths = {'F:\Bellatrix\Bellatrix_160830';...
             'F:\Bellatrix\Bellatrix_160901'};
         
if ~exist(fullfile(base_path,'fullReg.mat'),'file')
    disp('need to run cell registration first')
    return
else
    load(fullfile(base_path,'fullReg.mat'))
end

allfiles = [base_path; reg_paths];
[~,howSort] = sort(cellfun(@(x) x(end-5:end),allfiles,'UniformOutput',false));
allfiles = allfiles(howSort);

for thisFile = 1:length(allfiles)

    load(fullfile(allfiles{thisFile},'Pos_align.mat'))
    xls_file = dir(fullfile(allfiles{thisFile},'*BrainTime_Adjusted.xlsx'));
    [frames, txt] = xlsread(fullfile(allfiles{thisFile},xls_file.name), 1);

    bigStuff(thisFile).PSAbool = PSAbool;
    bigStuff(thisFile).x_adj_cm = x_adj_cm;
    
    forced_starts = CondExcelParseout(frames, txt, 'Start on maze (start of Forced', 0);
    free_starts = CondExcelParseout(frames, txt, 'Lift barrier (start of free choice)', 0);

    forced_stem_ends = CondExcelParseout(frames, txt, 'ForcedChoiceEnter', 0);
    if sum(forced_stem_ends)==0
        forced_stem_ends = CondExcelParseout(frames, txt, 'Forced Stem End', 0);
    end
    free_stem_ends = CondExcelParseout(frames, txt, 'FreeChoiceEnter', 0);
    if sum(free_stem_ends)==0
        free_stem_ends = CondExcelParseout(frames, txt, 'Free Stem End', 0);
    end

    %Trial directions
    [right_forced, left_forced, right_free, left_free] = DNMPtrialDirections(frames, txt);

    %Good lap timestamps (video too short, FT too short, etc.)
    tooLong = frames >= length(speed);%FTuseIndices(end)
    GoodLaps = any(tooLong,2) == 0;

    okTypes = {'Start on maze (start of Forced'; 'Lift barrier (start of free choice)';...
               'Leave maze'; 'Enter Delay'; 'Forced Choice'; 'Free Choice';...
               'Forced Reward'; 'Free Reward'; 'ForcedChoiceEnter';'FreeChoiceEnter'};
    headings = {txt{1,:}};
    useCols = find(cellfun(@(x) any(strcmpi(x,okTypes)),headings));
    checkFrames = frames(:,useCols);
    [C,ia,ic] = unique(checkFrames,'rows');
    for ur = 1:size(checkFrames,1)
        [~,ia,~] = unique(checkFrames(ur,:));
        MessedUp(ur,1) = length(ia) < size(checkFrames,2); %#ok<SAGROW>
    end
    if any(MessedUp); disp(['deleting some laps, overlap frames, file ' allfiles{thisFile}]); end
    correct_trials = right_forced & left_free | ...
        left_forced & right_free;
    allGood = GoodLaps & correct_trials;

    forced_r_stem = [forced_starts(allGood & right_forced), forced_stem_ends(allGood & right_forced)];
    forced_l_stem = [forced_starts(allGood & left_forced), forced_stem_ends(allGood & left_forced)];
    free_r_stem = [free_starts(allGood & right_free), free_stem_ends(allGood & right_free)];
    free_l_stem = [free_starts(allGood & left_free), free_stem_ends(allGood & left_free)];

    bigStuff(thisFile).epochs(1).starts = forced_l_stem(:,1);
    bigStuff(thisFile).epochs(1).stops = forced_l_stem(:,2);
    bigStuff(thisFile).epochs(2).starts = forced_r_stem(:,1);
    bigStuff(thisFile).epochs(2).stops = forced_r_stem(:,2);
    bigStuff(thisFile).epochs(3).starts = free_l_stem(:,1);
    bigStuff(thisFile).epochs(3).stops = free_l_stem(:,2);
    bigStuff(thisFile).epochs(4).starts = free_r_stem(:,1);
    bigStuff(thisFile).epochs(4).stops = free_r_stem(:,2);
    
    [FoLtotalHits, FoLactiveLaps, FoLreliability] = CellsInConditions2(PSAbool, forced_l_stem(:,1), forced_l_stem(:,2));
    [FoRtotalHits, FoRactiveLaps, FoRreliability] = CellsInConditions2(PSAbool, forced_r_stem(:,1), forced_r_stem(:,2));
    [FrLtotalHits, FrLactiveLaps, FrLreliability] = CellsInConditions2(PSAbool, free_l_stem(:,1), free_l_stem(:,2));
    [FrRtotalHits, FrRactiveLaps, FrRreliability] = CellsInConditions2(PSAbool, free_r_stem(:,1), free_r_stem(:,2));

    allReliability = [FoLreliability, FoRreliability, FrLreliability,  FrRreliability];
    useCells = find(sum(allReliability >= 0.5, 2)); 
    
    bigStuff(thisFile).allReliability = allReliability;
    bigStuff(thisFile).useCells = useCells;
    
end


plot_file = 'Cells Stem Rasters';
for plotCell = 1:length(useCells)
    thisCell = useCells(plotCell);
    rastPlot = PlotRasterMultiSess(x_adj_cm,epochs,PSAbool,thisCell);
    export_fig(plot_file,'-pdf','-append')
    close rastPlot
end