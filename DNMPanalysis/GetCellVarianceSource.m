function [b,r,stats, MSE] = GetCellVarianceSource(trialbytrial,pooledUnpooled)
%pooled unpooled is like in others, look at conditions individually or pool
%across dimension type

numCells = size(trialbytrial(1).trialPSAbool{1},1);
numSess = length(unique(trialbytrial(1).sessID));
conds = GetTBTconds(trialbytrial);

for cellI = 1:numCells
    for sessI = 1:numSess
        designMat = [];
        responses = [];
        for condI = 1:length(trialbytrial)
            lapsHere = trialbytrial(condI).sessID == sessI;
            cellPSAbool = cellfun(@(x) x(cellI,:),trialbytrial(condI).trialPSAbool(lapsHere),'UniformOutput',false);
        
            cellSum = cellfun(@sum,cellPSAbool,'UniformOutput',false);
            
            responses = [responses; cellSum];
            
            %desTrials = (size(designMat,1)+1):(size(designMat,1)+1+sum(lapsHere)-1);
            switch pooledUnpooled 
                case 'unpooled'
                    designAdd = zeros(sum(lapsHere),lengthConds);
                    designAdd(:, condI) = 1;
                    %designMat( desTrials, condI) = 1;
                case 'pooled'
                    designAdd = [sum(conds.Right==condI) sum(conds.Test == condI)];
                    designAdd = repmat(designAdd,sum(lapsHere),1);
                    %designMat( desTrials, :) = [sum(conds.Right==condI) sum(conds.Test == condI)];
            end
            designMat = [designMat; designAdd];
             
        end
        
        %Do the prediction
        designMat = [ones(size(designMat,1),1), designMat];
        responses = cell2mat(responses);
        
        [b,~,r,~,sta] = regress(responses,designMat);
        coefs{cellI,sessI} = b;
        %rsq(cellI,sessI) = r; 
        stats{cellI,sessI} = sta;
        MSE(cellI,sessI) = sta(4);
        
    end
end
                