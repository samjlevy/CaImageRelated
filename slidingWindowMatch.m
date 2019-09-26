function [epochs] = slidingWindowMatch(sequence,matchSeg)

sequence = sequence(:)'; %make it a row
matchSeg = matchSeg(:); %make it a column
ml = length(matchSeg);

I = eye(ml);
epochs = [];
for ii = 1:length(sequence)-(ml-1)
    matchArr = sequence(ii:ii+(ml-1)) == matchSeg;
    
    if sum(sum(matchArr==I))==ml*ml
        epochs = [epochs; ii ii+ml-1];
    end
    %if sum(sum(matchArr,1)==1)==ml && sum(sum(matchArr,2)==1)==ml
    %    epochs = [epochs; ii ii+ml-1];
    %end
end

end