function allFiringCOM = TMapFiringCOM(TMap)

allFiringCOM = cell2mat(cellfun(@FiringCOM,TMap,'UniformOutput',false));

end