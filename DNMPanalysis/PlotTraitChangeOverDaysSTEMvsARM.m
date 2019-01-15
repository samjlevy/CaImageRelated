function [figHand,statsOut] = PlotTraitChangeOverDaysSTEMvsARM(pooledTraitChangesSTEM,pooledDaysApartSTEM,pooledTraitChangesARM,...
    pooledDaysApartARM,colorsUse,labels,figHand,ylims,yLabel)

numTgs = length(pooledTraitChangesSTEM);
subRows = ceil(numTgs/3);

for tgI = 1:numTgs
    subplot(subRows,3,tgI)
    
    colorHere = colorsUse{tgI};
    colorsUseHereA = colorHere+0.15; colorsUseHereA(colorsUseHereA > 1)=1;
    colorsUseHereB = colorHere-0.15; colorsUseHereB(colorsUseHereB < 0)=0;
    colorsUseHere = {colorsUseHereA; colorsUseHereB};
    labelsHere = {[labels{tgI} '-STEM']; [labels{tgI} '-ARM']};
    
    [statsOutTemp] = PlotTraitChangeOverDaysOne({pooledTraitChangesSTEM{tgI} pooledTraitChangesARM{tgI}},...
        pooledDaysApartSTEM,colorsUseHere,labelsHere,yLabel,ylims);
    
    statsOut.slopeDiffComp(tgI) = statsOutTemp.slopeDiffComp;
    statsOut.signtests(tgI) = statsOutTemp.signtests;
    statsOut.rankSumAll(tgI) = statsOutTemp.rankSumAll;
end

% Slopes of each of these lines
for tgI = 1:numTgs
    [~, ~, ~, statsOut.stem.slopeRR(tgI), statsOut.stem.slopePval(tgI), ~] =...
        fitLinRegSL(pooledTraitChangesSTEM{tgI}, pooledDaysApartSTEM);
    
    [statsOut.stem.slopeDiffZero(tgI).Fval,statsOut.stem.slopeDiffZero(tgI).dfNum,...
     statsOut.stem.slopeDiffZero(tgI).dfDen,statsOut.stem.slopeDiffZero(tgI).pVal] =...
        slopeDiffFromZeroFtest(pooledTraitChangesSTEM{tgI}, pooledDaysApartSTEM);
    
    [~, ~, ~, statsOut.arm.slopeRR(tgI), statsOut.arm.slopePval(tgI), ~] =...
        fitLinRegSL(pooledTraitChangesARM{tgI}, pooledDaysApartARM);
    
    [statsOut.arm.slopeDiffZero(tgI).Fval,statsOut.arm.slopeDiffZero(tgI).dfNum,...
     statsOut.arm.slopeDiffZero(tgI).dfDen,statsOut.arm.slopeDiffZero(tgI).pVal] =...
        slopeDiffFromZeroFtest(pooledTraitChangesARM{tgI}, pooledDaysApartARM);
end

end