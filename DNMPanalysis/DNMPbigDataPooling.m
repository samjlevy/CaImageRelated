DNMPBigDataPooling(file_paths, sessionTypes, 

%This is kind of a re-do of trial-by-trial
%Saves out trial-by-trial for different chunks of the maze, all on-maze
%activity, spreadsheet data, all position and activity, all in one place so
%it can be accessed easily


allfiles = [base_path; fullReg.RegSessions(:)];
filepts = cellfun(@(x) strsplit(x,'_'),allfiles,'UniformOutput',false);
dates = cell2mat(cellfun(@(x) str2double(x{2}(1:6)),filepts,'UniformOutput',false));
[~,howSort] = sort(dates);

for thisFile = 1:length(allfiles)
    load(fullfile(allfiles{thisFile},'Pos_align.mat'))
    
    position.all_x_adj_cm{1,thisFile} = x_adj_cm;
    position.all_y_adj_cm{1,thisFile} = y_adj_cm;
    all_PSAbool{1,thisFile} = PSAbool;
    
    xls_file = dir(fullfile(allfiles{thisFile},'*Finalized.xlsx'));
    xls_file = xls_file.name;
    
    [exel.frames, exel.txt] - xlsread(fullfile(allfiles{thisFile},xls_file), 1);

    
   