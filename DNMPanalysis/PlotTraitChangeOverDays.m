function [figHand,statsOut] = PlotTraitChangeOverDays(pooledTraitChanges,pooledDaysApart,comparisons,colorsUse,labels,figHand,plotDots,lineType,ylims,yLabel)

if isnumeric(comparisons)
    numComps = size(comparisons,1);
    comparisons = mat2cell(comparisons,ones(numComps,1),size(comparisons,2));
elseif iscell(comparisons)
    numComps = length(comparisons);
end

if length(colorsUse)~=length(pooledTraitChanges)
    disp('Error: not equal number of traits and colors, will fail')
    keyboard
end

for compI = 1:numComps
    subplot(1,numComps,compI)
    [statsOutTemp] = PlotTraitChangeOverDaysOne(pooledTraitChanges(comparisons{compI}),pooledDaysApart,...
        colorsUse(comparisons{compI}),labels(comparisons{compI}),plotDots,lineType,yLabel,ylims);
    
    
    statsOut.slopeDiffComp{compI} = statsOutTemp.slopeDiffComp;
    statsOut.signtests{compI} = statsOutTemp.signtests;
    statsOut.rankSumAll{compI} = statsOutTemp.rankSumAll;
    statsOut.comps{compI} = statsOutTemp.comps;
end

% Slopes of each of these lines
for tgI = 1:length(pooledTraitChanges)
    [~, ~, ~, statsOut.slopeRR(tgI), statsOut.slopePval(tgI), ~] =...
        fitLinRegSL(pooledTraitChanges{tgI}, pooledDaysApart);
    
    [statsOut.slopeDiffZero(tgI).Fval,statsOut.slopeDiffZero(tgI).dfNum,...
     statsOut.slopeDiffZero(tgI).dfDen,statsOut.slopeDiffZero(tgI).pVal] =...
        slopeDiffFromZeroFtest(pooledTraitChanges{tgI}, pooledDaysApart);
end

end