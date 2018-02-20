function [allfiles, position, all_PSAbool, correctBounds, badLaps, sortedSessionInds, lapNumber]...
    = GetMegaStuff2(base_path, reg_paths, regUseType, regUseInput)
%This script aquires all the information from multiple files in a format thats useful
%for going through each file in the same way later. Right now it only does the center stem, 
%but it's possible it would work for any timestamps where there is a study/test l/r.
%Doesn't yet handle forced/unforced, mostly because GetBehavior for that
%isn't ready yet. 

if ~exist(fullfile(base_path,'fullReg.mat'),'file')
    disp('need to run cell registration first')
    return
else
    load(fullfile(base_path,'fullReg.mat'))
end

if isempty(reg_paths)
    reg_paths = fullReg.RegSessions;
end

switch regUseType
    case 'vector'
        regUse = regUseInput;
    case 'sessionType'
        regUse = fullReg.sessionType==1;
        %regUse = fullReg.sessionType==regUseInput; %1/2 for DNMP/ForcedUnforced
end

%allfiles = [base_path; reg_paths(:)];
allfiles = [base_path; fullReg.RegSessions(:)];
filepts = cellfun(@(x) strsplit(x,'_'),allfiles,'UniformOutput',false);
dates = cell2mat(cellfun(@(x) str2double(x{2}(1:6)),filepts,'UniformOutput',false));
[~,howSort] = sort(dates);
%allfiles = allfiles(howSort);

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
    %[frames, txt] = xlsread(fullfile(allfiles{thisFile},xls_file), 1);

    position.all_x_adj_cm{1,thisFile} = x_adj_cm;
    position.all_y_adj_cm{1,thisFile} = y_adj_cm;
    all_PSAbool{1,thisFile} = PSAbool;
    
    %Trial directions
    switch sessionType(thisFile)
        case 1
            [bounds, ~, ~, ~, correct, lapNum] = GetBlockDNMPbehavior...
                ( fullfile(allfiles{thisFile},xls_file), 'stem_only', length(x_adj_cm)); 
        case 2
            disp('Sorry Forced/Unforced not working')
    end

    ss = fieldnames(bounds);
    for block = 1:4
        correctBounds(thisFile).(ss{block}) =...
            [bounds.(ss{block})(correct.(ss{block}),1)...
            bounds.(ss{block})(correct.(ss{block}),2)];
        
        lapNumber(thisFile).(ss{block}).all = lapNum.(ss{block});
        
        lapNumber(thisFile).(ss{block}).correct =...
            lapNum.(ss{block})(correct.(ss{block}));
        
        badLaps(thisFile).(ss{block}) =...
            [bounds.(ss{block})(correct.(ss{block})==0,1)...
            bounds.(ss{block})(correct.(ss{block})==0,2)];
        
        lapNumber(thisFile).(ss{block}).wrong=...
            lapNum.(ss{block})(correct.(ss{block})==0);
    end
    
end

%{
    
    allReliability = [FoLreliability, FoRreliability, FrLreliability,  FrRreliability];
    useLogical = sum(allReliability >= 0.5, 2);
    useCells = find(useLogical); 
    
    bigStuff(TFind).allReliability = allReliability;
    bigStuff(TFind).useLogical = useLogical;
    bigStuff(TFind).useCells = useCells;
    all_UseLogical{1,TFind} = useLogical;

    all_epochs(thisFile).epochs(1).starts = bounds.study_l(correct.study_l,1);
    all_epochs(thisFile).epochs(1).stops = bounds.study_l(correct.study_l,2);
    all_epochs(thisFile).epochs(2).starts = bounds.study_r(correct.study_r,1);
    all_epochs(thisFile).epochs(2).stops = bounds.study_r(correct.study_r,2);
    all_epochs(thisFile).epochs(3).starts = bounds.test_l(correct.test_l,1);
    all_epochs(thisFile).epochs(3).stops = bounds.test_l(correct.test_l,2);
    all_epochs(thisFile).epochs(4).starts = bounds.test_r(correct.test_r,1);
    all_epochs(thisFile).epochs(4).stops = bounds.test_r(correct.test_r,2);
    
    
    %}
end