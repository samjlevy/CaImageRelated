%SingleCellRemapping4_2

%Center of mass shift
allFiringCOM = cell(numMice,1);
oneEnvCOMchanges = cell(numDayPairs,1); oneEnvCOMchangesCellsUse = cell(numDayPairs,1);
twoEnvCOMchanges = cell(numDayPairs,1); twoEnvCOMchangesCellsUse = cell(numDayPairs,1);
for mouseI = 1:numMice
    allFiringCOM{mouseI} = TMapFiringCOM(cellTMapH{mouseI});
    
    for dpI = 1:numDayPairs
        comsA = squeeze(allFiringCOM{mouseI}(:,dayPairsForward(dpI,1),:));
        comsB = squeeze(allFiringCOM{mouseI}(:,dayPairsForward(dpI,2),:));
        COMchanges{mouseI}{dpI} = abs(comsB - comsA); %(cell, cond)
    
        %Ultimately want to compare this to a shuffle, is diff greater than suffle
        
        % Cell inclusion
        %cellsUseHere = sum(dayUseAll{mouseI}(:,dayPairsForward(dpI,:)),2) > 0;
        cellsUseHere = sum(sum(dayUse{mouseI}(:,dayPairsForward(dpI,:),condsUse)>0,3),2) > 0;
        haveCellBothDays = sum(cellSSI{mouseI}(:,dayPairsForward(dpI,:))>0,2)==2;
        
        cellsUseHere = cellsUseHere & haveCellBothDays;
        
        COMcellsUse{mouseI}{dpI} = repmat(cellsUseHere,1,numConds);
        % Aggregate data
        switch groupNum(mouseI)
            case 1
                oneEnvCOMchanges{dpI} = [oneEnvCOMchanges{dpI}; COMchanges{mouseI}{dpI}];%(cell, cond)
                oneEnvCOMchangesCellsUse{dpI} = logical([oneEnvCOMchangesCellsUse{dpI}; COMcellsUse{mouseI}{dpI}]);
            case 2
                twoEnvCOMchanges{dpI} = [twoEnvCOMchanges{dpI}; COMchanges{mouseI}{dpI}];
                twoEnvCOMchangesCellsUse{dpI} = logical([twoEnvCOMchangesCellsUse{dpI}; COMcellsUse{mouseI}{dpI}]);
        end
        
    end
    
end
    

