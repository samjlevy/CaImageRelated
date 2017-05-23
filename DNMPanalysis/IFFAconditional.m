function [activity, hits, hitRate, durations, meanDur] = IFFAconditional(PSAbool, inFieldTimes, blockBounds) 
%inFieldTimes comes from AllTimeInField, PF logical for duration of PSABool
%blockBounds froms from GetBlockDNMPbehavior, starts and stops

numCells = size(PSAbool,1);
numFields = size(inFieldTimes,2);
hits = nan(size(inFieldTimes));
hitRate = nan(size(inFieldTimes));
meanDur =  nan(size(inFieldTimes));
durations = cell(size(inFieldTimes));
activity = cell(size(inFieldTimes));

for thisCell = 1:numCells
    for thisField = 1:numFields
        if any(inFieldTimes{thisCell,thisField})
            cellPSAbool=PSAbool(thisCell,:).*inFieldTimes{thisCell,thisField};
            fieldCondHits = 0;
            theseDurs = [];
            PSAhere = [];
            for thisBlock = 1:length(blockBounds)
                thisPass = blockBounds(thisBlock,:);
                PSAhere{thisBlock,1} = cellPSAbool([thisPass(1):thisPass(2)]);
                fieldCondHits = fieldCondHits + any(PSAhere{thisBlock,1});
                theseDurs = [theseDurs; sum(PSAhere{thisBlock,1})];
            end
            hitRateHere = fieldCondHits/length(blockBounds);
            meanDurHere = mean(theseDurs);
            
            hits(thisCell, thisField) = fieldCondHits;
            hitRate(thisCell, thisField) = hitRateHere;
            durations{thisCell, thisField} = theseDurs;
            meanDur(thisCell, thisField) = meanDurHere;
            activity{thisCell, thisField} = PSAhere;
        end
    end
end


end

%Rate remapping
[stem_frame_bounds, stem_include, ~] =...
    GetBlockDNMPbehavior( frames, txt, 'stem_only', length(x_adj_cm));
forcedLbounds = [stem_framesBounds.forced_l_start stem_frame_bounds.forced_l_stop];
PSA = load('Pos_align.mat','PSAbool');
%[PFepochPSA] = PFepochToPSAtime ( place_stats_file, isRunningInds, pos_file )
%[FoLPSAbool] = ConditionalActivityOnly(PSA.PSAbool, stem_include.forced_l);
[FoLinFieldTime,FoLpasses] = AllTimeInField (files.maps.FoL, files.stats.FoL);
%[IFFA]=InFieldFiringActivity(FoLPSAbool, FoLinFieldTime);
[FoLactivity, FoLhits, FoLhitRate, FoLdurations, FoLmeanDur] =...
    IFFAconditional(PSA.PSAbool, FoLinFieldTime, forcedLbounds); 

