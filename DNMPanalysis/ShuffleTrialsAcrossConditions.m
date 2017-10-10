function shuffledTBT = ShuffleTrialsAcrossConditions(trialbytrial,dimShuffle)

lStudy = find(strcmpi({trialbytrial(:).name},'study_l'));
rStudy =  find(strcmpi({trialbytrial(:).name},'study_r'));
lTest =  find(strcmpi({trialbytrial(:).name},'test_l'));
rTest =  find(strcmpi({trialbytrial(:).name},'test_r'));

moreTrials = max(cellfun(@length, {trialbytrial(:).trialPSAbool}));

switch dimShuffle
    case {'direction','leftright'}
        useSess = [lStudy rStudy lTest rTest];
        
        shuffleThis = round(rand(mostTrials,2));
        trialShuffAssign = [useSess(shuffleThis(:,1)+1)' useSess(~shuffleThis(:,1)+1)' ...
                            useSess(shuffleThis(:,2)+3)' useSess(~shuffleThis(:,2)+3)'];
    case {'studytest','trialtype'}
        useSess = [lStudy lTest rStudy rTest];
        
        shuffleThis = round(rand(mostTrials,2));
        trialShuffAssign = [useSess(shuffleThis(:,1)+1)' useSess(~shuffleThis(:,1)+1)' ...
                            useSess(shuffleThis(:,2)+3)' useSess(~shuffleThis(:,2)+3)'];
    case 'all'
        useSess = [lStudy rStudy lTest rTest];
        
        for tt = 1:moreTrials
            trialShuffAssign(tt,:) = useSess(randperm(4));
        end
end

shuffledTBT = trialbytrial;

ss = fieldnames(trialbytrial);
%First equalize these cell arrays
for fn = 1:length(ss)
    if iscell(trialbytrial(1).(ss{fn}))
        for condType = 1:4
            if length(shuffledTBT(condType).(ss{fn})) < moreTrials
                neededInds = length(shuffledTBT(condType).(ss{fn}))+1:moreTrials;
                shuffledTBT(condType).(ss{fn})(neededInds) = cell(length(neededInds),1);
            end
        end
    end
    if strcmpi(ss{fn},'sessID')
        for condType = 1:4
            neededInds = length(shuffledTBT(condType).(ss{fn}))+1:moreTrials;
            shuffledTBT(condType).(ss{fn})(neededInds) = 3;
        end
    end
end
drawFrom = shuffledTBT;
%then re-sort trials by condition
fixedSessID = zeros(4,1);
for fn = 1:length(ss)
    if iscell(trialbytrial(1).(ss{fn}))
        for condType = 1:4
            for trial = 1:moreTrials
                shuffledTBT(condType).(ss{fn}){trial} = ...
                    drawFrom(trialShuffAssign(trial,condType)).(ss{fn}){trial};
            end
            deleteT = cellfun(@isempty, shuffledTBT(condType).(ss{fn}));
            shuffledTBT(condType).(ss{fn})(deleteT) = [];
            if fixedSessID(condType)==0
                shuffledTBT(condType).sessID(deleteT) = [];
                fixedSessID(condType) = 1;
            end
        end
    end
end

end