%Rate Remapping:
meanRates = []; meanRateDiffs = []; pctChangeMean = [];
oneEnvMeanRateDiffs = cell(numDayPairs,1); oneEnvMeanRatePctChange = cell(numDayPairs,1);
oneEnvFiredEither = cell(numDayPairs,1); twoEnvFiredEither = cell(numDayPairs,1);
twoEnvMeanRateDiffs = cell(numDayPairs,1); twoEnvMeanRatePctChange = cell(numDayPairs,1);
oneEnvMeanRateCellsUse = cell(numDayPairs,1); twoEnvMeanRateCellsUse = cell(numDayPairs,1);
oneEnvFiredBoth = cell(numDayPairs,1); twoEnvFiredBoth = cell(numDayPairs,1);
for mouseI = 1:numMice
    meanRates{mouseI} = cell2mat(cellfun(@mean,cellTMapH{mouseI},'UniformOutput',false));
    for dpI = 1:numDayPairs
        mratesA = squeeze(meanRates{mouseI}(:,dayPairsForward(dpI,1),:));
        mratesB = squeeze(meanRates{mouseI}(:,dayPairsForward(dpI,2),:));
        mratesAll = [];
        mratesAll(:,:,1) = mratesA; 
        mratesAll(:,:,2) = mratesB;
        mfiredEither = sum(mratesAll,3)>0;
        mfiredBoth = sum(mratesAll>0,3)==2;
        meanRateDiffs{mouseI}{dpI} = max(mratesAll,[],3) - min(mratesAll,[],3);
        pctChangeMean{mouseI}{dpI} = meanRateDiffs{mouseI}{dpI} ./ max(mratesAll,[],3);
        
        % Cell inclusion
        %cellsUseHere = sum(dayUseAll{mouseI}(:,dayPairsForward(dpI,:)),2) > 0;
        cellsUseHere = sum(sum(dayUse{mouseI}(:,dayPairsForward(dpI,:),condsUse)>0,3),2) > 0;
        haveCellBothDays = sum(cellSSI{mouseI}(:,dayPairsForward(dpI,:))>0,2)==2;
        
        cellsUseHere = cellsUseHere & haveCellBothDays;
        
        switch groupNum(mouseI)
            case 1
                oneEnvMeanRateDiffs{dpI} = [oneEnvMeanRateDiffs{dpI}; meanRateDiffs{mouseI}{dpI}];%(cell, cond)
                oneEnvMeanRatePctChange{dpI} = [oneEnvMeanRatePctChange{dpI}; pctChangeMean{mouseI}{dpI}];
                oneEnvFiredEither{dpI} = [oneEnvFiredEither{dpI}; mfiredEither];
                oneEnvFiredBoth{dpI} = [oneEnvFiredBoth{dpI}; mfiredBoth];
                
                oneEnvMeanRateCellsUse{dpI} = logical([oneEnvMeanRateCellsUse{dpI}; repmat(cellsUseHere,1,numConds)]);
            case 2
                twoEnvMeanRateDiffs{dpI} = [twoEnvMeanRateDiffs{dpI}; meanRateDiffs{mouseI}{dpI}];
                twoEnvMeanRatePctChange{dpI} = [twoEnvMeanRatePctChange{dpI}; pctChangeMean{mouseI}{dpI}];
                twoEnvFiredEither{dpI} = [twoEnvFiredEither{dpI}; mfiredEither];
                twoEnvFiredBoth{dpI} = [twoEnvFiredBoth{dpI}; mfiredBoth];
                
                twoEnvMeanRateCellsUse{dpI} = logical([twoEnvMeanRateCellsUse{dpI}; repmat(cellsUseHere,1,numConds)]);
        end
    end
end

%Arm preference
oneEnvSameArms = cell(numDayPairs,1); oneEnvSameArmsID = cell(numDayPairs,1);
twoEnvSameArms = cell(numDayPairs,1); twoEnvSameArmsID = cell(numDayPairs,1);
for mouseI = 1:numMice
    [armPref{mouseI}] = CondFiringPreference(cellTMapH{mouseI});
    firedAtAll = sum(trialReli{mouseI},3)>0;
    
    for dpI = 1:numDayPairs
        firedBothDays = sum(firedAtAll(:,dayPairsForward(dpI,:)),2)==2;
        aboveThresh = sum(dayUseAll{mouseI}(:,dayPairsForward(dpI,:)),2)>0;
        
        %armsA = armPref{mouseI}(firedBothDays,dayPairsForward(dpI,1));
        %armsB = armPref{mouseI}(firedBothDays,dayPairsForward(dpI,2));
        armsA = armPref{mouseI}(:,dayPairsForward(dpI,1));
        armsB = armPref{mouseI}(:,dayPairsForward(dpI,2));
        
        sameArm = armsA==armsB;
        cellsUseHere = firedBothDays & aboveThresh;
            % Cell had transients on the maze both days, was above activity
            % threshold at least one of those days
        
        sameArmID = armsA;
        sameArm = sameArm(cellsUseHere);
        sameArmID = sameArmID(cellsUseHere);
        
        sameArmPct(mouseI,dpI) = sum(sameArm)/length(sameArm);
        switch groupNum(mouseI)
            case 1
                oneEnvSameArms{dpI} = [oneEnvSameArms{dpI}; sameArm];
                oneEnvSameArmsID{dpI} = [oneEnvSameArmsID{dpI}; sameArmID];
            case 2
                twoEnvSameArms{dpI} = [twoEnvSameArms{dpI}; sameArm];
                twoEnvSameArmsID{dpI} = [twoEnvSameArmsID{dpI}; sameArmID];
                
        end
        
        sameArmEach{mouseI}{dpI} = sameArm;
        fbd{mouseI}{dpI} = firedBothDays;
    end
