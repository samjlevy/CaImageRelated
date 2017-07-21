function [BigPSAbool, all_PSAbool_aligned] = PoolPSA(all_PSAbool, sessionInds)
%Takes as input a cell array of PSAbools and sessionInds (array of how
%cells are matched together across sessions
%Shuffles around indices to align them by row, adds zero rows where needed

fullLength = sum(cellfun(@length,all_PSAbool));
BigPSAbool = zeros(size(sessionInds,1),fullLength);

for sess = 1:length(all_PSAbool)
    all_PSAbool_aligned{sess} = zeros(size(sessionInds,1),size(all_PSAbool{sess},2));
    
    
    thisLength = size(all_PSAbool{1,sess},2);
    sessCells = sort(unique(sessionInds(:,sess)));
    sessCells(sessCells==0) = [];
    for thisCell = 1:sessCells
        cellRow = find(sessionInds(:,sess)==sessCells(thisCell)); 
        BigPSAbool(cellRow,1:thisLength) = all_PSAbool{1,sess}(sessCells(thisCell),:);
        
        %all_PSAbool_aligned{sess}(cellRow,:) = all_PSAbool{1,sess}(sessCells(thisCell),:);
    end
    for thisCell = 1:size(sessionInds,1)
        if sessionInds(thisCell,sess)~=0
        all_PSAbool_aligned{sess}(thisCell,1:thisLength) = all_PSAbool{sess}(sessionInds(thisCell,sess),1:thisLength);
        end
    end
end
        
end


