remakeTBT1
%This function is to remake trialbytrial easily, using the files it is
%currently made with. Useful for cases where some kind of alignment to
%positions, timestamps, cell registration, etc. was altered but everything
%else needs to stay the same

mainFolder = 'C:\Users\Sam\Desktop\DNMPfinalData';
mice = {'Bellatrix', 'Polaris', 'Calisto'};

for mouseI = 1:length(mice)
    load(fullfile(mainFolder,mice{mouseI},'trialbytrialOLD.mat'),'base_path','allfiles')
    reg_paths = allfiles;
    reg_paths(strcmp(reg_paths,base_path)) = [];

    MakeTrialbyTrial(base_path,reg_paths,'all',1,1)
    
end