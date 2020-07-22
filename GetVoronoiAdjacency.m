function voronoiAdj = GetVoronoiAdjacency(vorIndices,vorVerts)

if any(vorVerts)
    notInf = find(sum(~isinf(vorVerts),2)==2); %Indices that don't have inf
    fixedIndices = cellfun(@(x) x(logical(sum(x(:)==notInf(:)',2))),vorIndices,'UniformOutput',false);
    vorIndices = fixedIndices;
end

numCells = length(vorIndices);

aa = triu(ones(numCells),1);
[bb,cc] = ind2sub(size(aa),find(aa));
%tic
voronoiAdj = false(numCells,numCells);
for ii = 1:length(bb)
    voronoiAdj(bb(ii),cc(ii)) = any(sum(vorIndices{bb(ii)}==vorIndices{cc(ii)}'));
    %voronoiAdj(bb(ii),cc(ii)) = sum(sum(vorIndices{bb(ii)}==vorIndices{cc(ii)}'))>0;
end
%toc
voronoiAdj = voronoiAdj + voronoiAdj';

%Same operation, just to verify logic...
%{
indLocsX = cellfun(@(x) vorVerts(x,1),vorIndices,'UniformOutput',false);
badIndX = cellfun(@(x) ~isinf(x),indLocsX,'UniformOutput',false);
indLocsY = cellfun(@(x) vorVerts(x,2),vorIndices,'UniformOutput',false);
badIndY = cellfun(@(x) ~isinf(x),indLocsY,'UniformOutput',false);
noInfInds = cellfun(@(x,y) x & y,badIndX,badIndY,'UniformOutput',false);
fixedVerts2 = cellfun(@(x,y) x(y),vorIndices,noInfInds,'UniformOutput',false);
%}

%{
tic
voronoiAdj = false(numCells,numCells);
for cellI = 1:numCells
    %if edgePolys(cellI)==0
    for cellJ = 1:numCells
        if cellI ~= cellJ
            voronoiAdj(cellI,cellJ) =any(ismember(vorIndices{cellI},vorIndices{cellJ})); 
        end
    end
    %end
end
toc
%}
% aa = cellfun(@(x) indsToLogicals(x,size(vorVerts,1)),vorIndices,'UniformOutput',false);
%{
voronoiAdj = false(numCells,numCells);
for cellI = 1:numCells
    for cellJ = 1:numCells
        if cellI ~= cellJ
            voronoiAdj(cellI,cellJ) =any(sum(vorIndices{cellI}==vorIndices{cellJ}'));
            %voronoiAdj(cellI,cellJ) = any((aa{cellI}+aa{cellJ})==2);
            %voronoiAdj(cellI,cellJ) = any(aa{cellI}&aa{cellJ});
        end
    end
end
toc
%}



end