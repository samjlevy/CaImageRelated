function numTrialCells = CellsActiveEachTrial(trialbytrial)

for condI = 1:length(trialbytrial)
    numTrialCells{condI} = ...
        cell2mat(cellfun(@(x) sum(sum(x,2)>0),[trialbytrial(condI).trialPSAbool],'UniformOutput',false));
end

end