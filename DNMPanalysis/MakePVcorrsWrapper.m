function [pvCorrs,meanCorr,numCellsUsed,numNans,shuffpvCorrs,shuffMeanCorr,PVdayPairs ]=...
    MakePVcorrsWrapper(trialbytrial,shuffleWhat,numPerms,pooledCompPairs,pooledCondPairs,traitLogical)

numDays = length(unique(trialbytrial(1).sessID));

PVdayPairs = AllCombsV1V2(1:numDays,1:numDays);
    
%Split TBTs
[tbtSmallA, tbtSmallB] = SplitTrialByTrial(trialbytrial, 'alternate');

%Pool dims (for easy shuffling
tbtPooledA = PoolTBTacrossConds(tbtSmallA,pooledCondPairs,poolLabels);
tbtPooledB = PoolTBTacrossConds(tbtSmallB,pooledCondPairs,poolLabels);

for dpI = 1:size(PVdayPairs{mouseI},1)
    for cpI = 1:size(pooledCompPairs,1)
        %Strip down to essential day and condition pair
        minTbtA = StripTBT(tbtPooledA,pooledCompPairs(cpI,1),PVdayPairs(dpI,1));
        minTbtB = StripTBT(tbtPooledB,pooledCompPairs(cpI,2),PVdayPairs(dpI,2));
        
        %Make place fields
        trialReliA = traitLogical(:,PVdayPairs(dpI,1),pooledCompPairs(cpI,1));
        [TMapMinA , ~, ~, ~, ~, ~] = PFsLinTrialbyTrial2(minTbtA, xlims, cmperbin, minspeed,...
            [],'trialReli',trialReliA,'smooth',false,'dispProgress',false,'getZscore',false);
        trialReliB = traitLogical(:,PVdayPairs(dpI,2),pooledCompPairs(cpI,2));
        [TMapMinB , ~, ~, ~, ~, ~] = PFsLinTrialbyTrial2(minTbtB, xlims, cmperbin, minspeed,...
            [],'trialReli',trialReliB,'smooth',false,'dispProgress',false,'getZscore',false);
        
        %Run PV
        [pvCorrs{dpI,cpI},meanCorr{dpI,cpI},numCellsUsed{dpI,cpI},numNans{dpI,cpI}] = PopVectorCorrsSmallTMaps(...
            TMapMinA,TMapMinB,trialReliA,trialReliB,'activeEither','Spearman');
    end
end
                            
switch shuffleWhat
    case 'dayAndDim'

        for dpI = 1:size(PVdayPairs,1)
            for cpI = 1:size(pooledCompPairs,1)
                %Strip down to essential day and condition pair
                minTbtA = StripTBT(tbtPooledA,pooledCompPairs(cpI,1),PVdayPairs(dpI,1));
                minTbtB = StripTBT(tbtPooledB,pooledCompPairs(cpI,2),PVdayPairs(dpI,2));

                %Make place fields
                trialReliA = traitLogical(:,PVdayPairs(dpI,1),pooledCompPairs(cpI,1));
                %[TMapMinA , ~, ~, ~, ~, ~] = PFsLinTrialbyTrial2(minTbtA, xlims, cmperbin, minspeed,...
                %                    [],'trialReli',trialReliA,'smooth',false,'dispProgress',false,'getZscore',false);
                trialReliB = traitLogical(:,PVdayPairs(dpI,2),pooledCompPairs(cpI,2));
                %[TMapMinB , ~, ~, ~, ~, ~] = PFsLinTrialbyTrial2(minTbtB, xlims, cmperbin, minspeed,...
                %                    [],'trialReli',trialReliB,'smooth',false,'dispProgress',false,'getZscore',false);

                %Run PV
                %[pvCorrs{dpI,cpI},meanCorr{dpI,cpI},numCellsUsed{dpI,cpI},numNans{dpI,cpI}] = PopVectorCorrsSmallTMaps(...
                %                TMapMinA,TMapMinB,trialReliA,trialReliB,'activeEither','Spearman');

                for permI = 1:numPerms
                    %Shuffle between the two: this will shuffle both day and condition
                    [shuffMinTbtA, shuffMinTbtB] = ShuffleMinTBTs(minTbtA,minTbtB,'random');
                    shuffMinTbtA.sessID(:) = 1; shuffMinTbtB.sessID(:) = 1;

                    %Make place fields
                    [shuffTMapMinA , ~, ~, ~, ~, ~] = PFsLinTrialbyTrial2(shuffMinTbtA, xlims, cmperbin, minspeed,...
                                    [],'trialReli',trialReliA,'smooth',false,'dispProgress',false,'getZscore',false);
                    [shuffTMapMinB , ~, ~, ~, ~, ~] = PFsLinTrialbyTrial2(shuffMinTbtB, xlims, cmperbin, minspeed,...
                                    [],'trialReli',trialReliB,'smooth',false,'dispProgress',false,'getZscore',false);

                    %Run PV
                    [shuffpvCorrs{dpI,cpI}(permI,:),shuffMeanCorr{dpI,cpI}(permI,1),~,~] = PopVectorCorrsSmallTMaps(...
                                shuffTMapMinA,shuffTMapMinB,trialReliA,trialReliB,'activeEither','Spearman');
                end
            end
        end
        
    case 'condOnly'
        
        %LR first
        pooledCompPairs = [1 1; 2 2; 3 3; 4 4; 1 2; 2 1];
                
        for permI = 1:numPerms
            %Shuffle Trials
            LRshuffTbtSmallA = ShuffleTrialsAcrossConditions(tbtSmallA,'leftright');
            LRshuffTbtSmallB = ShuffleTrialsAcrossConditions(tbtSmallB,'leftright');
        
            %Pool by dim
            LRshuffTbtPooledA = PoolTBTacrossConds(LRshuffTbtSmallA,pooledCondPairs,poolLabels);
            LRshuffTbtPooledB = PoolTBTacrossConds(LRshuffTbtSmallB,pooledCondPairs,poolLabels);
        
            for dpI = 1:size(PVdayPairs{mouseI},1)
                for cpI = 1:size(pooledCompPairs,1)
                    trialReliA = traitLogical(:,PVdayPairs(dpI,1),pooledCompPairs(cpI,1));
                    trialReliB = traitLogical(:,PVdayPairs(dpI,2),pooledCompPairs(cpI,2));
                
                    LRshuffMinTbtA = StripTBT(LRshuffTbtPooledA,pooledCompPairs(cpI,1),PVdayPairs(dpI,1));
                    LRshuffMinTbtB = StripTBT(LRshuffTbtPooledB,pooledCompPairs(cpI,2),PVdayPairs(dpI,2));
                    
                    %Make place fields
                    [shuffTMapMinA , ~, ~, ~, ~, ~] = PFsLinTrialbyTrial2(LRshuffMinTbtA, xlims, cmperbin, minspeed,...
                                    [],'trialReli',trialReliA,'smooth',false,'dispProgress',false,'getZscore',false);
                    [shuffTMapMinB , ~, ~, ~, ~, ~] = PFsLinTrialbyTrial2(LRshuffMinTbtB, xlims, cmperbin, minspeed,...
                                    [],'trialReli',trialReliB,'smooth',false,'dispProgress',false,'getZscore',false);

                    %Run PV
                    [LRshuffpvCorrs{dpI,cpI}(permI,:),LRshuffMeanCorr{dpI,cpI}(permI,1),~,~] = PopVectorCorrsSmallTMaps(...
                                shuffTMapMinA,shuffTMapMinB,trialReliA,trialReliB,'activeEither','Spearman');
                end
            end 
        end
            
        %ST second
        pooledCompPairs = [1 1; 2 2; 3 3; 4 4; 3 4; 4 3];
        
        STshuffledTBT = ShuffleTrialsAcrossConditions(trialbytrial,'studytest');
        
        
        
    case 'dayOnly'
        
end

end