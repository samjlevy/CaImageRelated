% Finding ensemble notes

(trialbytrial, armTrialbytrial)

for condI = 1:length(trialbytrial)
    cellsActiveDur{condI} = cellfun(@(x) sum(x,2),trialbytrial(condI).trialPSAbool,'UniformOutput',false);
    cellsActiveDurArm{condI} = cellfun(@(x) sum(x,2),armTrialbytrial(condI).trialPSAbool,'UniformOutput',false);
    
    cellsActiveAtAll{condI} = cellfun(@(x) x>0,cellsActiveDur{condI},'UniformOutput',false);
    cellsActiveAtAllArm{condI} = cellfun(@(x) x>0,cellsActiveDurArm{condI},'UniformOutput',false);
end

%For each cell
%For each trial

    %Check which arm cells are also active this trial
        %What does 'check' mean?
        
    %Check which arm cells were active last trial
    
    