end
oneEnvSameArmsPct = cell2mat(cellfun(@(x) sum(x)/length(x),oneEnvSameArms,'UniformOutput',false));
twoEnvSameArmsPct = cell2mat(cellfun(@(x) sum(x)/length(x),twoEnvSameArms,'UniformOutput',false));

% Single neuron ratemap corrs

dayPairsH = CombinationMatcher(corrsLoaded.allDayPairs, dayPairsForward);

% Rate map correlations
singleCellCorrsRho = []; singleCellCorrsP = [];
oneEnvCorrsAll = cell(numDayPairs,1); oneEnvCorrsEach = cell(numDayPairs,numConds);
twoEnvCorrsAll = cell(numDayPairs,1); twoEnvCorrsEach = cell(numDayPairs,numConds);
oneEnvCorrsPall = cell(numDayPairs,1); oneEnvCorrsPeach = cell(numDayPairs,numConds);
twoEnvCorrsPall = cell(numDayPairs,1); twoEnvCorrsPeach = cell(numDayPairs,numConds);
oneEnvCorrsPallPct = cell(numDayPairs,1); oneEnvCorrsPeachPct = cell(numDayPairs,numConds);
twoEnvCorrsPallPct = cell(numDayPairs,1); twoEnvCorrsPeachPct = cell(numDayPairs,numConds);
oneEnvCorrsSingle = cell(numDayPairs,1); oneEnvCorrsSingleP = cell(numDayPairs,1);
twoEnvCorrsSingle = cell(numDayPairs,1); twoEnvCorrsSingleP = cell(numDayPairs,1);
for mouseI = 1:numMice
    
    %[singleCellCorrsRho{mouseI}, singleCellCorrsP{mouseI}] = singleNeuronCorrelations(cellTMapH{mouseI},dayPairsForward,[]);%turnBinsUse
    %{mouseI}{condI}{dayPairI}(cellI)
    %pooledTmap = cell(numCells(mouseI),9);
    %for cellI = 1:numCells(mouseI)
    %    for dayI = 1:9
    %        pooledTmap{cellI,dayI} = vertcat(cellTMapH{mouseI}{cellI,dayI,:});
    %    end
    %end
    %[singleCellAllCorrsRho{mouseI}, singleCellAllCorrsP{mouseI}] = singleNeuronCorrelations(pooledTmap,dayPairsForward,[]);%turnBinsUse
   
    for condI = 1:numel(condsUse)
        condJ = condsUse(condI);
        singleCellCorrsRho{mouseI}{condI} = corrsLoaded.singleCellCorrsRho{mouseI}{condJ}(dayPairsH);
        singleCellCorrsP{mouseI}{condI} = corrsLoaded.singleCellCorrsP{mouseI}{condJ}(dayPairsH);
    end
    
    switch length(condsUse)
        case 3
            disp('Assuming condsUse is [1 3 4]')
            singleCellAllCorrsRho{mouseI}{1} = corrsLoaded.singleCellThreeCorrsRho{mouseI}{1}(dayPairsH);
            singleCellAllCorrsP{mouseI}{1} = corrsLoaded.singleCellThreeCorrsP{mouseI}{1}(dayPairsH);
        case 4
            singleCellAllCorrsRho{mouseI}{1} = corrsLoaded.singleCellAllCorrsRho{mouseI}{1}(dayPairsH);
            singleCellAllCorrsP{mouseI}{1} = corrsLoaded.singleCellAllCorrsP{mouseI}{1}(dayPairsH);
        otherwise
            disp('Unaccounted for conds use')
    end
   
   
    for dpI = 1:numDayPairs
        %cellBothDays{mouseI}{dpI} = sum(dayUseAll{mouseI}(:,dayPairsForward(dpI,:)),2) > 0;
        cellBothDays = sum(sum(dayUse{mouseI}(:,dayPairsForward(dpI,:),condsUse),3)>0,2) > 0;
        haveCellBothDays = sum(cellSSI{mouseI}(:,dayPairsForward(dpI,:))>0,2)==2;
        
        cellsUseHere = cellBothDays & haveCellBothDays;
        
        pvCellsUse{mouseI}{dpI} = cellsUseHere;
        
        pValsAgg = [];
        for condI = 1:numel(condsUse)
            corrsHere = singleCellCorrsRho{mouseI}{condI}{dpI}(cellsUseHere);
            pValsHere = singleCellCorrsP{mouseI}{condI}{dpI}(cellsUseHere);
            pValsAgg = [pValsAgg; pValsHere];
            
            switch groupNum(mouseI)
                case 1
                    oneEnvCorrsAll{dpI} = [oneEnvCorrsAll{dpI}; corrsHere];
                    oneEnvCorrsEach{dpI,condI} = [oneEnvCorrsEach{dpI,condI}; corrsHere];
                    oneEnvCorrsPall{dpI} = [oneEnvCorrsPall{dpI}; pValsHere];
                    oneEnvCorrsPeach{dpI,condI} = [oneEnvCorrsPeach{dpI,condI}; pValsHere];
                    oneEnvCorrsPeachPct{dpI,condI} = [oneEnvCorrsPeachPct{dpI,condI}; sum(pValsHere<pThresh)/length(pValsHere)];
                case 2
                    twoEnvCorrsAll{dpI} = [twoEnvCorrsAll{dpI}; corrsHere];
                    twoEnvCorrsEach{dpI,condI} = [twoEnvCorrsEach{dpI,condI}; corrsHere];
                    twoEnvCorrsPall{dpI} = [twoEnvCorrsPall{dpI}; pValsHere];
                    twoEnvCorrsPeach{dpI,condI} = [twoEnvCorrsPeach{dpI,condI}; pValsHere];
                    twoEnvCorrsPeachPct{dpI,condI} = [twoEnvCorrsPeachPct{dpI,condI}; sum(pValsHere<pThresh)/length(pValsHere)];
            end
            
        end
        
        switch groupNum(mouseI)
            case 1
                oneEnvCorrsPallPct{dpI} = [oneEnvCorrsPallPct{dpI}; sum(pValsAgg<pThresh)/length(pValsAgg)];
                oneEnvCorrsSingle{dpI} = [oneEnvCorrsSingle{dpI}; singleCellAllCorrsRho{mouseI}{1}{dpI}(cellBothDays)];
                oneEnvCorrsSingleP{dpI} = [oneEnvCorrsSingleP{dpI}; singleCellAllCorrsP{mouseI}{1}{dpI}(cellBothDays)];
            case 2
                twoEnvCorrsPallPct{dpI} = [twoEnvCorrsPallPct{dpI}; sum(pValsAgg<pThresh)/length(pValsAgg)];
                twoEnvCorrsSingle{dpI} = [twoEnvCorrsSingle{dpI}; singleCellAllCorrsRho{mouseI}{1}{dpI}(cellBothDays)];
                twoEnvCorrsSingleP{dpI} = [twoEnvCorrsSingleP{dpI}; singleCellAllCorrsP{mouseI}{1}{dpI}(cellBothDays)];
        end
        
    end
    
        
        
        
