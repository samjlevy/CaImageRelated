function[uniqueSeq,epochs] = filterSeqToUnique(sequence)

sequence = sequence(:);

itemsHere = unique(sequence);

onsets = [1; find(diff([sequence(1); sequence]))]; 
offsets = [find(diff([sequence; sequence(end)])); length(sequence)];

epochs = [onsets(:) offsets(:)];


for epochI = 1:size(epochs)
    try
        uniqueSeq(epochI) = unique(sequence(epochs(epochI,1):epochs(epochI,2)));
    catch
        disp('something wrong with frames here')
    end
end

end
