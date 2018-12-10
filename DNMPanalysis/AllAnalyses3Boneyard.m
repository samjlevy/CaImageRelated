% All Analyses 3 boneyard

for mouseI = 1:numMice
    [xMax(mouseI,:), xMin(mouseI,:)] = GetTBTlims(cellTBT{mouseI});
end

saveName = fullfile(mainFolder,mice{mouseI},'PFsLin.mat');
switch exist(fullfile(mainFolder,mice{mouseI},'PFsLin.mat'),'file')
    case 0
        disp(['no placefields found for ' mice{mouseI} ', making now'])
        [~, ~, ~, ~, ~, ~] =...
            PFsLinTrialbyTrial2(cellTBT{mouseI}, xlims, cmperbin, minspeed,...
            saveName,'trialReli',trialReli{mouseI},'smooth',false);
    case 2
        disp(['found placefields for ' mice{mouseI} ', all good'])
end
%pooled placefields
 [~, ~, ~, ~, ~, ~] =...
            PFsLinTrialbyTrial2(cellTBT{mouseI}, xlims, cmperbin, minspeed,...
                saveName,'trialReli',trialReli{mouseI},'smooth',false,'condPairs',[1 3; 2 4; 1 2; 3 4]);  

            
%{
pooledPVdayPairs = cell(length(pooledCompPairs),1);
pooledPVcorrs = cell(length(pooledCompPairs),1);
pooledMeanPVcorrs = cell(length(pooledCompPairs),1);
pooledMeanPVcorrsHalfFirst = cell(length(pooledCompPairs),1);
pooledMeanPVcorrsHalfSecond = cell(length(pooledCompPairs),1);
for mouseI = 1:numMice
    %Pool across mice 
    for cpI = 1:length(pooledCompPairs)
        pooledPVdayPairs{cpI} = [pooledPVdayPairs{cpI}; PVdayPairs{mouseI}];
        pooledPVcorrs{cpI} = [pooledPVcorrs{cpI}; pvCorrs{mouseI}(:,cpI)];
        pooledMeanPVcorrs{cpI} = [pooledMeanPVcorrs{cpI}; meanCorr{mouseI}(:,cpI)];
        pooledMeanPVcorrsHalfFirst{cpI} = [pooledMeanPVcorrsHalfFirst{cpI}; meanCorrHalfFirst{mouseI}(:,cpI)];
        pooledMeanPVcorrsHalfSecond{cpI} = [pooledMeanPVcorrsHalfSecond{cpI}; meanCorrHalfSecond{mouseI}(:,cpI)];
    end
end
pooledPVcorrs = cellfun(@cell2mat,pooledPVcorrs,'UniformOutput',false);
%}
                

