function shuffledTBT = ShuffleTrialsAcrossConditions(trialbytrial,dimShuffle)
%This one only shuffles trials across conditions, maintains day assignment

lStudy = find(strcmpi({trialbytrial(:).name},'study_l'));
rStudy =  find(strcmpi({trialbytrial(:).name},'study_r'));
lTest =  find(strcmpi({trialbytrial(:).name},'test_l'));
rTest =  find(strcmpi({trialbytrial(:).name},'test_r'));


sessions = unique(trialbytrial(1).sessID);
shuffledTBT = trialbytrial;
ss = fieldnames(trialbytrial);
sessIDlong = [];
shuffTBTassign = [];

%Figure out where trials need to go
for sessI = 1:length(sessions)
    %moreTrials = max(cellfun(@length, {trialbytrial(:).trialPSAbool}));
    for aa = 1:length(trialbytrial)
        howManyTrials(aa) = sum(trialbytrial(aa).sessID==sessions(sessI));
        whichTrials{aa} = find(trialbytrial(aa).sessID==sessions(sessI));
    end
    moreTrials = max(howManyTrials);
    if size(dimShuffle,1)==1
        switch dimShuffle
            case {'direction','leftright','LR'}
                useSess = [lStudy rStudy lTest rTest];

                shuffleThis = round(rand(moreTrials,2));
                trialShuffAssign = [useSess(shuffleThis(:,1)+1)' useSess(~shuffleThis(:,1)+1)' ...
                                    useSess(shuffleThis(:,2)+3)' useSess(~shuffleThis(:,2)+3)'];
            case {'studytest','trialtype','ST'}
                useSess = [lStudy lTest rStudy rTest];

                shuffleThis = round(rand(moreTrials,2));
                trialShuffAssign = [useSess(shuffleThis(:,1)+1)' useSess(~shuffleThis(:,1)+1)' ...
                                    useSess(shuffleThis(:,2)+3)' useSess(~shuffleThis(:,2)+3)'];
                trialShuffAssign = trialShuffAssign(:, [1 3 2 4]);
            case 'all'
                useSess = [lStudy rStudy lTest rTest];

                for tt = 1:moreTrials
                    trialShuffAssign(tt,:) = useSess(randperm(4));
                end
        end
    else
        %custom shuffling pairs
        useSess = [];
        allNamesHere = {trialbytrial(:).name};
        for shuffPairI = 1:size(dimShuffle,1)
            for shuffThisI = 1:size(dimShuffle,2)
                useSess = [useSess,  find(strcmpi({trialbytrial(:).name},dimShuffle{shuffPairI,shuffThisI}))];
            end
        end        
        
        shuffleThis = round(rand(moreTrials,2));
        trialShuffAssign = [useSess(shuffleThis(:,1)+1)' useSess(~shuffleThis(:,1)+1)' ...
                            useSess(shuffleThis(:,2)+3)' useSess(~shuffleThis(:,2)+3)'];

        finalColOrder = [];
        for nameI = 1:length(allNamesHere)
            finalColOrder(nameI) = find(useSess==nameI);
        end
                        
        trialShuffAssign = trialShuffAssign(:, finalColOrder);
    end
    
    %Mod assignments to better index
    for cc = 1:4
        if howManyTrials(cc) < moreTrials
            zeroOut = trialShuffAssign(howManyTrials(cc)+1:end,:) == cc;
            zeroOutA = [zeros(howManyTrials(cc),4); zeroOut];
            trialShuffAssign(logical(zeroOutA)) = 0;
        end
    end
    
    shuffTBTassign = [shuffTBTassign; trialShuffAssign];
    sessIDlong = [sessIDlong; ones(moreTrials,1)*sessI];
end

%Preallocate
for condJ = 1:4
    shuffledTBT(condJ).trialsX = cell(length(sessIDlong),1);
    shuffledTBT(condJ).trialsY = cell(length(sessIDlong),1);
    shuffledTBT(condJ).trialPSAbool = cell(length(sessIDlong),1);
    shuffledTBT(condJ).trialRawTrace = cell(length(sessIDlong),1);
    %shuffledTBT(condJ).sessID = sessIDlong;
    %shuffledTBT(condJ).sessID(shuffTBTassign(:,condJ)==0) = 0;
    shuffledTBT(condJ).sessID = zeros(length(sessIDlong),1);
    shuffledTBT(condJ).lapNumber = zeros(length(sessIDlong),1);
    shuffledTBT(condJ).name = trialbytrial(condJ).name;
end

%Deal out trials to new conditions
for sessJ = 1:length(sessions)
    for fn = 1:length(ss)
        if iscell(trialbytrial(1).(ss{fn})) || isnumeric(trialbytrial(1).(ss{fn}))
            for condType = 1:4
                for condDraw = 1:4
                    %Get the indices to fill
                    allDeal = shuffTBTassign(:,condType)==condDraw;
                    indDealTo = allDeal & (sessIDlong==sessJ);
                    %Get the indices to draw from
                    findDrawFrom = find(shuffTBTassign(sessIDlong==sessJ,condType)==condDraw);
                    allDrawFrom = find(trialbytrial(condDraw).sessID == sessJ);
                    indDrawFrom = allDrawFrom(findDrawFrom); %#ok<FNDSB>
                    shuffledTBT(condType).(ss{fn})(indDealTo) =...
                        trialbytrial(condDraw).(ss{fn})(indDrawFrom);
                end
            end
        end
    end
end

if size(dimShuffle,1)>1
    condShuffles = mat2cell(shuffTBTassign,size(shuffTBTassign,1),ones(1,4));
    shuffConds = [];
    allNamesHere = {trialbytrial(:).name};
    for shuffPairI = 1:size(dimShuffle,1)
        for shuffThisI = 1:size(dimShuffle,2)
            shuffConds(shuffPairI,shuffThisI) = find(strcmpi({trialbytrial(:).name},dimShuffle{shuffPairI,shuffThisI}));
        end
    end
    for condI = 1:4 
        [shuffPair,~] = ind2sub([2,2],find(shuffConds==condI));
        for shuffR = 1:size(condShuffles{condI},1)
            if condI~=condShuffles{condI}(shuffR)
                holdX = shuffledTBT(condI).trialsX{shuffR};
                holdY = shuffledTBT(condI).trialsY{shuffR};
            
                switch [dimShuffle{shuffPair,:}]
                    case {'southnorth','northsouth','eastwest','westeast'}
                        shuffledTBT(condI).trialsX{shuffR} = holdX*-1;
                        shuffledTBT(condI).trialsY{shuffR} = holdY*-1;
                    case {'eastsouth','southeast','westnorth','northwest'}
                        shuffledTBT(condI).trialsX{shuffR} = holdY*-1;
                        shuffledTBT(condI).trialsY{shuffR} = holdX*-1;
                end
            end
        end
    end
end
    
    
%Delete empty cells
for condK = 1:4
    shuffledTBT(condK).trialsX(shuffTBTassign(:,condK)==0) = [];
    shuffledTBT(condK).trialsY(shuffTBTassign(:,condK)==0) = [];
    shuffledTBT(condK).trialPSAbool(shuffTBTassign(:,condK)==0) = [];
    shuffledTBT(condK).trialRawTrace(shuffTBTassign(:,condK)==0) = [];
    shuffledTBT(condK).sessID(shuffTBTassign(:,condK)==0) = [];
    shuffledTBT(condK).lapNumber(shuffTBTassign(:,condK)==0) = [];
end

%{    
    %First equalize these cell arrays
    
    %There used to be more stuff here but now it's gone
                    
                if howManyTrials(condType) < moreTrials

        
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
%}

end

