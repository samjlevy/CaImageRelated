function [epochs,inSequence] = slidingWindowMatch(sequence,matchSeg)

sequence = sequence(:)'; %make it a row
matchSeg = matchSeg(:); %make it a column
ml = length(matchSeg);

I = logical(eye(ml));
epochs = [];
inSequence = false(size(sequence));
for ii = 1:length(sequence)-(ml-1)
    tbs = ii:ii+(ml-1);
    matchArr = sequence(tbs) == matchSeg;
    
    %if sum(sum(matchArr==I))==ml*ml %Strict sequence where each element only happens once
    if sum(matchArr(I))==ml %Less exclusive, allows non-unique sequence elements
        epochs = [epochs; tbs(1) tbs(end)];
        inSequence(tbs) = true;
    end
    %if sum(sum(matchArr,1)==1)==ml && sum(sum(matchArr,2)==1)==ml
    %    epochs = [epochs; ii ii+ml-1];
    %end
end

end