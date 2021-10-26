% proRetroSplitterNotes

% need proper indexing between All trials and AllEach

sessI = 6

lapsH = find(trialbytrialAll(1).sessID==sessI)
aa = trialbytrialAll(1).lapSequence(lapsH)
seqLengths = cellfun(@numel,aa);
proW = seqLengths<=3 & cellfun(@(x) x(end)=='w',aa)
proE = seqLengths<=3 & cellfun(@(x) x(end)=='e',aa)

%{
seqLengthsThree = cellfun(@numel,trialbytrialAll(1).lapSequence )<=3;
endsW = cellfun(@(x) x(end)=='w',trialbytrialAll(1).lapSequence);
endsE = cellfun(@(x) x(end)=='e',trialbytrialAll(1).lapSequence);

proWlaps = trialbytrialAll(1).sessID==sessI & seqLengthsThree & endsW;
proElaps = trialbytrialAll(1).sessID==sessI & seqLengthsThree & endsE;
%}

numNonZero = nan(numMice,9);
sumNeg = nan(numMice,9);
sumPos = nan(numMice,9);
numTrialsWest = nan(numMice,9);
numTrialsEast = nan(numMice,9);

nBinVerts = lgDataBins.labels=='n';

for mouseI = 1:numMice
  
    load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'), 'trialbytrialAllEach')
    load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'), 'trialbytrialAll')
 
    nCellsH = size(trialbytrialAll(1).trialPSAbool{1},1);
thirdW = cellfun(@(x) x(3)=='w',trialbytrialAll(1).lapSequence);
thirdE = cellfun(@(x) x(3)=='e',trialbytrialAll(1).lapSequence);
for sessI = 1:9
proWlaps = trialbytrialAll(1).sessID==sessI & thirdW;
proElaps = trialbytrialAll(1).sessID==sessI & thirdE;

prospecTBT(1).trialsX = trialbytrialAllEach(1).trialsX(proWlaps);
prospecTBT(1).trialsY = trialbytrialAllEach(1).trialsY(proWlaps);
prospecTBT(1).trialPSAbool = trialbytrialAllEach(1).trialPSAbool(proWlaps);
prospecTBT(1).trialDFDTtrace = trialbytrialAllEach(1).trialDFDTtrace(proWlaps);
prospecTBT(1).trialRawTrace = trialbytrialAllEach(1).trialRawTrace(proWlaps);
prospecTBT(1).sessID = ones(size(prospecTBT(1).trialsX));
prospecTBT(1).name = 'N heading W';
prospecTBT(2).trialsX = trialbytrialAllEach(1).trialsX(proElaps);
prospecTBT(2).trialsY = trialbytrialAllEach(1).trialsY(proElaps);
prospecTBT(2).trialPSAbool = trialbytrialAllEach(1).trialPSAbool(proElaps);
prospecTBT(2).trialDFDTtrace = trialbytrialAllEach(1).trialDFDTtrace(proElaps);
prospecTBT(2).trialRawTrace = trialbytrialAllEach(1).trialRawTrace(proElaps);
prospecTBT(2).sessID = ones(size(prospecTBT(2).trialsX));
prospecTBT(2).name = 'N heading E';

nLapsEach = [sum(proWlaps) sum(proElaps)];
numTrialsWest(mouseI,sessI) = sum(proWlaps);
numTrialsEast(mouseI,sessI) = sum(proElaps);
if sum(proElaps)>0 && sum(proWlaps)>0
[splitTmap,~] = RateMapsDoublePlusV2(prospecTBT, lgBinVertices, 'vertices', [1;2], 0, 'zeroOut', [], false);
if sum(proWlaps)==0
    [splitTmap(:,1)] = deal(zeros(49,1));
end
if sum(proElaps)==0
    [splitTmap{:,2}] = deal(zeros(49,1));
end
splitTmap = cellfun(@(x) x(nBinVerts),splitTmap,'UniformOutput',false);

%condsCheck = [1;2];
%condCheck(nLapsEach==0) = [];
[~,~,~,numTrialsH] = TrialReliability2(prospecTBT,allMazeBound,0.25,1,[1;2]);
numTrialsH = squeeze(numTrialsH);  

lapsThresh = [min([sum(proWlaps) 3]) min([sum(proElaps) 3])];

clear discMean

for cellI = 1:nCellsH
    actHere = squeeze([splitTmap{cellI,1,:}]);
    
    discIndex = (actHere(:,2) - actHere(:,1))./sum(actHere,2);
    
    binsActive = sum(actHere,2) > 0;
    enoughLaps = numTrialsH(cellI,:) > lapsThresh;
    enoughLaps = sum(enoughLaps) * ones(nArmBins,1);
    
    binsInclude = binsActive & enoughLaps;
    discMean(cellI) = mean(discIndex(binsInclude));
end

discMean(isnan(discMean))=0;

numNonZero(mouseI,sessI) = sum(discMean~=0);
sumNeg(mouseI,sessI) = sum(discMean < -0.5);
sumPos(mouseI,sessI) = sum(discMean > 0.5);
end

end
end
msgbox('done')

%{
cellI = 6; 
condPlot = [1;2];
dayI = 1;
coloring = 'dynamic'; coloring = 'aboveThresh'; 
[aboveThreshBins.X{1:2}] = deal(lgDataBins.X);
[aboveThreshBins.Y{1:2}] = deal(lgDataBins.Y);
radiusLimit = 5;
PlotDotplotDoublePlus2(prospecTBT,cellI,condPlot,dayI,coloring,aboveThreshBins,radiusLimit)
%}
cellI = 128;
condAB = [1 1];
lapsAB{1} = proWlaps; 
lapsAB{2} = proElaps;
ProRetroDotPlotV1(trialbytrialAll,condAB,lapsAB,cellI)

lapsH(1)

find(trialbytrialAllEach(1).sessID==6,1)

find(proW)

lapsN = find(trialbytrialAllEach(2).sessID==6)

lapsS = find(trialbytrialAllEach(4).sessID==6)

figure; plot(trialbytrialAll(1).trialsX{155},trialbytrialAll(1).trialsY{155},'.k')

%{
for ii = 1:length(lapsH)
    jj = lapsH(ii);
    figure; 
    plot(trialbytrialAll(1).trialsX{jj},trialbytrialAll(1).trialsY{jj},'.k')
    hold on
    plot(trialbytrialAllEach(1).trialsX{jj},trialbytrialAllEach(1).trialsY{jj},'.r')
    title(num2str(jj))
end
%}
% North laps from trialbytrialAll(1) index properly into trialbytrialAllEach(1)

tbtW = 