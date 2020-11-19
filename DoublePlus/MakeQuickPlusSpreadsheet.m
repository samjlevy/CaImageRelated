function MakeQuickPlusSpreadsheet

sessType = questdlg('Session Type:','Sess Type','Within Day','Turn Right','Go East','Turn Right');

behVariables = load('plusMazeBehavior.mat');
load('posAnchored.mat','v0')

numTrials = length(behVariables.trialEpoch);

labels = {'center','north','east','south','west'};
labelsAbbrev = {'m','n','e','s','w'};
[sequences,~] = cellfun(@filterSeqToUnique,behVariables.trialSeqs,'UniformOutput',false);
seqLabeled = cellfun(@(x) [labelsAbbrev{x}],sequences,'UniformOutput',false);

startArm =  cell2mat(cellfun(@(x) x(1),behVariables.trialSeqs,'UniformOutput',false))';
lastArm = cell2mat(cellfun(@(x) x(end),behVariables.trialSeqs,'UniformOutput',false))';
targetArm = nan(numTrials,1);
switch sessType
    case 'Within Day'
        for epochI = 1:length(unique(behVariables.trialEpoch))
            rewardArm(epochI,1) = mode(lastArm(behVariables.trialEpoch==epochI));
            targetArm(behVariables.trialEpoch==epochI) = rewardArm(epochI,1);
        end
        trialCorrect = lastArm == targetArm;
        
    case 'Turn Right'
        nStart = startArm == 2;
        sStart = startArm == 4;
        eFinish = lastArm == 3;
        wFinish = lastArm == 5;
        
        trialCorrect = (nStart & wFinish) | (sStart & eFinish);
    case 'Go East'
        eFinish = lastArm == 3;
        trialCorrect = eFinish;
end
   
allowedFix = cell2mat(cellfun(@length,sequences,'UniformOutput',false))'>3;
    
%Check for bad laps
haveBounds = cell2mat(cellfun(@length,behVariables.trialBounds,'UniformOutput',false));
if any(haveBounds~=2)
    disp('found some bad laps')
    disp(['laps: ' num2str(find(haveBounds~=2))])
    keyboard
end
lapBounds = cell2mat(behVariables.trialBounds');

PlusDataTable = table([1:numTrials]',...
                      behVariables.trialEpoch,...
                      seqLabeled',...
                      lapBounds(:,1),...
                      lapBounds(:,2),...
                      trialCorrect,...
                      allowedFix,...
     'VariableNames',{'TrialNum','Epoch','ArmSequence','LapStart','LapStop','Correct','AllowedFix'});
 
writetable(PlusDataTable,'PlusBehavior.xlsx')

end

    