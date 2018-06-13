function allFiringCOM = TMapFiringCOM(TMap)

allFiringCOM = cellfun(@FiringCOM,TMap,'UniformOutput',false);

end