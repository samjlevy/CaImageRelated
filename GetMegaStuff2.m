function [allfiles, all_x_adj_cm, all_y_adj_cm, all_PSAbool, sortedSessionInds, all_UseLogical, useActual]...
    = GetMegaStuff2(base_path, reg_paths, regUse)

         
if ~exist(fullfile(base_path,'fullReg.mat'),'file')
    disp('need to run cell registration first')
    return
else
    load(fullfile(base_path,'fullReg.mat'))
end

if ~exist('reg_paths','var')
    reg_paths = fullReg.RegSessions;
end

allfiles = [base_path; reg_paths(:)];
filepts = cellfun(@(x) strsplit(x,'_'),allfiles,'UniformOutput',false);
dates = cell2mat(cellfun(@(x) str2double(x{2}(1:6)),filepts,'UniformOutput',false));
[~,howSort] = sort(dates);
allfiles = allfiles(howSort);

allUse = logical([1; regUse(:)]);
allUseSorted = allUse(howSort);

sortOnly = howSort(allUseSorted);

allfiles = [allfiles(sortOnly)];

allSessType = [1; fullReg.sessionType(:)];
sessionType = allSessType(sortOnly);

%sort session Inds: comes in in order of session registration
sortedSessionInds = fullReg.sessionInds(:,sortOnly);

for thisFile = 1:length(allfiles)
    load(fullfile(allfiles{thisFile},'Pos_align.mat'))
    xls_file = dir(fullfile(allfiles{thisFile},'*Finalized.xlsx'));
    xls_file = xls_file.name;
    [frames, txt] = xlsread(fullfile(allfiles{thisFile},xls_file), 1);

    all_x_adj_cm{1,thisFile} = x_adj_cm;
    all_y_adj_cm{1,thisFile} = y_adj_cm;
    all_PSAbool{1,thisFile} = PSAbool;
    
    %Trial directions
    switch sessionType(thisFile)
        case 1
            [start_stop_struct, ~, ~, ~, correct]...
                = GetBlockDNMPbehavior( xls_file, 'stem_only', length(x_adj_cm)); 
        case 2
            
    end
    
    
    correct_trials = right_forced & left_free | ...
        left_forced & right_free;
    allGood = GoodLaps & correct_trials;

    
    


    all_epochs(thisFile).epochs(1).starts = forced_l_stem(:,1);
    all_epochs(thisFile).epochs(1).stops = forced_l_stem(:,2);
    all_epochs(thisFile).epochs(2).starts = forced_r_stem(:,1);
    all_epochs(thisFile).epochs(2).stops = forced_r_stem(:,2);
    all_epochs(thisFile).epochs(3).starts = free_l_stem(:,1);
    all_epochs(thisFile).epochs(3).stops = free_l_stem(:,2);
    all_epochs(thisFile).epochs(4).starts = free_r_stem(:,1);
    all_epochs(thisFile).epochs(4).stops = free_r_stem(:,2);
    
    [~,~, FoLreliability] = CellsInConditions2(PSAbool, forced_l_stem(:,1), forced_l_stem(:,2));%FoLtotalHits, FoLactiveLaps
    [~,~, FoRreliability] = CellsInConditions2(PSAbool, forced_r_stem(:,1), forced_r_stem(:,2));%FoRtotalHits, FoRactiveLaps
    [~,~, FrLreliability] = CellsInConditions2(PSAbool, free_l_stem(:,1), free_l_stem(:,2));%FrLtotalHits, FrLactiveLaps
    [~,~, FrRreliability] = CellsInConditions2(PSAbool, free_r_stem(:,1), free_r_stem(:,2));%FrRtotalHits, FrRactiveLaps

    allReliability = [FoLreliability, FoRreliability, FrLreliability,  FrRreliability];
    useLogical = sum(allReliability >= 0.5, 2);
    useCells = find(useLogical); 
    
    bigStuff(TFind).allReliability = allReliability;
    bigStuff(TFind).useLogical = useLogical;
    bigStuff(TFind).useCells = useCells;
    all_UseLogical{1,TFind} = useLogical;
    
    end
end

%Find the cells to plot
try
    if any(fullReg.RegPairs)
        %use regpairs
    end
catch
    disp('made it to catch')
    bigUse = zeros(size(sortedSessionInds));
    %bigUse(bigStuff(1).useCells,1) = 1;
    for thisF = 1:length(allfiles)
        for cc = 1:length(bigStuff(thisF).useCells)
            pairedCell = find(sortedSessionInds(:,thisF)==bigStuff(thisF).useCells(cc));
            bigUse(pairedCell,thisF) = 1;
        end
    end
end
useActual = find(sum(bigUse,2) > 0);

%{
if sum(forced_stem_ends)==0
        forced_stem_ends = CondExcelParseout(frames, txt, 'Forced Stem End', 0);
    end
    if sum(free_stem_ends)==0
        free_stem_ends = CondExcelParseout(frames, txt, 'Free Stem End', 0);
    end
%}

end

