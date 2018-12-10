function [withinCSdayChange,cscDiffsChangePooled, sameDayCompsPooled] = CorrChangeOverDays(meanCorrs,dayPairsID,dayPairsTest,condSet,condSetComps)

numMice = length(meanCorrs);

cscCell = mat2cell(condSetComps,ones(size(condSetComps,1),1),size(condSetComps,2));
sameDayDayDiffsPooled = [];

withinCSdayChange = cell(length(condSet),1);
cscDiffsChangePooled = cell(size(condSetComps,1),1);
sameDayCompsPooled = [];
for mouseI = 1:numMice
    %Get only within day PVcorrs
    sameDayComps{mouseI} = dayPairsID{mouseI}(:,1)==dayPairsID{mouseI}(:,2); %These are in real days
    sameDayCompsPooled = [sameDayCompsPooled; sameDayComps{mouseI}];
    %sameDayComps{mouseI} = find(realDayDiffs{mouseI}==0);
    %sameDayDayDiffsPooled = [sameDayDayDiffsPooled; realDayDiffs{mouseI}];
    
    sameDayMeanCorrs{mouseI} = meanCorrs{mouseI}(sameDayComps{mouseI},:);
    
    CSpooledSameDayMeanCorrs{mouseI} = PoolDouble(sameDayMeanCorrs{mouseI},condSet);
    
    %Change of within condset over time
    [csPooledChangeMean{mouseI},~] = cellfun(@(x) TraitChangeDayPairs(x,dayPairsTest{mouseI}),CSpooledSameDayMeanCorrs{mouseI},'UniformOutput',false);
    
    %pool across mice
    for csI = 1:length(condSet)
        withinCSdayChange{csI} = [withinCSdayChange{csI}; csPooledChangeMean{mouseI}{csI}];
    end
    
    %Separation between condsets
    cscDiffsMean{mouseI} = cellfun(@(x) CSpooledSameDayMeanCorrs{mouseI}{x(1)} - CSpooledSameDayMeanCorrs{mouseI}{x(2)},cscCell,'UniformOutput',false);
    
    %Change of separation over time
    [cscDiffsChangeMean{mouseI},~] = cellfun(@(x) TraitChangeDayPairs(x,dayPairsTest{mouseI}),cscDiffsMean{mouseI},'UniformOutput',false);
    
    %pool across mice
    for cscI = 1:size(condSetComps,1)
        cscDiffsChangePooled{cscI} = [cscDiffsChangePooled{cscI}; cscDiffsChangeMean{mouseI}{cscI}];
    end
end
    
end