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
            singleCellAllCorrsRho{mouseI} = corrsLoaded.singleCellThreeCorrsRho{mouseI};
            singleCellAllCorrsP{mouseI} = corrsLoaded.singleCellThreeCorrsP{mouseI};
        case 4
            singleCellAllCorrsRho{mouseI} = corrsLoaded.singleCellAllCorrsRho{mouseI};
            singleCellAllCorrsP{mouseI} = corrsLoaded.singleCellAllCorrsP{mouseI};
        otherwise
            disp('Unaccounted for conds use')
    end
   
   
    for dpI = 1:numDayPairs
        %cellBothDays{mouseI}{dpI} = sum(dayUseAll{mouseI}(:,dayPairsForward(dpI,:)),2) > 0;
        cellBothDays{mouseI}{dpI} = sum(sum(dayUse{mouseI}(:,dayPairsForward(dpI,:),condsUse),3)>0,2) > 0;
        haveCellBothDays = sum(cellSSI{mouseI}(:,dayPairsForward(dpI,:))>0,2)==2;
        
        cellsUseHere = cellBothDays{mouseI}{dpI} & haveCellBothDays;
        
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
                oneEnvCorrsSingle{dpI} = [oneEnvCorrsSingle{dpI}; singleCellAllCorrsRho{mouseI}{1}{dpI}(cellBothDays{mouseI}{dpI})];
                oneEnvCorrsSingleP{dpI} = [oneEnvCorrsSingleP{dpI}; singleCellAllCorrsP{mouseI}{1}{dpI}(cellBothDays{mouseI}{dpI})];
            case 2
                twoEnvCorrsPallPct{dpI} = [twoEnvCorrsPallPct{dpI}; sum(pValsAgg<pThresh)/length(pValsAgg)];
                twoEnvCorrsSingle{dpI} = [twoEnvCorrsSingle{dpI}; singleCellAllCorrsRho{mouseI}{1}{dpI}(cellBothDays{mouseI}{dpI})];
                twoEnvCorrsSingleP{dpI} = [twoEnvCorrsSingleP{dpI}; singleCellAllCorrsP{mouseI}{1}{dpI}(cellBothDays{mouseI}{dpI})];
        end
        
    end
end     