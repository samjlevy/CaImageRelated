function MultiSessPlacefieldsLin( allfiles, all_x_adj_cm, all_y_adj_cm, sessionInds, all_PSAbool, cmperbin, all_useLogical, useActual)
numSessions = length(allfiles); 
allInc = cell(4,length(allfiles));
pooled = cell(length(allfiles),1);
for file = 1:length(allfiles)
    bta = dir(fullfile(allfiles{file},'*BrainTime_Adjusted.xlsx'));
    if length(bta)==1
        bta = bta.name;
    elseif length(bta) > 1
        isRight = cell2mat(cellfun(@(x) any(strfind(x,'~$')),{bta.name},'UniformOutput',false));
        if sum(isRight)==1
            bta = bta(isRight).name;
        end
    else 
        disp('could not find brainTime_adjusted file')
        return
    end
    [bounds{file},~,~, pooled{file},correct{file}] =...
    GetBlockDNMPbehavior( fullfile(allfiles{file},bta), 'stem_only', length(all_x_adj_cm{1,file}));

    allInc{1,file} = pooled{file}.include.forced & pooled{file}.include.left; %studyLeft
    allInc{2,file} = pooled{file}.include.forced & pooled{file}.include.right; %studyRight
    allInc{3,file} = pooled{file}.include.free & pooled{file}.include.left;%testLeft
    allInc{4,file} = pooled{file}.include.free & pooled{file}.include.right; %testRight    
end

correctBounds = StructCorrect(bounds, correct);

trialbytrial = PoolTrialsAcrossSessions(correctBounds,all_x_adj_cm,all_y_adj_cm,all_PSAbool,sessionInds);




plotX = [trialbytrial(cond).trialsX{:}];
plotY = [trialbytrial(cond).trialsY{:}];
blockBool = logical([trialbytrial(cond).trialPSAbool{:}]);
spikeX = plotX(blockBool(14,:));
spikeY = plotY(blockBool(14,:));
ddd



%Old version
%preallocate place cell stuff;
for cellI = 1:length(useActual)
    thisCell = useActual(cellI);
for cond = 1:4
    plotX = [];
    spikeX = [];
    cellPSA = [];
    for sess = 1:numSessions           
        PSArow = sessionInds(thisCell,sess);
        if PSArow ~= 0
            if all_useLogical{1,sess}(PSArow)==1
                hereTime = allInc{cond,sess};
                plotX = [plotX all_x_adj_cm{1,sess}(hereTime)]; %#ok<AGROW>
                spikeX = [spikeX all_x_adj_cm{1,sess}(hereTime & all_PSAbool{1,sess}(PSArow,:))]; %#ok<AGROW>
                cellPSA = [cellPSA  all_PSAbool{1,sess}(PSArow,allInc{cond,sess})]; %#ok<AGROW>
            end
        end
    end
    
    %make linPlace Field
    xmin = 25;
    xmax = 60;
    Xrange = xmax-xmin; 
    nXBins = ceil(Xrange/cmperbin); 
    xEdges = (0:nXBins)*cmperbin+xmin;
    
    nFrames = length(plotX);
    SR=20;
    dx = diff(plotX);
    dy = diff(plotY);
    speed = hypot(dx,dy)*SR;
    velocity = convtrim(speed,ones(1,2*20))./(2*20);
    good = true(1,nFrames);
    isrunning = good;                                   %Running frames that were not excluded. 
    isrunning(velocity < minspeed) = false;
    
    [OccMap{thisCell,cond},RunOccMap{thisCell,cond},xBin{thisCell,cond}] = MakeOccMapLin(plotX,good,isrunning,xEdges);
    [TMap_unsmoothed{thisCell,cond},TCounts{thisCell,cond},TMap_gauss{thisCell,cond}] = ...
            MakePlacefieldLin(logical(cellPSA),plotX,xEdges,RunOccMap{thisCell,cond},...
            'cmperbin',cmperbin,'smooth',true);
    
    %make tuning curves
    PlaceTuningCurveLin(PSAbool, bounds, x_adj_cm)
    
end
end

end