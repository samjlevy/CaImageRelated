% Fix daybyday registration:


%sortedSessionInds(isnan(sortedSessionInds)) = 0;
totalNSess = length(daybyday.all_x_adj_cm);

sessUse = totalNSess-8:totalNSess;
nCells = size(sortedSessionInds,1);
sortedSessionInds = cell_registered_struct.cell_to_index_map;

for sessI = 1:9
    %{
    daybydayBig.all_x_adj_cm{sessI,1} = daybyday.all_x_adj_cm{sessUse(sessI)};
    daybydayBig.all_y_adj_cm{sessI,1} = daybyday.all_y_adj_cm{sessUse(sessI)};
    daybydayBig.behavior{sessI,1} = daybyday.behavior{sessUse(sessI)};
    daybydayBig.excludeFrames{sessI,1} = daybyday.excludeFrames{sessUse(sessI)};
    daybydayBig.realDays(sessI,1) = daybyday.realDays(sessUse(sessI));
    daybydayBig.sessType{sessI,1} = daybyday.sessType{sessUse(sessI)};
    daybydayBig.mazeSize{sessI,1} = daybyday.mazeSize{sessUse(sessI)};
    %}
    nFrames = size(daybyday.PSAbool{sessUse(sessI)},2);
    cellsH = sortedSessionInds(:,sessI);
    
    daybydayBig.PSAbool{sessI} = zeros(nCells,nFrames);
    daybydayBig.PSAbool{sessI}(cellsH>0,:) = ...
        daybyday.PSAbool{sessUse(sessI)}(cellsH(cellsH>0),:);
    daybydayBig.PSAbool{sessI} = logical(daybydayBig.PSAbool{sessI});
    
    daybydayBig.RawTrace{sessI} = zeros(nCells,nFrames);
    daybydayBig.RawTrace{sessI}(cellsH>0,:) = ...
        daybyday.RawTrace{sessUse(sessI)}(cellsH(cellsH>0),:);
    
    daybydayBig.DFDTtrace{sessI} = zeros(nCells,nFrames);
    daybydayBig.DFDTtrace{sessI}(cellsH>0,:) = ...
        daybyday.DFDTtrace{sessUse(sessI)}(cellsH(cellsH>0),:);
end

%allfiles = allfiles(sessUse);
save('daybydayBig.mat','daybydayBig','sortedSessionInds','allfiles','-v7.3')