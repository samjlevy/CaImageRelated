function [pvCorrs, meanCorr, numCellsUsed, numNans, shuffPVcorrs, shuffMeanCorr, PVdayPairs ]=...
    MakePVcorrsWrapper2(trialbytrial, shuffleWhat, shuffleDim, numPerms, pooledCompPairs,...
                       pooledCondPairs, poolLabels, traitLogical, binEdges, minspeed)
%pooledCondPairs is how to pool placefields across dimensions
%pooledCompPairs is the pairs of condition comparisons to make after pooling placefields
%pooledShuffleDim is what dimension to shuffle across, should be same length as pooledCompPairs


numDays = length(unique(trialbytrial(1).sessID));

PVdayPairs = AllCombsV1V2(1:numDays,1:numDays);
numDayPairs = size(PVdayPairs,1);    
numCompPairs = length(pooledCompPairs);

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
    for cpI = 1:length(pooledCompPairs)
        %Strip down to essential day and condition pair
        minTbtA = StripTBT(tbtPooledA,pooledCompPairs{cpI}(1),PVdayPairs(dpI,1));
        minTbtB = StripTBT(tbtPooledB,pooledCompPairs{cpI}(2),PVdayPairs(dpI,2));
        
        %Make place fields: no cond pairs, already dealt with
        %{
        trialReliA = traitLogical(:,PVdayPairs(dpI,1),pooledCompPairs(cpI,1));
        [TMapMinA , ~, ~, ~, ~, ~] = PFsLinTrialbyTrial2(minTbtA, xlims, cmperbin, minspeed,...
            [],'trialReli',trialReliA,'smooth',false,'dispProgress',false,'getZscore',false);
        trialReliB = traitLogical(:,PVdayPairs(dpI,2),pooledCompPairs(cpI,2));
        [TMapMinB , ~, ~, ~, ~, ~] = PFsLinTrialbyTrial2(minTbtB, xlims, cmperbin, minspeed,...
            [],'trialReli',trialReliB,'smooth',false,'dispProgress',false,'getZscore',false);
        %}
        
        [TMapMinA, ~, ~, ~, ~, ~, ~] =...
            PFsLinTBTdnmp(minTbtA, binEdges, minspeed, [], false,[]);
        [TMapMinB, ~, ~, ~, ~, ~, ~] =...
            PFsLinTBTdnmp(minTbtB, binEdges, minspeed, [], false,[]);
        
        %Make the trialRelis
        trialReliA = traitLogical(:,PVdayPairs(dpI,1),pooledCompPairs{cpI}(1));
        trialReliB = traitLogical(:,PVdayPairs(dpI,2),pooledCompPairs{cpI}(2));
        
        %Run PV
        [pvCorrs{dpI,cpI},meanCorr{dpI,cpI},numCellsUsed{dpI,cpI},numNans{dpI,cpI}] = PopVectorCorrsSmallTMaps(...
            TMapMinA,TMapMinB,trialReliA,trialReliB,'activeEither','Spearman');
        %{
        for cpI = 1:length(pooledCompPairs)
                %Shuffle days, and pool into long tbts
                [growingShuffTbtAone, growingShuffTbtAtwo] = DayShuffleGrowingTBT(tbtSmallA,PVdayPairs,true);
                [growingShuffTbtBone, growingShuffTbtBtwo] = DayShuffleGrowingTBT(tbtSmallB,PVdayPairs,true);
                
                %pool trials across conditions
                dayShuffTbtPooledAone = PoolTBTacrossConds(growingShuffTbtAone,pooledCondPairs,poolLabels);
                %dayShuffTbtPooledAtwo = PoolTBTacrossConds(growingShuffTbtAtwo,pooledCondPairs,poolLabels);
                %dayShuffTbtPooledBone = PoolTBTacrossConds(growingShuffTbtBone,pooledCondPairs,poolLabels);
                dayShuffTbtPooledBtwo = PoolTBTacrossConds(growingShuffTbtBtwo,pooledCondPairs,poolLabels);

                %Slot compPair(2) from dayPair(x,2) into the right cond
                dayShuffTbtPooled = dayShuffTbtPooledAone;
                %dayShuffTbtPooledA(pooledCompPairs{cpI}(2)) = dayShuffTbtPooledAtwo(pooledCompPairs{cpI}(2));
                %dayShuffTbtPooledB = dayShuffTbtPooledBone;
                dayShuffTbtPooled(pooledCompPairs{cpI}(2)) = dayShuffTbtPooledBtwo(pooledCompPairs{cpI}(2));
                %NOTE: condPair index now has pooledCompPairs(cpI}(1) and dayPair(x,1)
                
                %Make place fields; no pooling 
                [dayShuffTMap, ~, ~, ~, ~, ~, ~] =...
                PFsLinTBTdnmp(dayShuffTbtPooled, binEdges, minspeed, [], false,[]);
                %[dayShuffTMapB, ~, ~, ~, ~, ~, ~] =...
                %PFsLinTBTdnmp(dayShuffTbtPooledB, binEdges, minspeed, [], false,[]);
                
                %Get reliability
                growingTraitLogical = DayPairGrowingTraitLogical(traitLogical,PVdayPairs,pooledCompPairs{cpI});
                trialReliA = growingTraitLogical(:,:,pooledCompPairs{cpI}(1));
                trialReliB = growingTraitLogical(:,:,pooledCompPairs{cpI}(2));
                
                %Make PV corrs 
                shuffTMapSlimA = dayShuffTMap(:,:,pooledCompPairs{cpI}(1));
                shuffTMapSlimB = dayShuffTMap(:,:,pooledCompPairs{cpI}(2));
                
                %"same day" day pairs
                alignedDayPairs = repmat(1:numDayPairs,2,1)';
                
                %Make correlations
                [shuffPVcorrResults,shuffMeanCorrResults,~,~] = PopVectorCorrsSlimTMaps(...
                    shuffTMapSlimA,shuffTMapSlimB,trialReliA,trialReliB,alignedDayPairs,'activeEither','Spearman');
                
                %shuffPVcorrsTemp(2,:) = shuffPVcorrResults;
                
                for dpI = 1:numDayPairs
                    shuffPVcorrs{dpI,cpI}(permI,:) = shuffPVcorrResults{dpI};
                    shuffMeanCorr{dpI,cpI}(permI,:) = shuffMeanCorrResults{dpI};
                end
        end
            %}
    end
