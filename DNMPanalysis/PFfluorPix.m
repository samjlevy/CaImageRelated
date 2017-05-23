function [PFfluoresence] = PFfluorPix(PFocc,isrunning,LPtrace)%PFpixels,,RunOccMap,xBin,yBin,

shift = min(LPtrace);
LPtrace = LPtrace - shift;

%Convert PFepochs to PSAbool time
runningInds = find(isrunning); 
allEpoch = [];
for epoch = 1:size(PFocc,1)
    allEpoch = [allEpoch PFocc(epoch,1):PFocc(epoch,2)];
end
PFinPSAboolInds = runningInds(allEpoch);

allPFfluor = LPtrace(PFinPSAboolInds);  

%PFfluoresence = mean(allPFfluor);
PFfluoresence = sum(allPFfluor)/size(PFocc,1);


%For matching time to bins
%linIndTotal = sub2ind(size(RunOccMap),xBinTotal,yBinTotal);

end