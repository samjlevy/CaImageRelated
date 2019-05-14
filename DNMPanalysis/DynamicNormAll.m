function maxClose = DynamicNormAll(ptsX,ptsY,normX,normY,indexIntoNorm,radiusLimit)
%Index into norm has to fit normX(indexIntoNorm) = ptsX
%Can leave normX and normY empty to not normlize by another occupancy vector

numConds = length(ptsX);

%Make them rows for easier
for condI = 1:numConds
ptsX{condI} = ptsX{condI}(:)';
ptsY{condI} = ptsY{condI}(:)';
end

%if ~isempty(indexIntoNorm)
%    for condI = 1:numConds
%        ptsX{condI} = ptsX{condI}(indexIntoNorm{condI});
%        ptsY{condI} = ptsY{condI}(indexIntoNorm{condI});
%    end
%nd

%Get distances: arrangement is row is anchor point, Y is to this pt
for condI = 1:numConds
for ptI = 1:length(ptsX{condI})
    distances{condI}(ptI,:) = cell2mat(arrayfun(@(x,y)...
        hypot(ptsX{condI}(ptI)-x,ptsY{condI}(ptI)-y),ptsX{condI},ptsY{condI},'UniformOutput',false));
end
end

maxDist = max(max(distances{condI}));
minDist = min(min(distances{condI}(distances{condI}>0)));
    
%radiusLimit = 1;
for condI = 1:numConds
for ptI = 1:length(ptsX{condI})
    ptsClose{condI}(ptI,1) = sum(distances{condI}(ptI,:) <= radiusLimit,2) - 1;
end
end

%Repeat for occupancy normalizing
if ~isempty(normX) && ~isempty(normY)
    for condI = 1:numConds
    %if any(indexIntoNorm)
    %    normX = normX(indexIntoNorm);
    %    normY = normY(indexIntoNorm);
    %end
        normX{condI} = normX{condI}(:)';
        normY{condI} = normY{condI}(:)';

        for ptJ = 1:length(normX{condI})
            distancesNorm{condI}(ptJ,:) = cell2mat(arrayfun(@(x,y)...
                hypot(normX{condI}(ptJ)-x,normY{condI}(ptJ)-y),normX{condI},normY{condI},'UniformOutput',false));
        end

        for ptJ = 1:length(normX{condI})
            ptsCloseNorm{condI}(ptJ,1) = sum(distancesNorm{condI}(ptJ,:) <= radiusLimit,2) - 1;
        end

        if ~isempty(indexIntoNorm)
            ptsCloseNorm{condI} = ptsCloseNorm{condI}(indexIntoNorm{condI});
        end

        ptsClose{condI} = ptsClose{condI}(ptsCloseNorm{condI}~=0);
        ptsCloseNorm{condI} = ptsCloseNorm{condI}(ptsCloseNorm{condI}~=0);

        %These should now be the same size
        ptsClose{condI} = ptsClose{condI}./ptsCloseNorm{condI};
    end 
end

maxClose = max(cell2mat(cellfun(@max,ptsClose,'UniformOutput',false)));
    
end