%Old DI score stuff

    %{
    DImeansLRsplitters = DImeansLR; DImeansLRsplitters(LRthisCellSplits{mouseI}==0) = NaN; %LR only?
    DImeansSTsplitters = DImeansST; DImeansSTsplitters(STthisCellSplits{mouseI}==0) = NaN; %ST only?
    DImeansLRboth = DImeanLR{mouseI}; DImeansLRboth(splittersBOTH{mouseI}==0) = NaN; %DIs of both Splitters
    DImeansSTboth = DImeanST{mouseI}; DImeansSTboth(splittersBOTH{mouseI}==0) = NaN;
    %DImeansNOTLRsplitters = DImeansLR; DImeansNOTLRsplitters(LRthisCellSplits{mouseI}==1) = NaN; %LR only?
    %DImeansNOTSTsplitters = DImeansST; DImeansNOTSTsplitters(STthisCellSplits{mouseI}==1) = NaN; %ST only?
    DImeansNOTLRsplitters = DImeansLR; DImeansNOTLRsplitters(nonLRsplitters{mouseI}==0) = NaN; %LR only? Should be same as above?
    DImeansNOTSTsplitters = DImeansST; DImeansNOTSTsplitters(nonSTsplitters{mouseI}==0) = NaN; %ST only? Should be same as above?
    %}
    %{
    for dayI = 1:size(DImeanLR{mouseI},2)
        %dayDistLR(mouseI,dayI) = histcounts(DImeanLR{mouseI}(:,dayI),binEdges);
        %dayDistST(mouseI,dayI) = histcounts(DImeanST{mouseI}(:,dayI),binEdges);
        
        %All LR splitters
        dayDistLR{mouseI}(dayI,:) = histcounts(DImeansLR(:,dayI),binEdges); %Active only; why day use again?
        dayDistST{mouseI}(dayI,:) = histcounts(DImeansST(:,dayI),binEdges); %Active only
        pctDayDistLR{mouseI}(dayI,:) =  dayDistLR{mouseI}(dayI,:) / sum(dayDistLR{mouseI}(dayI,:)); %by percentage
        pctDayDistST{mouseI}(dayI,:) =  dayDistST{mouseI}(dayI,:) / sum(dayDistST{mouseI}(dayI,:));
        pctEdgeLR{mouseI}(dayI) = sum(pctDayDistLR{mouseI}(dayI,[1 end]));
        pctEdgeST{mouseI}(dayI) = sum(pctDayDistST{mouseI}(dayI,[1 end]));
        
        dayDistLRsplitters{mouseI}(dayI,:) = histcounts(DImeansLRsplitters(:,dayI),binEdges); %Active only
        dayDistSTsplitters{mouseI}(dayI,:) = histcounts(DImeansSTsplitters(:,dayI),binEdges); %Active only
        pctDayDistLRsplitters{mouseI}(dayI,:) =  dayDistLRsplitters{mouseI}(dayI,:) / sum(dayDistLRsplitters{mouseI}(dayI,:));
        pctDayDistSTsplitters{mouseI}(dayI,:) =  dayDistSTsplitters{mouseI}(dayI,:) / sum(dayDistSTsplitters{mouseI}(dayI,:));
        pctEdgeLRsplitters{mouseI}(dayI) = sum(pctDayDistLRsplitters{mouseI}(dayI,[1 end]));
        pctEdgeSTsplitters{mouseI}(dayI) = sum(pctDayDistSTsplitters{mouseI}(dayI,[1 end]));
        
        dayDistLRboth{mouseI}(dayI,:) = histcounts(DImeansLRboth(:,dayI),binEdges); %Active only
        dayDistSTboth{mouseI}(dayI,:) = histcounts(DImeansSTboth(:,dayI),binEdges); %Active only
        pctDayDistLRboth{mouseI}(dayI,:) =  dayDistLRboth{mouseI}(dayI,:) / sum(dayDistLRboth{mouseI}(dayI,:));
        pctDayDistSTboth{mouseI}(dayI,:) =  dayDistSTboth{mouseI}(dayI,:) / sum(dayDistSTboth{mouseI}(dayI,:));
        pctEdgeLRboth{mouseI}(dayI) = sum(pctDayDistLRboth{mouseI}(dayI,[1 end]));
        pctEdgeSTboth{mouseI}(dayI) = sum(pctDayDistSTboth{mouseI}(dayI,[1 end]));
        
        dayDistNOTLRsplitters{mouseI}(dayI,:) = histcounts(DImeansNOTLRsplitters(:,dayI),binEdges); %Active only
        dayDistNOTSTsplitters{mouseI}(dayI,:) = histcounts(DImeansNOTSTsplitters(:,dayI),binEdges); %Active only
        pctDayDistNOTLRsplitters{mouseI}(dayI,:) =  dayDistNOTLRsplitters{mouseI}(dayI,:) / sum(dayDistNOTLRsplitters{mouseI}(dayI,:));
        pctDayDistNOTSTsplitters{mouseI}(dayI,:) =  dayDistNOTSTsplitters{mouseI}(dayI,:) / sum(dayDistNOTSTsplitters{mouseI}(dayI,:));
        pctEdgeNOTLRsplitters{mouseI}(dayI) = sum(pctDayDistNOTLRsplitters{mouseI}(dayI,[1 end]));
        pctEdgeNOTSTsplitters{mouseI}(dayI) = sum(pctDayDistNOTSTsplitters{mouseI}(dayI,[1 end]));
        
        %Could look across dimension: LR DIs of ST splitters
        %{
        mouseI = 0;
        mouseI = mouseI + 1
        pctEdgeLR{mouseI}
        pctEdgeLRsplitters{mouseI}
        pctEdgeNOTLRsplitters{mouseI}

        mouseI = 0;
        mouseI = mouseI + 1
        pctEdgeST{mouseI}
        pctEdgeSTsplitters{mouseI}
        pctEdgeNOTSTsplitters{mouseI}
        %}
    end
    %}  
    %{
    for binI = 1:length(binEdges)-1
        ddLR = dayDistLR{mouseI}(:,binI);
        dayDistMeansLR(mouseI,binI) = mean(ddLR(ddLR~=0));
        dayDistSEMsLR(mouseI,binI) = standarderrorSL(ddLR(ddLR~=0));
        ddST = dayDistST{mouseI}(:,binI);
        dayDistMeansST(mouseI,binI) = mean(ddST(ddST~=0));
        dayDistSEMsST(mouseI,binI) = standarderrorSL(ddST(ddST~=0));
        
        ddLRs = dayDistLRsplitters{mouseI}(:,binI);
        dayDistMeansLRsplitters(mouseI,binI) = mean(ddLRs(ddLRs~=0));
        dayDistSEMsLRsplitters(mouseI,binI) = standarderrorSL(ddLRs(ddLRs~=0));
        ddSTs = dayDistSTsplitters{mouseI}(:,binI);
        dayDistMeansSTsplitters(mouseI,binI) = mean(ddSTs(ddSTs~=0));
        dayDistSEMsSTsplitters(mouseI,binI) = standarderrorSL(ddSTs(ddSTs~=0));
        
        ddLRboth = dayDistLRboth{mouseI}(:,binI);
        dayDistMeansLRboth(mouseI,binI) = mean(ddLRboth(ddLRboth~=0));
        dayDistSEMsLRboth(mouseI,binI) = standarderrorSL(ddLRboth(ddLRboth~=0));
        ddSTboth = dayDistSTboth{mouseI}(:,binI);
        dayDistMeansSTboth(mouseI,binI) = mean(ddSTboth(ddSTboth~=0));
        dayDistSEMsSTboth(mouseI,binI) = standarderrorSL(ddSTboth(ddSTboth~=0));
        
        ppLR = pctDayDistLR{mouseI}(:,binI);
        pctsDistMeanLR(mouseI,binI) = mean(ppLR(ppLR~=0));
        pctsDistSEMsLR(mouseI,binI) = standarderrorSL(ppLR(ppLR~=0));
        ppST = pctDayDistST{mouseI}(:,binI);
        pctsDistMeanST(mouseI,binI) = mean(ppST(ppST~=0));
        pctsDistSEMsST(mouseI,binI) = standarderrorSL(ppST(ppST~=0));
    end
    %}