end     

% Reliability changes
% Should break this up by whether same rule or different rule
% Maybe do it for all days, etc. 
% Also this probably needs to be moved into main analysis...

% Questions: 
%     Does remapping happen preferentially to low activity cells?
%     Is there any relationship with remapping and changing reliability?
%     Same cell: across multiple pairs of days, remaps more or less with
%     its own differences in reliability?

%oneEnvRemapReli = cell(1,numDayPairs); oneEnvRemapRho = cell(1,numDayPairs); oneEnvRemapP = cell(1,numDayPairs);
%twoEnvRemapReli = cell(1,numDayPairs); twoEnvRemapRho = cell(1,numDayPairs); twoEnvRemapP = cell(1,numDayPairs);

oneEnvRemapReliEach = cell(numDayPairs,numel(condsUse)); oneEnvRemapRhoEach = cell(numDayPairs,numel(condsUse)); oneEnvRemapPEach = cell(numDayPairs,numel(condsUse));
twoEnvRemapReliEach = cell(numDayPairs,numel(condsUse)); twoEnvRemapRhoEach = cell(numDayPairs,numel(condsUse)); twoEnvRemapPEach = cell(numDayPairs,numel(condsUse));
for mouseI = 1:numMice
    for dpI = 1:numDayPairs
        haveCellBothDays = sum(cellSSI{mouseI}(:,dayPairsForward(dpI,:))>0,2)==2;
        %aboveThreshOneDay = sum(dayUseAll{mouseI}(:,dayPairsForward(dpI,:)),2) >= 1;
        firedOnMazeOneDays = sum(trialReliAll{mouseI}(:,dayPairsForward(dpI,:))>0,2) >= 1;
        firedOnMazeBothDays = sum(trialReliAll{mouseI}(:,dayPairsForward(dpI,:))>0,2) == 2;
        % This version restricts to conds used...
        % firedOnMazeBothDays = sum(sum(trialReli{mouseI}(:,dayPairsForward(dpI,:),condsUse),3)>0,2) == 2;
        
        reliAllH = trialReliAll{mouseI}(:,dayPairsForward(dpI,1));
        
        cellsUseH = haveCellBothDays & firedOnMazeBothDays; %& aboveThreshOneDay;
        
        reliChange = trialReliAll{mouseI}(:,dayPairsForward(dpI,2)) - trialReliAll{mouseI}(:,dayPairsForward(dpI,1));
        switch groupNum(mouseI)
            case 1
                oneEnvRemapReli{mouseI}{dpI} = reliAllH(cellsUseH);
                oneEnvRemapReliChange{mouseI}{dpI} = reliChange(cellsUseH);
                oneEnvRemapRho{mouseI}{dpI} = singleCellAllCorrsRho{mouseI}{1}{dpI}(cellsUseH);
                oneEnvRemapP{mouseI}{dpI} = singleCellAllCorrsP{mouseI}{1}{dpI}(cellsUseH);
                oneEnvRemapCellsUse{mouseI}{dpI} = cellsUseH;
            case 2
                twoEnvRemapReli{mouseI}{dpI} = reliAllH(cellsUseH);
                twoEnvRemapReliChange{mouseI}{dpI} = reliChange(cellsUseH);
                twoEnvRemapRho{mouseI}{dpI} = singleCellAllCorrsRho{mouseI}{1}{dpI}(cellsUseH);
                twoEnvRemapP{mouseI}{dpI} = singleCellAllCorrsP{mouseI}{1}{dpI}(cellsUseH);
                twoEnvRemapCellsUse{mouseI}{dpI} = cellsUseH;
        end
        
        %{
        switch groupNum(mouseI)
            case 1
                oneEnvRemapReli{dpI} = [oneEnvRemapReli{dpI}; reliAllH(cellsUseH)];
                oneEnvRemapRho{dpI} = [oneEnvRemapRho{dpI}; singleCellAllCorrsRho{mouseI}{1}{dpI}(cellsUseH)];
                oneEnvRemapP{dpI} = [oneEnvRemapP{dpI}; singleCellAllCorrsP{mouseI}{1}{dpI}(cellsUseH)];
            case 2
                twoEnvRemapReli{dpI} = [twoEnvRemapReli{dpI}; reliAllH(cellsUseH)];
                twoEnvRemapRho{dpI} = [twoEnvRemapRho{dpI}; singleCellAllCorrsRho{mouseI}{1}{dpI}(cellsUseH)];
                twoEnvRemapP{dpI} = [twoEnvRemapP{dpI}; singleCellAllCorrsP{mouseI}{1}{dpI}(cellsUseH)];
        end
        %}
        
        %Each arm
        for condI = 1:numel(condsUse)
            % Need something here to kick out cond with less than 1 trial;
            % covered by this?
            if numSessTrials{mouseI}(dayPairsForward(dpI,1),condI) > 1
            firedOnMazeOneDays = sum(trialReli{mouseI}(:,dayPairsForward(dpI,:),condI)>0,2) >= 1;
            firedOnMazeBothDays = sum(trialReli{mouseI}(:,dayPairsForward(dpI,:),condI)>0,2) == 2;
                        
            reliAllH = trialReli{mouseI}(:,dayPairsForward(dpI,1),condI);
            cellsUseH = haveCellBothDays & firedOnMazeBothDays;
            switch groupNum(mouseI)
                case 1
                    oneEnvRemapReliEach{dpI,condI} = [oneEnvRemapReliEach{dpI,condI}; reliAllH(cellsUseH)];
                    oneEnvRemapRhoEach{dpI,condI} = [oneEnvRemapRhoEach{dpI,condI}; singleCellCorrsRho{mouseI}{condI}{dpI}(cellsUseH)];
                    oneEnvRemapPEach{dpI,condI} = [oneEnvRemapPEach{dpI,condI}; singleCellCorrsP{mouseI}{condI}{dpI}(cellsUseH)];
                case 2
                    twoEnvRemapReliEach{dpI,condI} = [twoEnvRemapReliEach{dpI,condI}; reliAllH(cellsUseH)];
                    twoEnvRemapRhoEach{dpI,condI} = [twoEnvRemapRhoEach{dpI,condI}; singleCellCorrsRho{mouseI}{condI}{dpI}(cellsUseH)];
                    twoEnvRemapPEach{dpI,condI} = [twoEnvRemapPEach{dpI,condI}; singleCellCorrsP{mouseI}{condI}{dpI}(cellsUseH)];
            end
            
            end
        end
    end