end
 
%Do all the shuffling
shuffPVcorrs = cell(numDayPairs,numCompPairs);
shuffMeanCorr = cell(numDayPairs,numCompPairs);
if numPerms > 0

disp('Shuffling now')
p = ProgressBar(numPerms);

switch shuffleWhat
    case 'dimOnly'
        for permI = 1:numPerms
            %Shuffle across the dimensions
            shuffTbtSmallA = ShuffleTrialsAcrossConditions(tbtSmallA,shuffleDim);
            shuffTbtSmallB = ShuffleTrialsAcrossConditions(tbtSmallB,shuffleDim);
            
            %shuffTbtPooledA = PoolTBTacrossConds(shuffTbtSmallA,pooledCondPairs,poolLabels);
            %shuffTbtPooledB = PoolTBTacrossConds(shuffTbtSmallB,pooledCondPairs,poolLabels);
            
            %shuffTbtPooledA(
            
            %Make a bunch of place fields
            [shuffTMapSmallA, ~, ~, ~, ~, ~, ~] =...
                PFsLinTBTdnmp(shuffTbtSmallA, binEdges, minspeed, [], false,pooledCondPairs);
            [shuffTMapSmallB, ~, ~, ~, ~, ~, ~] =...
                PFsLinTBTdnmp(shuffTbtSmallB, binEdges, minspeed, [], false,pooledCondPairs);
            
            for cpI = 1:length(pooledCompPairs)
                %Trim to the one condition
                shuffTMapSlimA = shuffTMapSmallA(:,:,pooledCompPairs{cpI}(1));
                shuffTMapSlimB = shuffTMapSmallB(:,:,pooledCompPairs{cpI}(2));
                
                %Get reliability from original
                trialReliA = traitLogical(:,:,pooledCompPairs{cpI}(1));
                trialReliB = traitLogical(:,:,pooledCompPairs{cpI}(2));
                
                %Make correlations
                [shuffPVcorrResults,shuffMeanCorrResults,~,~] = PopVectorCorrsSlimTMaps(...
                    shuffTMapSlimA,shuffTMapSlimB,trialReliA,trialReliB,PVdayPairs,'activeEither','Spearman');
                %shuffPVcorrsTemp(2,:) = shuffPVcorrResults;
                
                for dpI = 1:numDayPairs
                    shuffPVcorrs{dpI,cpI}(permI,:) = shuffPVcorrResults{dpI};
                    shuffMeanCorr{dpI,cpI}(permI,:) = shuffMeanCorrResults{dpI};
                end
            end
            p.progress;
        end
        
    case 'dayOnly'
        for permI = 1:numPerms
            for cpI = 1:length(pooledCompPairs)
                %Shuffle days, and pool into long tbts
                [growingShuffTbtAone, growingShuffTbtAtwo] = DayShuffleGrowingTBT(tbtSmallA,PVdayPairs,true);
                [growingShuffTbtBone, growingShuffTbtBtwo] = DayShuffleGrowingTBT(tbtSmallB,PVdayPairs,true);
                
                %pool trials across conditions
                dayShuffTbtPooledAone = PoolTBTacrossConds(growingShuffTbtAone,pooledCondPairs,poolLabels);
                %dayShuffTbtPooledAtwo = PoolTBTacrossConds(growingShuffTbtAtwo,pooledCondPairs,poolLabels);
                %dayShuffTbtPooledBone = PoolTBTacrossConds(growingShuffTbtBone,pooledCondPairs,poolLabels);
                dayShuffTbtPooledBtwo = PoolTBTacrossConds(growingShuffTbtBtwo,pooledCondPairs,poolLabels);

                %Slot compPair(2) from dayPair(x,2) into the right cond
                dayShuffTbtPooled = dayShuffTbtPooledAone;
                %dayShuffTbtPooledA(pooledCompPairs{cpI}(2)) = dayShuffTbtPooledAtwo(pooledCompPairs{cpI}(2));
                %dayShuffTbtPooledB = dayShuffTbtPooledBone;
                dayShuffTbtPooled(pooledCompPairs{cpI}(2)) = dayShuffTbtPooledBtwo(pooledCompPairs{cpI}(2));
                %NOTE: condPair index now has pooledCompPairs(cpI}(1) and dayPair(x,1)
                
                %Make place fields; no pooling 
                [dayShuffTMap, ~, ~, ~, ~, ~, ~] =...
                PFsLinTBTdnmp(dayShuffTbtPooled, binEdges, minspeed, [], false,[]);
                %[dayShuffTMapB, ~, ~, ~, ~, ~, ~] =...
                %PFsLinTBTdnmp(dayShuffTbtPooledB, binEdges, minspeed, [], false,[]);
                
                %Get reliability
                growingTraitLogical = DayPairGrowingTraitLogical(traitLogical,PVdayPairs,pooledCompPairs{cpI});
                trialReliA = growingTraitLogical(:,:,pooledCompPairs{cpI}(1));
                trialReliB = growingTraitLogical(:,:,pooledCompPairs{cpI}(2));
                
                %Make PV corrs 
                shuffTMapSlimA = dayShuffTMap(:,:,pooledCompPairs{cpI}(1));
                shuffTMapSlimB = dayShuffTMap(:,:,pooledCompPairs{cpI}(2));
                
                %"same day" day pairs
                alignedDayPairs = repmat(1:numDayPairs,2,1)';
                
                %Make correlations
                [shuffPVcorrResults,shuffMeanCorrResults,~,~] = PopVectorCorrsSlimTMaps(...
                    shuffTMapSlimA,shuffTMapSlimB,trialReliA,trialReliB,alignedDayPairs,'activeEither','Spearman');
                
                %shuffPVcorrsTemp(2,:) = shuffPVcorrResults;
                
                for dpI = 1:numDayPairs
                    shuffPVcorrs{dpI,cpI}(permI,:) = shuffPVcorrResults{dpI};
                    shuffMeanCorr{dpI,cpI}(permI,:) = shuffMeanCorrResults{dpI};
                end
            end
            p.progress;
        end 
    case 'dayAndDim'
        disp('Nope not working yet')
end
p.stop;
end

end
