function MakeFullRegFake(sessionPaths)
%Makes a fake full reg for quick trialbytrial, etc.
%assumes sesionpaths{1} is baseSession

if ischar(sessionPaths)
    sessionPaths = {sessionPaths};
end

fullReg.RegSessions = [];
fullReg.sessionType = [];
fullReg.orientation = [];
fullReg.cellCenters = [];
for sessI = 1:length(sessionPaths)
    prts = strsplit(sessionPaths{sessI},'\');
    cd(sessionPaths{sessI})
    sessType{sessI,1} = prts{end};
    sessType{sessI,2}= input(['What type of sesion is this - ' sessionPaths{sessI} '- >> '],'s');
    realDays(sessI,1) = str2double(input('What is the realDay number of this session >>','s'));
    
    fullReg.RegDay(sessI,1) = realDays(sessI,1);
    
    if sessI == 1
        fullReg.baseSession = sessionPaths{sessI};
    else
        fullReg.RegSessions{sessI-1} = sessionPaths{sessI};
        fullReg.sessionType{sessI-1} = sessType{sessI,2};
    end

    allFilesNames{sessI} = sessionPaths{sessI};
    
    load('FinalOutput.mat','cellROIs')
    if length(unique(cellROIs{1}))>2
        %Not a binary image
        NeuronImage = cellfun(@(x) x>0.4*max(x(:)),cellROIs,'UniformOutput',false);
    end
    
    fullReg.cellCenters = [fullReg.cellCenters; getAllCellCenters(NeuronImage)];
    
    fullReg.sessionInds = [];
    fullReg.sessionInds([1:length(NeuronImage)]+size(fullReg.sessionInds,1),sessI) = sessI*ones(length(NeuronImage),1);
end
  
cd(sessionPaths{1})

save('realDays.mat','allFilesNames','realDays')
save('sessType.mat','sessType')
save('fullReg.mat','fullReg')

end