end


% MI of activity across arms
MI = [];
for mouseI = 1:numMice
    for sessI = 1:9
        for condI = 1:4
            nDayTrials(condI) = sum(cellTBT{mouseI}(condI).sessID == sessI);
        end
        
        if any(nDayTrials)
            for cellI = 1:numCells(mouseI)
                [MI{mouseI}(cellI,sessI)] = ModulationIndex(squeeze(numTrialsFired{mouseI}(cellI,sessI,:)));
            end
        end
    end
end

MIthree = [];
for mouseI = 1:numMice
    for sessI = 1:9
        for condI = 1:4
            nDayTrials(condI) = sum(cellTBT{mouseI}(condI).sessID == sessI);
        end
        
        if any(nDayTrials)
            for cellI = 1:numCells(mouseI)
                [MIthree{mouseI}(cellI,sessI)] = ModulationIndex(squeeze(numTrialsFired{mouseI}(cellI,sessI,condsUse)));
            end
        end
    end
end

for mouseI = 1:numMice
    for dpI = 1:numDayPairs
        
        haveCellBothDays = sum(cellSSI{mouseI}(:,dayPairsForward(dpI,:))>0,2)==2;
        aboveThreshOneDay = sum(dayUseAll{mouseI}(:,dayPairsForward(dpI,:)),2) >= 1;
        firedOnMazeOneDays = sum(trialReliAll{mouseI}(:,dayPairsForward(dpI,:))>0,2) >= 1;
        firedOnMazeBothDays = sum(trialReliAll{mouseI}(:,dayPairsForward(dpI,:))>0,2) == 2;
        % This version restricts to conds used...
        % firedOnMazeBothDays = sum(sum(trialReli{mouseI}(:,dayPairsForward(dpI,:),condsUse),3)>0,2) == 2;
        
        cellsUseH = haveCellBothDays & firedOnMazeBothDays & aboveThreshOneDay;
        
        MIdiffs = MI{mouseI}(:,dayPairsForward(dpI,2)) - MI{mouseI}(:,dayPairsForward(dpI,1));
        %MIdiff{mouseI}{dpI} = MIdiffs(cellsUseH);
        MIdiff{mouseI}{dpI} = MIdiffs;
        
        % 3 cond
        aboveThreshOneDay = sum(sum(dayUse{mouseI}(:,dayPairsForward(dpI,:),condsUse),2),3) >= 1;
        firedOnMazeOneDays = sum(sum(trialReli{mouseI}(:,dayPairsForward(dpI,:),condsUse)>0,3),2) >= 1;
        firedOnMazeBothDays = sum(sum(trialReli{mouseI}(:,dayPairsForward(dpI,:),condsUse)>0,3),2) == 2;
        
        cellsUseHeach  = haveCellBothDays & firedOnMazeBothDays & aboveThreshOneDay;
        MIthreeDiffs = MIthree{mouseI}(:,dayPairsForward(dpI,2)) - MIthree{mouseI}(:,dayPairsForward(dpI,1));
        %MIthreeDiff{mouseI}{dpI} = MIthreeDiffs(cellsUseH);
        MIthreeDiff{mouseI}{dpI} = MIthreeDiffs;
        
    end
