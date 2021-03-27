function [binOrderIndex] = SetBinOrder(dataBins,trialOrders,numInnerKeep)

armLabels = ['n','e','s','w'];
binMidsX = mean(dataBins.X,2);
binMidsY = mean(dataBins.Y,2);

pt = [binMidsX(dataBins.labels=='m') binMidsY(dataBins.labels=='m')];
otherPts = [binMidsX binMidsY]; % (lgDataBins.label~='m')
binDistFromCenter = GetPtFromPtsDist(pt,otherPts);
for armI = 1:4
    theseArms = find(dataBins.labels == armLabels(armI));
    armDists = binDistFromCenter(theseArms);
    [~,armBinDistsRank{armI}] = sort(armDists,'ascend');
    % if we need to eliminate furthest out bin
    if ~isempty(numInnerKeep)
         armBinDistsRank{armI} = armBinDistsRank{armI}(1:numInnerKeep);
    end
end



for toI = 1:numel(trialOrders)
    armSeq = trialOrders{toI};
    %binOrderIndex{toI} = [];
    switch numel(armSeq)
        case 1
        armBins = find(dataBins.labels == armSeq);
        binOrderIndex{toI} = armBins(armBinDistsRank{find(armLabels==armSeq)});
    
        case 3
    armBinsS = find(dataBins.labels == armSeq(1));
    armBinsE = find(dataBins.labels == armSeq(3));
    binOrderIndex{toI} = [armBinsS(flipud(armBinDistsRank{find(armLabels==armSeq(1))}));...
                          find(dataBins.labels==armSeq(2));...
                          armBinsE(armBinDistsRank{find(armLabels==armSeq(3))})];
    end
        %{
    figure; plot(binMidsX(binOrderIndex{toI}),binMidsY(binOrderIndex{toI}))
    hold on
    ptColors = rateColorMap(1:length(binOrderIndex{toI}),'jet',length(binOrderIndex{toI}));
    for ii = 1:length(binOrderIndex{toI}); plot(binMidsX(binOrderIndex{toI}(ii)),binMidsY(binOrderIndex{toI}(ii)),'o','MarkerFaceColor',ptColors(ii,:)); end
  %}
end

end