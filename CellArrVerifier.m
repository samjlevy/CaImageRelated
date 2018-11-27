            function notSame = CellArrVerifier(cellArr1,cellArr2)
numBins = length(cellArr1{1});

sameSize = cell2mat(cellfun(@(x,y) sum(x(:)==y(:))==numBins,cellArr1,cellArr2,'UniformOutput',false));

notSame = find(sameSize==0);

switch any(notSame)
    case 0
        disp('All values are the same in all cells')
    case 1
        disp(['Found ' num2str(length(notSame)) ' bad cells'])
end

end