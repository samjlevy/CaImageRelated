function BigPSAbool = PoolPSA(all_PSAbool, sessionInds)
%Takes as input a cell array of PSAbools and sessionInds (array of how
%cells are matched together across sessions
%Shuffles around indices to align them by row, adds zero rows where needed

fullLength = sum(cellfun(@length,all_PSAbool));
BigPSAbool = zeros(size(sessionInds,1),fullLength);
for sess = 1:length(all_PSAbool)
    thisLength = size(all_PSAbool{1,sess},2);
    sessCells = sort(unique(sessionInds(:,sess)));
    sessCells(sessCells==0) = [];
    for thisCell = 1:sessCells
        cellRow = find(sessionInds(:,sess)==sessCells(thisCell)); 
        BigPSAbool(cellRow,1:thisLength) = all_PSAbool{1,sess}(sessCells(thisCell),:); %#ok<FNDSB>
    end
end

end


