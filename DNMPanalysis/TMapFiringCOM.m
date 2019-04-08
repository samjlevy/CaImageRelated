function allFiringCOM = TMapFiringCOM(TMap,varargin)

allFiringCOM = cell2mat(cellfun(@FiringCOM,TMap,'UniformOutput',false));

if ~isempty(varargin)
    if strcmpi(varargin{1},'maxBin')
        allFiringCOM = cell2mat(cellfun(@MaxFiringBin,TMap,'UniformOutput',false));
    end
end

end