function [uniqueSeq,seqEpochs] = SingleTrialSequence(xPos,yPos,bounds,flickerThresh)

seqID = zeros(1,length(xPos));
for sI = 1:length(bounds)
    [inArea,~] = inpolygon(xPos,yPos,bounds{sI}(:,1),bounds{sI}(:,2));
    seqID(inArea) = sI;
end

[uniqueSeq,seqEpochs] = filterSeqToUnique(seqID);
seqDurs = diff(seqEpochs,1,2);
    
%any that are <= flicker thresh get cut,
tooShort = seqDurs<=flickerThresh;
uniqueSeq(tooShort) = [];
seqEpochs(tooShort,:) = [];

end