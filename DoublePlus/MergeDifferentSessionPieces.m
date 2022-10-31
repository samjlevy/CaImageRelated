function MergeDifferentSessionPieces(foldersUse,cellRegInds,saveFolder)

% folders use as a cell array, cellReginds cell session inds
for fI = 1:numel(foldersUse)
    pb{fI} = load(fullfile(foldersUse{fI},'Pos_brain.mat'));
    ff{fI} = readtable(fullfile(foldersUse{fI},'PlusBehavior_BrainTime.xlsx'));
    
    % Also need fluorescence...
    traces{fI} = load(fullfile(foldersUse{fI},'FinalOutput.mat'), 'NeuronTraces');
    %tracesAdj{fI}.NeuronTraces.RawTrace = traces{fI}.NeuronTraces.RawTrace(:,pb{fI}.PSAboolUseIndices);
    %tracesAdj{fI}.NeuronTraces.LPtrace = traces{fI}.NeuronTraces.LPtrace(:,pb{fI}.PSAboolUseIndices);
    %tracesAdj{fI}.NeuronTraces.DFDTtrace = traces{fI}.NeuronTraces.DFDTtrace(:,pb{fI}.PSAboolUseIndices);

    nFrames(fI) = size(pb{fI}.PSAboolAdjusted,2);
end
nFrames = [0 nFrames];

% Rearrange cell SSI, stack positions
xBrain = [];
yBrain = [];

NeuronTraces.RawTrace = zeros(size(cellRegInds,1),sum(nFrames));
NeuronTraces.LPtrace = zeros(size(cellRegInds,1),sum(nFrames));
NeuronTraces.DFDTtrace = zeros(size(cellRegInds,1),sum(nFrames));

PSAboolAdjusted = false(size(cellRegInds,1),sum(nFrames));

PSAboolUseIndices = [];
for fI = 1:length(foldersUse)
    frameInds = (1:nFrames(fI+1))+sum(nFrames(1:fI));
    cellsHere = cellRegInds(:,fI);
    PSAboolAdjusted(cellsHere>0,frameInds) = pb{fI}.PSAboolAdjusted(cellsHere(cellsHere>0),:);
    
    NeuronTraces.RawTrace(cellsHere>0,frameInds) = traces{fI}.NeuronTraces.RawTrace(cellsHere(cellsHere>0),:);
    NeuronTraces.LPtrace(cellsHere>0,frameInds) = traces{fI}.NeuronTraces.LPtrace(cellsHere(cellsHere>0),:);
    NeuronTraces.DFDTtrace(cellsHere>0,frameInds) = traces{fI}.NeuronTraces.DFDTtrace(cellsHere(cellsHere>0),:);
    
    xBrain = [xBrain, pb{fI}.xBrain];
    yBrain = [yBrain, pb{fI}.yBrain];
    
    PSAboolUseIndices = [PSAboolUseIndices pb{fI}.PSAboolUseIndices+nFrames(fI)];
end

brain_time = [];
for fI = 1:length(foldersUse)
    if fI==1 
        brain_time = pb{fI}.brain_time;
    else
        brain_time = [brain_time, pb{fI}.brain_time+brain_time(end)];
    end
end
%{
for paI = 1:length(foldersUse)
    xx = ff{paI};
    xx.Correct = logical(xx.Correct);
    xx.AllowedFix = logical(xx.AllowedFix);
    xx.LapStart = xx.LapStart + sum(nFrames(1:paI));
    xx.LapStop = xx.LapStop + sum(nFrames(1:paI));
    nTrialsHere = size(xx,1);
    
    % Detect behavior:
    lapStarts = cellfun(@(x) x(1), xx.ArmSequence);
    lapStops = cellfun(@(x) x(end), xx.ArmSequence);
    if any((lapStarts=='n' | lapStarts=='s')==0)
        disp('Found a problem lap...')
        keyboard
    end
            
    if strcmpi(unique(lapStops(xx.Correct)),'e')
        % Rule is go east
        xx.Rule = repmat({'Place'},nTrialsHere,1);
    elseif sum( (lapStarts(xx.Correct)=='n' & lapStops(xx.Correct)=='w') |...
                (lapStarts(xx.Correct)=='s' & lapStops(xx.Correct)=='e') ) ...
                == sum(xx.Correct)
        % Rule is turn right
        xx.Rule = repmat({'Turn'},nTrialsHere,1);
    else
        stt = input('Did not identify this trial type; what is it? >> ','s');
        xx.Rule = repmat(stt,nTrialsHere,1);
    end
        
    if paI == 1
        xx.SessInd = ones(nTrialsHere,1);
        bigTable = xx;
    else
        switch strcmpi(bigTable.Rule(end,:),xx.Rule(1,:))
            case 0 % If a different trial type from last epoch...
                xx.SessInd = ones(nTrialsHere,1)*(bigTable.SessInd(end)+1);
            case 1
                xx.SessInd = ones(nTrialsHere,1)*(bigTable.SessInd(end));
        end
        bigTable = [bigTable; xx];
    end

end

nTrials = size(bigTable,1);
bigTable.TrialNum(:) = [1:nTrials]'; 

saveName = 'PlusBehavior_BrainTime_Finalized.xlsx';

writetable(bigTable,fullfile(saveFolder,saveName))
%}
save(fullfile(saveFolder,'Pos_brain.mat'),'PSAboolAdjusted','NeuronTraces','xBrain','yBrain','nFrames','brain_time','PSAboolUseIndices')

end