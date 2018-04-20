function sigDecoding = decoderSignificance(performance,sessPairs,pThresh)
%Expects performance organized as columns by decoding condition, 1st row is
%the original, rows after are shuffled

numConds = size(performance,2);
numShuffles = size(performance,1)-1;
pInd = round((1-pThresh)*numShuffles); %Be greather than this

for condI = 1:numConds
    %Reorganize
    thesePerfs = zeros(numShuffles,size(sessPairs,1)); 
    for shuffI = 1:numShuffles
        thesePerfs(shuffI,:) = performance{shuffI+1,condI}';
    end
    
    thesePerfs = sort(thesePerfs,1,'ascend');
    thesePerfs95 = thesePerfs(pInd,:);
    
    sigDecoding{1,condI} = performance{1,condI}'>thesePerfs95;
end

end