end
%Absolute remapping
%{
oneMazeHaveBothAgg = cell(1,numDayPairs);
oneMazeStartFiringAgg = cell(1,numDayPairs);
oneMazeStopFiringAgg = cell(1,numDayPairs);

twoMazeHaveBothAgg = cell(1,numDayPairs);
twoMazeStartFiringAgg = cell(1,numDayPairs);
twoMazeStopFiringAgg = cell(1,numDayPairs);
oneMazeHaveBothEachAgg = cell(numDayPairs,numConds);
oneMazeStartFiringEachAgg = cell(numDayPairs,numConds);
oneMazeStopFiringEachAgg = cell(numDayPairs,numConds);

twoMazeHaveBothEachAgg = cell(numDayPairs,numConds);
twoMazeStartFiringEachAgg = cell(numDayPairs,numConds);
twoMazeStopFiringEachAgg = cell(numDayPairs,numConds);

oneArmActiveChange = cell(1,numDayPairs); twoArmActiveChange = cell(1,numDayPairs);
for mouseI = 1:numMice
    for dpI = 1:numDayPairs
        anyActive = sum(dayUseAll{mouseI}(:,dayPairsForward(dpI,:)),1);
        if sum(anyActive>0) == 2
            % Day change at all above thresh
            cellAboveThresh = sum(dayUse{mouseI}(:,dayPairsForward(dpI,:),condsUse),3)>0;
            haveCellBothDays = sum(cellSSI{mouseI}(:,dayPairsForward(dpI,:))>0,2)==2;
            cellsUseHere = sum(cellAboveThresh,2)>0 & haveCellBothDays;
            
            cellBothDays = sum(cellAboveThresh(cellsUseHere,:),2)==2;
            cellOneDay = sum(cellAboveThresh(cellsUseHere,:),2)==1;
            
            cellFirstDay = cellAboveThresh(cellsUseHere,1);
            cellSecondDay = cellAboveThresh(cellsUseHere,2);
            
            startsFiring = cellSecondDay & cellOneDay;
            stopsFiring = cellFirstDay & cellOneDay;
            
            nHaveBoth = sum(haveCellBothDays);
            
            pctHaveBoth{mouseI}(dpI,1) = sum(cellBothDays)/nHaveBoth;
            pctStartFiring{mouseI}(dpI,1) = sum(startsFiring)/nHaveBoth;
            pctStopFiring{mouseI}(dpI,1) = sum(stopsFiring)/nHaveBoth;
            
            switch groupNum(mouseI)
                case 1
                    oneMazeHaveBothAgg{dpI} = [oneMazeHaveBothAgg{dpI}; pctHaveBoth{mouseI}(dpI)];
                    oneMazeStartFiringAgg{dpI} = [oneMazeStartFiringAgg{dpI}; pctStartFiring{mouseI}(dpI)];
                    oneMazeStopFiringAgg{dpI} = [oneMazeStopFiringAgg{dpI}; pctStopFiring{mouseI}(dpI)];
                case 2
                    twoMazeHaveBothAgg{dpI} = [twoMazeHaveBothAgg{dpI}; pctHaveBoth{mouseI}(dpI)];
                    twoMazeStartFiringAgg{dpI} = [twoMazeStartFiringAgg{dpI}; pctStartFiring{mouseI}(dpI)];
                    twoMazeStopFiringAgg{dpI} = [twoMazeStopFiringAgg{dpI}; pctStopFiring{mouseI}(dpI)];
            end
                
            for condI = 1:numel(condsUse)
                cellAboveThresh = dayUse{mouseI}(:,dayPairsForward(dpI,:),condsUse(condI));
                haveCellBothDays = sum(cellSSI{mouseI}(:,dayPairsForward(dpI,:))>0,2)==2;
                cellsUseHere = sum(cellAboveThresh,2)>0 & haveCellBothDays;
            
                cellBothDays = sum(cellAboveThresh(cellsUseHere,:),2)==2;
                cellOneDay = sum(cellAboveThresh(cellsUseHere,:),2)==1;
            
                cellFirstDay = cellAboveThresh(cellsUseHere,1);
                cellSecondDay = cellAboveThresh(cellsUseHere,2);
            
                startsFiring = cellSecondDay & cellOneDay;
                stopsFiring = cellFirstDay & cellOneDay;
            
                nHaveBoth = sum(haveCellBothDays);
            
                pctHaveBothEach{mouseI}(dpI,condI) = sum(cellBothDays)/nHaveBoth;
                pctStartFiringEach{mouseI}(dpI,condI) = sum(startsFiring)/nHaveBoth;
                pctStopFiringEach{mouseI}(dpI,condI) = sum(stopsFiring)/nHaveBoth;
                
                switch groupNum(mouseI)
                    case 1
                        oneMazeHaveBothEachAgg{dpI,condI} = [oneMazeHaveBothEachAgg{dpI,condI}; pctHaveBothEach{mouseI}(dpI,condI)];
                        oneMazeStartFiringEachAgg{dpI,condI} = [oneMazeStartFiringEachAgg{dpI,condI}; pctStartFiringEach{mouseI}(dpI,condI)];
                        oneMazeStopFiringEachAgg{dpI,condI} = [oneMazeStopFiringEachAgg{dpI,condI}; pctStopFiringEach{mouseI}(dpI,condI)];
                    case 2
                        twoMazeHaveBothEachAgg{dpI,condI} = [twoMazeHaveBothEachAgg{dpI,condI}; pctHaveBothEach{mouseI}(dpI,condI)];
                        twoMazeStartFiringEachAgg{dpI,condI} = [twoMazeStartFiringEachAgg{dpI,condI}; pctStartFiringEach{mouseI}(dpI,condI)];
                        twoMazeStopFiringEachAgg{dpI,condI} = [twoMazeStopFiringEachAgg{dpI,condI}; pctStopFiringEach{mouseI}(dpI,condI)];
                end
            end
            
            % Distribution across arms
            %haveCellBothDays = sum(cellSSI{mouseI}(:,dayPairsForward(dpI,:))>0,2)==2;
            armActiveA = squeeze(dayUse{mouseI}(:,dayPairsForward(dpI,1),condsUse));
            nActiveA = sum(armActiveA,1);
            totalActiveA = sum(dayUseAll{mouseI}(:,dayPairsForward(dpI,1)));
            pctActiveA = nActiveA/totalActiveA;
            
            armActiveB = squeeze(dayUse{mouseI}(:,dayPairsForward(dpI,2),condsUse));
            nActiveB = sum(armActiveB,1);
            totalActiveB = sum(dayUseAll{mouseI}(:,dayPairsForward(dpI,2)));
            pctActiveB = nActiveB/totalActiveB;
            
            pctArmActiveChange{mouseI}(dpI,:) = pctActiveB-pctActiveA;
            
            switch groupNum(mouseI)
                case 1
                    oneArmActiveChange{dpI} = [oneArmActiveChange{dpI}; pctArmActiveChange{mouseI}];
                case 2
                    twoArmActiveChange{dpI} = [twoArmActiveChange{dpI}; pctArmActiveChange{mouseI}];
            end
        end
            
    end   
end

%}
