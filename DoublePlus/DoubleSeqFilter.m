function [filteredSequences, filteredSeqEpochs] = DoubleSeqFilter(sequences,seqEpochs,outThresh)

nSeq = numel(sequences);

filteredSequences = cell(nSeq,1);
filteredSeqEpochs = cell(nSeq,1);
for ii = 1:nSeq
    seqH = sequences{ii}(1);
    seqEh = seqEpochs{ii}(1,:);
    for jj = 1:numel(sequences{ii})-1
        seqH = [seqH; sequences{ii}(jj+1)];
        seqEh = [seqEh; seqEpochs{ii}(jj+1,:)];
        if sequences{ii}(jj) == sequences{ii}(jj+1)
            if (seqEpochs{ii}(jj+1,1) - seqEpochs{ii}(jj,2)) < outThresh
                seqH(end) = [];
                seqEh(end-1,2) = seqEh(end,2);
                seqEh(end,:) = [];
            end
        end  
    end
    filteredSequences{ii,1} = seqH;
    filteredSeqEpochs{ii,1} = seqEh;
end

end