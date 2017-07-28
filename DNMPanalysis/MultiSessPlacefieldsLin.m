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

[sortedReliability,aboveThresh] = TrialReliability(trialbytrial, 0.5);
newUseActual = find(sum(aboveThresh,2) > 0);

rastPlot = figure('name','Raster Plot','Position',[100 50 1000 800]);
PlotRasterMultiSess2(trialbytrial, thisCell, sessionInds, sortedReliability,rastPlot);

dotHeat = figure;
sublocs = [  ;   ;   ;  ];
ManyDotPlots(trialbytrial, thisCell, sessionInds, aboveThresh, dotHeat, subLocs); 

%make lin place fields

%plot heatmaps

plotX = [trialbytrial(condType).trialsX{:}];
plotY = [trialbytrial(condType).trialsY{:}];
blockBool = [trialbytrial(condType).trialPSAbool{:}];
spikeX = plotX(blockBool(14,:));
spikeY = plotY(blockBool(14,:));
ddd



%Old version
%preallocate place cell stuff;
for cellI = 1:length(useActual)
    thisCell = useActual(cellI);
for condType = 1:4
    plotX = [];
    spikeX = [];
    cellPSA = [];
    for sess = 1:numSessions           
        PSArow = sessionInds(thisCell,sess);
        if PSArow ~= 0
            if all_useLogical{1,sess}(PSArow)==1
                hereTime = allInc{condType,sess};
                plotX = [plotX all_x_adj_cm{1,sess}(hereTime)]; %#ok<AGROW>
                spikeX = [spikeX all_x_adj_cm{1,sess}(hereTime & all_PSAbool{1,sess}(PSArow,:))]; %#ok<AGROW>
                cellPSA = [cellPSA  all_PSAbool{1,sess}(PSArow,allInc{condType,sess})]; %#ok<AGROW>
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
    
    [OccMap{thisCell,condType},RunOccMap{thisCell,condType},xBin{thisCell,condType}] = MakeOccMapLin(plotX,good,isrunning,xEdges);
    [TMap_unsmoothed{thisCell,condType},TCounts{thisCell,condType},TMap_gauss{thisCell,condType}] = ...
            MakePlacefieldLin(logical(cellPSA),plotX,xEdges,RunOccMap{thisCell,condType},...
            'cmperbin',cmperbin,'smooth',true);
    
    %make tuning curves
    PlaceTuningCurveLin(PSAbool, bounds, x_adj_cm)
    
end
end

end