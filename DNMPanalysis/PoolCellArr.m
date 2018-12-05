function CSpooledCellArr = PoolCellArr(cellArr,poolingSets)

numPoolingSets = length({poolingSets{:}});
CSpooledCellArr = cell(size(poolingSets));
for csI = 1:numPoolingSets
    for csJ = 1:length(poolingSets{csI})
        CSpooledCellArr{csI} = [CSpooledCellArr{csI}; cellArr{poolingSets{csI}(csJ)}];
    end
end

end
