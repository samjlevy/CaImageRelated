function [pvCorrs, meanCorr, numCellsUsed, numNans, shuffPVcorrs, shuffMeanCorr, PVdayPairs ]=...
    MakePVcorrsWrapper(trialbytrial, shuffleWhat, numPerms, pooledCompPairs, shuffleCond,...
                       pooledCondPairs, poolLabels, traitLogical, xlims, cmperbin, minspeed)
%pooledCompPairs is the pairs of condition comparisons to make after pooling placefields
%pooledCondPairs is how to pool placefields across dimensions
%pooledShuffleDim is what dimension to shuffle across, should be same length as pooledCompPairs


numDays = length(unique(trialbytrial(1).sessID));

PVdayPairs = AllCombsV1V2(1:numDays,1:numDays);
numDayPairs = size(PVdayPairs,1);    
numCompPairs = size(pooledCompPairs,1);

%Split TBTs
[tbtSmallA, tbtSmallB] = SplitTrialByTrial(trialbytrial, 'alternate');

%Pool dims (for easy shuffling)
tbtPooledA = PoolTBTacrossConds(tbtSmallA,pooledCondPairs,poolLabels);
tbtPooledB = PoolTBTacrossConds(tbtSmallB,pooledCondPairs,poolLabels);

pvCorrs = cell(numDayPairs,numCompPairs);
meanCorr = cell(numDayPairs,numCompPairs);
numCellsUsed = cell(numDayPairs,numCompPairs);
numNans = cell(numDayPairs,numCompPairs);

for dpI = 1:numDayPairs
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
        shuffleDay = 1;
        shuffleDim = 1;
    case 'dimOnly'
        shuffleDay = 0;
        shuffleDim = 1;
    case 'dayOnly'
        shuffleDay = 1;
        shuffleDim = 0;
end

%Do all the shuffling
shuffPVcorrs = cell(numDayPairs,numCompPairs);
shuffMeanCorr = cell(numDayPairs,numCompPairs);
for permI = 1:numPerms
    for cpI = 1:size(pooledCompPairs,1)

        %Shuffle across dimensions
        if shuffleDim==1        
            %Shuffle Trials
            shuffTbtSmallA = ShuffleTrialsAcrossConditions(tbtSmallA,shuffleCond{cpI});
            shuffTbtSmallB = ShuffleTrialsAcrossConditions(tbtSmallB,shuffleCond{cpI});
        else
            shuffTbtSmallA = tbtSmallA;
            shuffTbtSmallB = tbtSmallB;
        end

        for dpI = 1:size(PVdayPairs,1)
            
            %Shuffle across days
            if shuffleDay==1
                condDayShuffA = ShuffleTrialsAcrossDays(shuffTbtSmallA,PVdayPairs(dpI,1),PVdayPairs(dpI,2));
                condDayShuffB = ShuffleTrialsAcrossDays(shuffTbtSmallB,PVdayPairs(dpI,1),PVdayPairs(dpI,2));
            else
                condDayShuffA = shuffTbtSmallA;
                condDayShuffB = shuffTbtSmallB;
            end
            
            %Pool across dimensions
            shuffPooledTbtA = PoolTBTacrossConds(condDayShuffA,pooledCondPairs,poolLabels);
            shuffPooledTbtB = PoolTBTacrossConds(condDayShuffB,pooledCondPairs,poolLabels);
            
            %Get reliability from original
            trialReliA = traitLogical(:,PVdayPairs(dpI,1),pooledCompPairs(cpI,1));
            trialReliB = traitLogical(:,PVdayPairs(dpI,2),pooledCompPairs(cpI,2));
        
            %Strip to minimum day and condition
            shuffMinTbtA = StripTBT(shuffPooledTbtA,pooledCompPairs(cpI,1),PVdayPairs(dpI,1));  
            shuffMinTbtB = StripTBT(shuffPooledTbtB,pooledCompPairs(cpI,2),PVdayPairs(dpI,2));  
                
                    
            %Make place fields
            [shuffTMapMinA , ~, ~, ~, ~, ~] = PFsLinTrialbyTrial2(shuffMinTbtA, xlims, cmperbin, minspeed,...
                    [],'trialReli',trialReliA,'smooth',false,'dispProgress',false,'getZscore',false);
            [shuffTMapMinB , ~, ~, ~, ~, ~] = PFsLinTrialbyTrial2(shuffMinTbtB, xlims, cmperbin, minspeed,...
                    [],'trialReli',trialReliB,'smooth',false,'dispProgress',false,'getZscore',false);

            %Run PV
            [shuffPVcorrs{dpI,cpI}(permI,:),shuffMeanCorr{dpI,cpI}(permI,1),~,~] = PopVectorCorrsSmallTMaps(...
                    shuffTMapMinA,shuffTMapMinB,trialReliA,trialReliB,'activeEither','Spearman');
        end
    end
end


end
%{
        %this might actually not be right? Doesn't introduce data from
        %other conditions like shuffle across conditions does
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
%}