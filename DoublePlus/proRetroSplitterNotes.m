% proRetroSplitterNotes

% need properindexing between All trials and AllEach

sessID = 6
lapsH = find(trialbytrialAll(1).sessID==6)
aa = trialbytrialAll(1).lapSequence(lapsH)
seqLengths = cellfun(@numel,aa)
proW = seqLengths<=3 & cellfun(@(x) x(end)=='w',aa)
proE = seqLengths<=3 & cellfun(@(x) x(end)=='e',aa)
find(proW)

lapsN = find(trialbytrialAllEach(2).sessID==6)

lapsS = find(trialbytrialAllEach(4).sessID==6)

figure; plot(trialbytrialAll(1).trialsX{155},trialbytrialAll(1).trialsY{155},'.k')