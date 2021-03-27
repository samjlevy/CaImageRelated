function [binsKeep] = TrimBinsUse(dataBins,numInnerKeep)


armLabels = ['n','e','s','w'];
binMidsX = mean(dataBins.X,2);
binMidsY = mean(dataBins.Y,2);

pt = [binMidsX(dataBins.labels=='m') binMidsY(dataBins.labels=='m')];
otherPts = [binMidsX binMidsY]; % (lgDataBins.label~='m')
binDistFromCenter = GetPtFromPtsDist(pt,otherPts);

binsKeep = false(size(dataBins.X,1),1);
for armI = 1:4
    theseArms = find(dataBins.labels == armLabels(armI));
    armDists = binDistFromCenter(theseArms);
    [~,armBinDistsRank{armI}] = sort(armDists,'ascend');
    % if we need to eliminate furthest out bin
    armBinDistsRank{armI} = armBinDistsRank{armI}(1:numInnerKeep);
    
    binsKeep(theseArms(armBinDistsRank{armI})) = true;
    
end

binsKeep(armLabels=='m') = true;

end
