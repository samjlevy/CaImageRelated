function tiersAdj = GetAllTierAdjacency(adjMat,tierLim)

if isempty(tierLim)
    tierLim = 10;
end

nCells = size(adjMat,1);

cellsCovered = false(nCells,nCells);
tiersAdj = zeros(nCells,nCells);
for cellI = 1:nCells
    tiersAdj(cellI,cellI) = Inf;
end

tierI = -1;
%if there are any cells we haven't found adjacency for yet
while (sum(sum(cellsCovered==0)) > 0) && tierI < tierLim-1
    tierI = tierI + 1;
    tierNadj = GetTierNAdjacency(adjMat,tierI);
    tierNadj = tierNadj*(tierI+1); %label this adjacency with its tierN
    
    tierNadj = tierNadj .* ~cellsCovered; %Exclude points from tier up to this point
    
    tiersAdj = tiersAdj + tierNadj; %add to whole relationship matrix
    

   cellsCovered = tiersAdj > 0;
   
   if tierI >= tierLim-1
       disp(['Encounterd tier limit = ' num2str(tierLim)]) 
   end
end

tiersAdj(tiersAdj==Inf) = 0;

end