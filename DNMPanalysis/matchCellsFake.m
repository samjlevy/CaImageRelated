function matchCellsFake(base_path, reg_paths)
%This puts together a fullReg for sessions that aren't actually registered.
%Session inds just makes new entries for every single cell. 
load(fullfile(base_path,'FinalOutput.mat'),'NeuronImage') %,'NeuronAvg'
baseImage = NeuronImage;
fullReg.sessionInds = [1:length(baseImage)]'; %#ok<NBRAK>
fullReg.BaseSession = base_path;
fullReg.RegSessions = {};
%fullReg.centers = base_cellCenters; 
%fullReg.orientation = cell2mat(cellfun(@(x) x.Orientation, baseOrientation, 'UniformOutput',false))';
    
%fullRegImage = baseImage;
%fullRegROIavg = MakeAvgROI(NeuronImage,NeuronAvg);

for regI = 1:length(reg_paths)

    reg_path = reg_paths{regI};
    
    load(fullfile(reg_path,'FinalOutput.mat'),'NeuronImage')
    
    newCol = size(fullReg.sessionInds,2) + 1;

    newRow = size(fullReg.sessionInds,1) + 1;
    newFakeCells = newRow:newRow+length(NeuronImage)-1;
    %Assign matched cells' indices to corresponding base cells
    fullReg.sessionInds(newFakeCells, newCol) = 1:length(NeuronImage);

    fullReg.RegSessions{regI} = reg_path;

    try
        save(fullfile(base_path,'fullRegFake.mat'),'fullReg','-v7.3')
        %save(fullfile(base_path,'fullRegImage.mat'),'fullRegImage','-v7.3')
        %save(fullfile(base_path,'fullRegROIavg.mat'),'fullRegROIavg','-v7.3')
        disp('worked, saved')
    catch
        keyboard
    end
end

end