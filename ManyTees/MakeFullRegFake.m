function MakeFullRegFake(sessionPaths,baseSessionInd,realDays,sessType,sessIndsOverlap)
%Makes a fake full reg for quick trialbytrial, etc.
%assumes sesionpaths{1} is baseSession

if ischar(sessionPaths)
    sessionPaths = {sessionPaths};
end

if isempty(baseSessionInd)
    baseSessionInd = 1;
    disp('Assuming 1st in list is base session...')
end


fullReg.RegSessions = {};
fullReg.sessionType = [];
fullReg.orientation = [];
fullReg.cellCenters = [];
fullReg.sessionInds = [];
fullReg.realDays = nan(length(sessionPaths),1);
for sessI = 1:length(sessionPaths)
    cd(sessionPaths{sessI})
    if isempty(sessType)
        prts = strsplit(sessionPaths{sessI},'\');
        cd(sessionPaths{sessI})
        sessType{sessI,1} = prts{end};
        sessType{sessI,2}= input(['What type of sesion is this - ' sessionPaths{sessI} '- >> '],'s');
    end
    
    if isempty(realDays)
        realDays(sessI,1) = str2double(input('What is the realDay number of this session >>','s'));
    end
    
    fullReg.realDays(sessI,1) = realDays(sessI);
    
    if sessI == baseSessionInd
        fullReg.baseSession = sessionPaths{sessI};
        fullReg.baseSessionInd = baseSessionInd;
    end
    
    fullReg.RegSessions{sessI,1} = sessionPaths{sessI};
    fullReg.sessionType{sessI,1} = sessType{sessI};

    allFilesNames{sessI} = sessionPaths{sessI};
    
    try
        load('FinalOutput.mat','NeuronImage')
    catch
    load('FinalOutput.mat','cellROIs')
    if length(unique(cellROIs{1}))>2
        %Not a binary image
        NeuronImage = cellfun(@(x) x>0.4*max(x(:)),cellROIs,'UniformOutput',false);
    end
    end
    
    fullReg.cellCenters = [fullReg.cellCenters; getAllCellCenters(NeuronImage,[])];
    
    switch sessIndsOverlap
        case {'nonoverlap','independent'}
            fullReg.sessionInds([1:length(NeuronImage)]+size(fullReg.sessionInds,1),sessI) = [1:length(NeuronImage)]';
        case 'overlap'
            szDiff = length(NeuronImage)-size(fullReg.sessionInds,1);
            if szDiff > 0
                fullReg.sessionInds = [[fullReg.sessionInds zeros(size(fullReg.sessionInds,1),1)]; zeros(szDiff,sessI)];
            end
            
            fullReg.sessionInds(1:length(NeuronImage),sessI) = [1:length(NeuronImage)]';
    end
end
  
flPts = strsplit(fullReg.baseSession,'\');
baseDir = fullfile(flPts{1:end-1});
cd(baseDir)

save('realDays.mat','allFilesNames','realDays')
save('sessType.mat','sessType')
save('fullReg.mat','fullReg')

end
