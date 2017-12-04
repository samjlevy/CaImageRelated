function lapBlockNums = assignLapBlocks(trialbytrial, numBlocks)

numSess = length(unique(trialbytrial(1).sessID));
numConds = length(trialbytrial);

lapBlockNums = cell(numConds,1);

for condI = 1:numConds
    
    lapBlockNums{condI} = zeros(length(trialbytrial(condI).sessID),1);
    
    for sessI = 1:numSess
        theseLaps = find(trialbytrial(condI).sessID==sessI);
        edges = round(linspace(1,length(theseLaps),numBlocks+1));
        edges(1) = 0;
        
        blockID = zeros(length(theseLaps),1);
        for bb = 1:numBlocks
            blockID(edges(bb)+1:edges(bb+1)) = bb;
        end
        lapBlockNums{condI}(theseLaps) = blockID;
    end
end



end