%end
%{

%Trait logical prop change Place by splitter
% Coming or going?
for mouseI = 1:numMice
     numPctPXSLR{mouseI}(1,:) = sum(placeSplitLR{mouseI},1);
    numPctPXSLR{mouseI}(2,:) = numPctPXSLR{mouseI}(1,:)./cellsActiveToday{mouseI};
    rangePctPXSLR(mouseI,1:2) = [mean(numPctPXSLR{mouseI}(2,:)) standarderrorSL(numPctPXSLR{mouseI}(2,:))];
    
    numPctPXSST{mouseI}(1,:) = sum(placeSplitST{mouseI},1);
    numPctPXSST{mouseI}(2,:) = numPctPXSST{mouseI}(1,:)./cellsActiveToday{mouseI};
    rangePctPXSST(mouseI,1:2) = [mean(numPctPXSST{mouseI}(2,:)) standarderrorSL(numPctPXSST{mouseI}(2,:))];
    
    numPctPXSBOTH{mouseI}(1,:) = sum(placeSplitBOTH{mouseI},1);
    numPctPXSBOTH{mouseI}(2,:) = numPctPXSBOTH{mouseI}(1,:)./cellsActiveToday{mouseI};
    rangePctPXSBOTH(mouseI,1:2) = [mean(numPctPXSBOTH{mouseI}(2,:)) standarderrorSL(numPctPXSBOTH{mouseI}(2,:))];
    
    numPctPXSLRonly{mouseI}(1,:) = sum(placeSplitLRonly{mouseI},1);
    numPctPXSLRonly{mouseI}(2,:) = numPctPXSLRonly{mouseI}(1,:)./cellsActiveToday{mouseI};
    rangePctPXSLRonly(mouseI,1:2) = [mean(numPctPXSLRonly{mouseI}(2,:)) standarderrorSL(numPctPXSLRonly{mouseI}(2,:))];
    
    numPctPXSSTonly{mouseI}(1,:) = sum(placeSplitSTonly{mouseI},1);
    numPctPXSSTonly{mouseI}(2,:) = numPctPXSSTonly{mouseI}(1,:)./cellsActiveToday{mouseI};
    rangePctPXSSTonly(mouseI,1:2) = [mean(numPctPXSSTonly{mouseI}(2,:)) standarderrorSL(numPctPXSSTonly{mouseI}(2,:))];
    
    numPctPXSNone{mouseI}(1,:) = sum(placeSplitNone{mouseI},1);
    numPctPXSNone{mouseI}(2,:) = numPctPXSNone{mouseI}(1,:)./cellsActiveToday{mouseI};
    rangePctPXSNone(mouseI,1:2) = [mean(numPctPXSNone{mouseI}(2,:)) standarderrorSL(numPctPXSNone{mouseI}(2,:))];
    
    [pxsLRCOM{mouseI}, pxsDayBiasLR{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, placeSplitLR{mouseI});
    [pxsSTCOM{mouseI}, pxsDayBiasST{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, placeSplitST{mouseI});
    [pxsBOTHCOM{mouseI}, pxsDayBiasBOTH{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, placeSplitBOTH{mouseI});
    [pxsLRonlyCOM{mouseI}, pxsDayBiasLRonly{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, placeSplitLRonly{mouseI});
    [pxsSTonlyCOM{mouseI}, pxsDayBiasSTonly{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, placeSplitSTonly{mouseI});
    [pxsNoneCOM{mouseI}, pxsDayBiasNone{mouseI}] = LogicalTraitCenterofMass(dayUse{mouseI}, placeSplitNone{mouseI});
    disp(['done place by splitter mouse ' num2str(mouseI)])
end
for mouseI = 1:numMice
    [PSnumChange{mouseI}, PSpctChange{mouseI}, dayPairs{mouseI}] = NNplusKChange(placeAndSplitter{mouseI}, dayUse{mouseI});
    [PSxnumChange{mouseI}, PSxpctChange{mouseI}, dayPairs{mouseI}] = NNplusKChange(placeNotSplitter{mouseI}, dayUse{mouseI});
    [PxSnumChange{mouseI}, PxSpctChange{mouseI}, dayPairs{mouseI}] = NNplusKChange(splitterNotPlace{mouseI}, dayUse{mouseI});
    
    %Sort by days apart
    dayDiffs{mouseI} = diff(dayPairs{mouseI},1,2);
    possibleDiffs = unique(dayDiffs{mouseI});
    for pdI = 1:length(possibleDiffs)
        PSnumChangeReorg{mouseI}{pdI} = PSnumChange{mouseI}(dayDiffs{mouseI}==possibleDiffs(pdI));
        PSpctChangeReorg{mouseI}{pdI} = PSpctChange{mouseI}(dayDiffs{mouseI}==possibleDiffs(pdI));
        PSxnumChangeReorg{mouseI}{pdI} = PSxnumChange{mouseI}(dayDiffs{mouseI}==possibleDiffs(pdI));
        PSxpctChangeReorg{mouseI}{pdI} = PSxpctChange{mouseI}(dayDiffs{mouseI}==possibleDiffs(pdI)); 
        PxSnumChangeReorg{mouseI}{pdI} = PxSnumChange{mouseI}(dayDiffs{mouseI}==possibleDiffs(pdI));
        PxSpctChangeReorg{mouseI}{pdI} = PxSpctChange{mouseI}(dayDiffs{mouseI}==possibleDiffs(pdI));
    end
    meanPSpctChange{mouseI} = cell2mat(cellfun(@mean,PSpctChangeReorg{mouseI},'UniformOutput',false));
    meanPSxpctChange{mouseI} = cell2mat(cellfun(@mean,PSxpctChangeReorg{mouseI},'UniformOutput',false));
    meanPxSpctChange{mouseI} = cell2mat(cellfun(@mean,PxSpctChangeReorg{mouseI},'UniformOutput',false));
end
%}

%{
    numDailySplittersANY{mouseI} = sum(splittersANY{mouseI},1);
    daysSplitANY{mouseI} = sum(splittersANY{mouseI},2);
    rangeDailySplittersANY(mouseI,:) = [mean(numDailySplittersANY{mouseI}) standarderrorSL(numDailySplittersANY{mouseI})];
    pctDailySplittersANY{mouseI} = numDailySplittersANY{mouseI}./cellsActiveToday{mouseI};
    rangePctDailySplittersANY(mouseI,:) = [mean(pctDailySplittersANY{mouseI}) standarderrorSL(pctDailySplittersANY{mouseI})];%Pct
    splitAllDaysANY{mouseI} = splitterDayBiasANY{mouseI}/sum(sum(dayUse{mouseI},2) > 1); %ever splitLR/cells active at least 2 days
    
    numDailySplittersLR{mouseI} = sum(splittersLR{mouseI},1);
    daysSplitLR{mouseI} = sum(splittersLR{mouseI},2);
    rangeDailySplittersLR(mouseI,:) = [mean(numDailySplittersLR{mouseI}) standarderrorSL(numDailySplittersLR{mouseI})];
    pctDailySplittersLR{mouseI} = numDailySplittersLR{mouseI}./cellsActiveToday{mouseI};
    rangePctDailySplittersLR(mouseI,:) = [mean(pctDailySplittersLR{mouseI}) standarderrorSL(pctDailySplittersLR{mouseI})];%Pct
    splitAllDaysLR{mouseI} = splitterDayBiasLR{mouseI}/sum(sum(dayUse{mouseI},2) > 1); %ever splitLR/cells active at least 2 days
    
    numDailySplittersST{mouseI} = sum(splittersST{mouseI},1);
    daysSplitST{mouseI} = sum(splittersST{mouseI},2);
    rangeDailySplittersST(mouseI,:) = [mean(numDailySplittersST{mouseI}) standarderrorSL(numDailySplittersST{mouseI})];
    pctDailySplittersST{mouseI} = numDailySplittersST{mouseI}./cellsActiveToday{mouseI};
    rangePctDailySplittersST(mouseI,:) = [mean(pctDailySplittersST{mouseI}) standarderrorSL(pctDailySplittersST{mouseI})];%Pct
    splitAllDaysST{mouseI} = splitterDayBiasST{mouseI}/sum(sum(dayUse{mouseI},2) > 1); %ever splitST/cells active at least 2 days
    
    numDailySplittersBOTH{mouseI} = sum(splittersBOTH{mouseI},1);
    daysSplitBOTH{mouseI} = sum(splittersBOTH{mouseI},2);
    rangeDailySplittersBOTH(mouseI,:) = [mean(numDailySplittersBOTH{mouseI}) standarderrorSL(numDailySplittersBOTH{mouseI})];
    pctDailySplittersBOTH{mouseI} = numDailySplittersBOTH{mouseI}./cellsActiveToday{mouseI};
    rangePctDailySplittersBOTH(mouseI,:) = [mean(pctDailySplittersBOTH{mouseI}) standarderrorSL(pctDailySplittersBOTH{mouseI})];%Pct
    splitAllDaysBOTH{mouseI} = splitterDayBiasBOTH{mouseI}/sum(sum(dayUse{mouseI},2) > 1); %ever splitBOTH/cells active at least 2 days
    
    numDailySplittersLRonly{mouseI} = sum(splittersLRonly{mouseI},1);
    daysSplitLRonly{mouseI} = sum(splittersLRonly{mouseI},2);
    rangeDailySplittersLRonly(mouseI,:) = [mean(numDailySplittersLRonly{mouseI}) standarderrorSL(numDailySplittersLRonly{mouseI})];
    pctDailySplittersLRonly{mouseI} = numDailySplittersLRonly{mouseI}./cellsActiveToday{mouseI};
    rangePctDailySplittersLRonly(mouseI,:) = [mean(pctDailySplittersLRonly{mouseI}) standarderrorSL(pctDailySplittersLRonly{mouseI})];%Pct
    splitAllDaysLRonly{mouseI} = splitterDayBiasLRonly{mouseI}/sum(sum(dayUse{mouseI},2) > 1); %ever splitBOTH/cells active at least 2 days

    numDailySplittersSTonly{mouseI} = sum(splittersSTonly{mouseI},1);
    daysSplitSTonly{mouseI} = sum(splittersSTonly{mouseI},2);
    rangeDailySplittersSTonly(mouseI,:) = [mean(numDailySplittersSTonly{mouseI}) standarderrorSL(numDailySplittersSTonly{mouseI})];%Raw number
    pctDailySplittersSTonly{mouseI} = numDailySplittersSTonly{mouseI}./cellsActiveToday{mouseI};
    rangePctDailySplittersSTonly(mouseI,:) = [mean(pctDailySplittersSTonly{mouseI}) standarderrorSL(pctDailySplittersSTonly{mouseI})]; %Pct
    splitAllDaysSTonly{mouseI} = splitterDayBiasSTonly{mouseI}/sum(sum(dayUse{mouseI},2) > 1); %ever splitBOTH/cells active at least 2 days
    
    numDailySplittersEXany{mouseI} = sum(splittersEXany{mouseI},1);
    daysSplitEXany{mouseI} = sum(splittersEXany{mouseI},2);
    rangeDailySplittersEXany(mouseI,:) = [mean(numDailySplittersEXany{mouseI}) standarderrorSL(numDailySplittersEXany{mouseI})];%Raw number
    pctDailySplittersEXany{mouseI} = numDailySplittersEXany{mouseI}./cellsActiveToday{mouseI};
    rangePctDailySplittersEXany(mouseI,:) = [mean(pctDailySplittersEXany{mouseI}) standarderrorSL(pctDailySplittersEXany{mouseI})]; %Pct
    splitAllDaysEXany{mouseI} = splitterDayBiasEXany{mouseI}/sum(sum(dayUse{mouseI},2) > 1); 

    numDailySplittersNone{mouseI} = sum(splittersNone{mouseI},1);
    daysSplitNone{mouseI} = sum(splittersNone{mouseI},2);
    rangeDailySplittersNone(mouseI,:) = [mean(numDailySplittersNone{mouseI}) standarderrorSL(numDailySplittersNone{mouseI})];%Raw number
    pctDailySplittersNone{mouseI} = numDailySplittersNone{mouseI}./cellsActiveToday{mouseI};
    rangePctDailySplittersNone(mouseI,:) = [mean(pctDailySplittersNone{mouseI}) standarderrorSL(pctDailySplittersNone{mouseI})]; 
    splitAllDaysNone{mouseI} = splitterDayBiasNone{mouseI}/sum(sum(dayUse{mouseI},2) > 1); 
    %}


cscCell = mat2cell(condSetComps,ones(size(condSetComps,1),1),size(condSetComps,2));
sameDayDayDiffsPooled = cell(length(pvNames),1);
for pvtI = 1:length(pvNames)
    withinCSdayChangeMean{pvtI} = cell(length(condSet),1);
    withinCSdayChangeMeanHalfFirst{pvtI} = cell(length(condSet),1);
    withinCSdayChangeMeanHalfSecond{pvtI} = cell(length(condSet),1);
    cscDiffsChangeMeanPooled{pvtI} = cell(size(condSetComps,1),1);
    cscDiffsChangeMeanHalfFirstPooled{pvtI} = cell(size(condSetComps,1),1);
    cscDiffsChangeMeanHalfSecondPooled{pvtI} = cell(size(condSetComps,1),1);
    for mouseI = 1:numMice
        %Get only within day PVcorrs
        sameDayPairs{pvtI}{mouseI} = find(PVdayPairs{pvtI}{mouseI}(:,1)==PVdayPairs{pvtI}{mouseI}(:,2)); %These are in real days
        %sameDayDayDiffs{pvtI}{mouseI} = realDayDiffs{mouseI}(sameDayPairs{pvtI}{mouseI});
        sameDayDayDiffsPooled{pvtI} = [sameDayDayDiffsPooled{pvtI}; realDayDiffs{mouseI}];
        
        %sameDaypvCorrs{pvtI}{mouseI} = tpvCorrs; need this? how to do it right?
        sameDaymeanCorr{pvtI}{mouseI} = meanCorr{pvtI}{mouseI}(sameDayPairs{pvtI}{mouseI},:);
        sameDaymeanCorrHalfFirst{pvtI}{mouseI} = meanCorrHalfFirst{pvtI}{mouseI}(sameDayPairs{pvtI}{mouseI},:);
        sameDaymeanCorrHalfSecond{pvtI}{mouseI} = meanCorrHalfSecond{pvtI}{mouseI}(sameDayPairs{pvtI}{mouseI},:);
        
        CSpooledSameDaymeanCorr{pvtI}{mouseI} = PoolDouble(sameDaymeanCorr{pvtI}{mouseI},condSet);
        CSpooledSameDaymeanCorrHalfFirst{pvtI}{mouseI} = PoolDouble(sameDaymeanCorrHalfFirst{pvtI}{mouseI},condSet);
        CSpooledSameDaymeanCorrHalfSecond{pvtI}{mouseI} = PoolDouble(sameDaymeanCorrHalfSecond{pvtI}{mouseI},condSet);
        
        %Change of within condset over time
        [csPooledChangeMean{pvtI}{mouseI},~] = cellfun(@(x) TraitChangeDayPairs(x,dayPairs{mouseI}),CSpooledSameDaymeanCorr{pvtI}{mouseI},'UniformOutput',false);
        [csPooledChangeMeanHalfFirst{pvtI}{mouseI},~] = cellfun(@(x) TraitChangeDayPairs(x,dayPairs{mouseI}),CSpooledSameDaymeanCorrHalfFirst{pvtI}{mouseI},'UniformOutput',false);
        [csPooledChangeMeanHalfSecond{pvtI}{mouseI},~] = cellfun(@(x) TraitChangeDayPairs(x,dayPairs{mouseI}),CSpooledSameDaymeanCorrHalfSecond{pvtI}{mouseI},'UniformOutput',false);
        
        %pool across mice
        for csI = 1:length(condSet)
            withinCSdayChangeMean{pvtI}{csI} = [withinCSdayChangeMean{pvtI}{csI}; csPooledChangeMean{pvtI}{mouseI}{csI}];
            withinCSdayChangeMeanHalfFirst{pvtI}{csI} = [withinCSdayChangeMeanHalfFirst{pvtI}{csI}; csPooledChangeMeanHalfFirst{pvtI}{mouseI}{csI}];
            withinCSdayChangeMeanHalfSecond{pvtI}{csI} = [withinCSdayChangeMeanHalfSecond{pvtI}{csI}; csPooledChangeMeanHalfSecond{pvtI}{mouseI}{csI}];
        end
            
        %Separation between condsets
        cscDiffsMean{pvtI}{mouseI} = cellfun(@(x) CSpooledSameDaymeanCorr{pvtI}{mouseI}{x(1)} - CSpooledSameDaymeanCorr{pvtI}{mouseI}{x(2)},cscCell,'UniformOutput',false);
        cscDiffsMeanHalfFirst{pvtI}{mouseI} = cellfun(@(x) CSpooledSameDaymeanCorrHalfFirst{pvtI}{mouseI}{x(1)} - CSpooledSameDaymeanCorrHalfFirst{pvtI}{mouseI}{x(2)},cscCell,'UniformOutput',false);
        cscDiffsMeanHalfSecond{pvtI}{mouseI} = cellfun(@(x) CSpooledSameDaymeanCorrHalfSecond{pvtI}{mouseI}{x(1)} - CSpooledSameDaymeanCorrHalfSecond{pvtI}{mouseI}{x(2)},cscCell,'UniformOutput',false);
        
        %Change of separation over time
        [cscDiffsChangeMean{pvtI}{mouseI},~] = cellfun(@(x) TraitChangeDayPairs(x,dayPairs{mouseI}),cscDiffsMean{pvtI}{mouseI},'UniformOutput',false);
        [cscDiffsChangeMeanHalfFirst{pvtI}{mouseI},~] = cellfun(@(x) TraitChangeDayPairs(x,dayPairs{mouseI}),cscDiffsMeanHalfFirst{pvtI}{mouseI},'UniformOutput',false);
        [cscDiffsChangeMeanHalfSecond{pvtI}{mouseI},~] = cellfun(@(x) TraitChangeDayPairs(x,dayPairs{mouseI}),cscDiffsMeanHalfSecond{pvtI}{mouseI},'UniformOutput',false);
        
        %pool across mice
        for cscI = 1:size(condSetComps,1)
            cscDiffsChangeMeanPooled{pvtI}{cscI} = [cscDiffsChangeMeanPooled{pvtI}{cscI}; cscDiffsChangeMean{pvtI}{mouseI}{cscI}];
            cscDiffsChangeMeanHalfFirstPooled{pvtI}{cscI} = [cscDiffsChangeMeanPooled{pvtI}{cscI}; cscDiffsChangeMeanHalfFirst{pvtI}{mouseI}{cscI}];
            cscDiffsChangeMeanHalfSecondPooled{pvtI}{cscI} = [cscDiffsChangeMeanPooled{pvtI}{cscI}; cscDiffsChangeMeanHalfSecond{pvtI}{mouseI}{cscI}];
        end
    end
    
end
                