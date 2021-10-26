ppa = cellTBTall{mouseI}(1).isCorrect(cellTBTall{mouseI}(1).sessID == 4)
ppb = cellTBTall{mouseI}(3).isCorrect(cellTBTall{mouseI}(3).sessID == 4)

for mouseI = 1:numMice
    for sessI = 1:9
        ppa = cellTBTall{mouseI}(1).isCorrect(cellTBTall{mouseI}(1).sessID == sessI);
        ppb = cellTBTall{mouseI}(3).isCorrect(cellTBTall{mouseI}(3).sessID == sessI);
        
        perfBlocks{mouseI}(1,sessI) = sum(ppa)/numel(ppa);
        perfBlocks{mouseI}(2,sessI) = sum(ppb)/numel(ppb);
    end
    
    [~,blockMax{1}(mouseI,1)] = max(perfBlocks{mouseI}(1,[1:3]));
    [~,blockMax{1}(mouseI,2)] = max(perfBlocks{mouseI}(1,[4:6]));
    [~,blockMax{1}(mouseI,3)] = max(perfBlocks{mouseI}(1,[7:9]));
    %[~,blockMax{1}(mouseI,3)] = max(perfBlocks{mouseI}(1,1));
    [~,blockMax{2}(mouseI,1)] = max(perfBlocks{mouseI}(2,[1:3]));
    [~,blockMax{2}(mouseI,2)] = max(perfBlocks{mouseI}(2,[4:6]));
    [~,blockMax{2}(mouseI,3)] = max(perfBlocks{mouseI}(2,[7:9]));
    %[~,blockMax{2}(mouseI,3)] = max(perfBlocks{mouseI}(2,1));
end

lapsNumsHere = [];
perfHere = [];
perfP = [];
tmapRho = [];
dc = [1 2 3];
changeDays = [1 2];
for dpI = 1:2
    
for mouseI = 1:numMice
    refDay = dc(blockMax{1}(mouseI,dpI))+3*(dpI-1);
    changeDay = dc(blockMax{1}(mouseI,dpI+1))+3*(dpI);
for condI = 1:numel(condsUse)
    condJ = condsUse(condI);
    
    
    % Cells use...?
    % Registered both days, above thresh one
    haveCellBothDays = sum(cellSSI{mouseI}(:,[refDay changeDay]) > 0,2) == 2;
    aboveThreshOne = sum(dayUseAll{mouseI}(:,[refDay changeDay]) > 0,2) > 0;
    cellsUse = haveCellBothDays & aboveThreshOne;
    
    % Bins this arm
    binsH = lgDataBins.labels == armLabels{condJ};
    binsUse{1} = lgDataBins.X(binsH,:);
    binsUse{2} = lgDataBins.Y(binsH,:);
    
    % Reference sess trials
    %refTrials = find(cellTBT{mouseI}(condJ).sessID == refDay,10,'last'); 
    refTrials = find(cellTBT{mouseI}(condJ).sessID == refDay); 
    
    if any(refTrials)
    
    tbtSmallRef = StripTBTbyTrials(cellTBT{mouseI},condJ,refTrials);
    [refTmap,~] = RateMapsDoublePlusV2(tbtSmallRef, binsUse, 'vertices', [1], 0, 'zeroOut', [], false);
    refTmap = refTmap(:,refDay)';
    refTmap = cell2mat(refTmap)';
   
    % Trials during learning day
    changeTrialsAll = find(cellTBTall{mouseI}(condJ).sessID == changeDay);
    emptyTrials = cellfun(@isempty,cellTBTall{mouseI}(condJ).trialsX(changeTrialsAll));
    changeTrialsAll(emptyTrials) = [];
    
    nStartInds = numel(changeTrialsAll)-nWindowTrials+1;
    
    tmapRho{dpI,condI}{mouseI} = nan(numel(nStartInds),nArmBins);
    perfP{dpI,condI}{mouseI} = nan(numel(nStartInds),nArmBins);
    perfHere{dpI,condI}{mouseI} = nan(numel(nStartInds),1);
    if any(changeTrialsAll) && any(cellsUse)
        
        wStartInds = 1:1:(numel(changeTrialsAll)-nWindowTrials+1);
        %wStarts = changeTrialsAll(wStartInds);
        
        
    for wwI = 1:numel(wStartInds)
        changeTrialsUse = changeTrialsAll([wStartInds(wwI)+[0:1:(nWindowTrials-1)]]);
        
        tbtSmallChange = StripTBTbyTrials(cellTBTall{mouseI},condJ,changeTrialsUse);
        [changeTmap,~] = RateMapsDoublePlusV2(tbtSmallChange, binsUse, 'vertices', [1], 0, 'zeroOut', [], false);
        changeTmap = changeTmap(:,changeDay)';
        changeTmap = cell2mat(changeTmap)';
        
        % PV corrs
        for binI = 1:nArmBins
            [tmapRho{dpI,condI}{mouseI}(wwI,binI),perfP{dpI,condI}{mouseI}(wwI,binI)] =...
                corr(refTmap(cellsUse,binI),changeTmap(cellsUse,binI),'type','Spearman');
        end
        
        perfHere{dpI,condI}{mouseI}(wwI,1) = sum(tbtSmallChange(1).isCorrect) / numel(changeTrialsUse);
        
        lapsNumsHere{dpI,condI}{mouseI}(wwI,1) = mean(cellTBTall{mouseI}(condJ).lapNumber(changeTrialsUse));
        lapsHere{dpI,condI}{mouseI}(wwI,1) = mean(changeTrialsUse);
    end
        
    end %any changeTrials
    end %any refTrials
end
end
end