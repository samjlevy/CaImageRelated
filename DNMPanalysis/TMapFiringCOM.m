function allFiringCOM = TMapFiringCOM(TMap,dayUse)

%for cellI = 1:size(TMap,1)
%    for sessI = 1:size(TMap,3)
%        for condI = 1:size(TMap,

allFiringCOM = cell2mat(cellfun(@FiringCOM,TMap,'UniformOutput',false));

if any(dayUse)
    allFiringCOM(dayUse

end