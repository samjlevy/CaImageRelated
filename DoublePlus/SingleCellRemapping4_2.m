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
        for condI = 1:numConds
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
