function [outputs] = CellRegStatsPostHoc(frDir)

distanceThreshold = 3;
try 
    load(fullfile(frDir,'fullReg.mat'))
    load(fullfile(frDir,'fullRegROIavg.mat'))
catch
    [frFile,frDir] = uigetfile('*.mat','Full reg file:');
    load(fullfile(frDir,'fullReg.mat'))
    load(fullfile(frDir,'fullRegROIavg.mat'))
end

%regImageBufferUse = 'RegisteredImageSLbuffered2.mat';
regImageBufferUse = 'RegisteredImageSL.mat';

numRegSess = length(fullReg.RegSessions);
%Pre allocate some stuff
for regI = 1:numRegSess
    
    baseDir = fullReg.RegSessions{regI};
    if exist(fullfile(baseDir,regImageBufferUse),'file')==0
        disp('Seems like we can not load this: please direct us to the proper drive (any directory)')
        baseDir = uigetdir('File not found, direct to correct folder');
    end
    
    baseDirSplit = strsplit(baseDir,'\');
    baseDirLetter = baseDirSplit{1};
    newBasePath = fullfile(baseDirLetter,fullReg.RegSessions{regI}(3:end));
    regImage = load(fullfile(newBasePath,regImageBufferUse));
    OriginalImage = load(fullfile(newBasePath,'FinalOutput.mat'),'NeuronImage');
    regImage.OriginalImage = OriginalImage.NeuronImage;
    OriginalAvg = load(fullfile(newBasePath,'FinalOutput.mat'),'NeuronAvg');
    regImage.OriginalAvg = OriginalAvg.NeuronAvg;
    
    regImage.OriginalCenters = getAllCellCenters(regImage.OriginalImage);
    disp(['Loaded background file, working on reg stats for registered session ' num2str(regI)])
    
    %Make a function from here
    
    %Step based on registration session order, what cells registered so far
    lastCellUseReg = find(fullReg.sessionInds(:,regI+1),1,'last');
    cellsCheckReg = 1:lastCellUseReg;
    lastCellUseBase = find(fullReg.sessionInds(:,regI),1,'last'); 
    cellsCheckBase = 1:lastCellUseBase;
    
    numBaseCells = lastCellUseBase;
    numRegCells = length(regImage.reg_shift_centers);
    
    %start assigning cells
    [closestCell, distance] = findclosest2D(...
        fullReg.centers(cellsCheckBase,1), fullReg.centers(cellsCheckBase,2),...
        regImage.reg_shift_centers(:,1), regImage.reg_shift_centers(:,2));
    %closest cell is index in base cells for all reg cells
    allClosestCells = closestCell;
    allDistances = distance;

    %Refine based on center-to-center distances
    cellsInRange = closestCell(distance < distanceThreshold);
    closestCell(distance >= distanceThreshold) = NaN;
    rinds = 1:numRegCells; %reg cells nums
    inRangeIndices = rinds(distance <= distanceThreshold); %indices of regCells
    binEdges = 0.5:1:numBaseCells+0.5;
    [counts,~] = histcounts(cellsInRange,binEdges);
    overlapped = find(counts > 1);
    %if 2 cells get matched to the same base cell, use the one with the higher correlation
    for repCell = 1:length(overlapped)
        matchedCells = inRangeIndices(cellsInRange==overlapped(repCell)); 
            %indices in closestCell, full length regCells

        baseReg = fullRegROIavg{1,overlapped(repCell)};
        regMatchedReg = {regImage.regAvg_shifted{1,matchedCells}};

        areaCorrs = cellfun(@(x) corr(baseReg(:),x(:),'type','Spearman'), regMatchedReg, 'UniformOutput',false);
        areaCorrs = cell2mat(areaCorrs);

        useCell = areaCorrs==max(areaCorrs);
        if sum(useCell)==1
            %good
            closestCell(matchedCells(~useCell)) = NaN;
            distance(matchedCells(~useCell)) = NaN;
        else
            %either both or none, problem; mostly shouldn't happen?
            disp('something up here, found 2 matches for this cell; probably need a fallback')
        end 
    end

    %Reorganizing into indices from tenaspis runs
    inRangeIndicesCells = rinds(~isnan(closestCell)); %reg cells
    unpairedRegCells = rinds(isnan(closestCell));
    %length(inRangeIndicesCells) + length(unpairedRegCells) == numRegCells
    
    bref = ones(size(fullReg.centers,1),1);
    bref(allClosestCells(inRangeIndicesCells)) = 0;
    unmatchedBaseCells = find(bref);
    
    matchedBaseCells = allClosestCells(inRangeIndicesCells);
    numMatchedHere = length(matchedBaseCells);
    
    realRegColumn = fullReg.sessionInds(cellsCheckBase,regI+1);
    recreatedRegColumn = [];
    recreatedRegColumn(matchedBaseCells,1) = inRangeIndicesCells;
    
    if length(realRegColumn) ~= length(recreatedRegColumn)
        disp('Some kind of size mismatch')
        dbstop
    end
    
    %Assess real and recreated mismatches
    unexpectedReg = realRegColumn ~= recreatedRegColumn;
    unexpectedRegCells = find(unexpectedReg);
    
    %Manually rejected: when re-registered, found a match, but registered
    %says nothing
    manualRejected = realRegColumn(unexpectedReg)~=0; %Indexes into uRegInds
    manRejInds = unexpectedRegCells(manualRejected);
    manRejCells = recreatedRegColumn(manRejInds);
    
    %Swapped in: when re-registered, nothing, but there is a cellregistered there
    swappedIn = realRegColumn(unexpectedReg)~=0; %Indexes into uRegInds
    swappedInInds = unexpectedRegCells(swappedIn);
    swappedInCells = realRegColumn(swappedInInds); %Index in the reg session
    
    regCellsHere = sum(fullReg.sessionInds(:,[1 regI+1])>0,2)==2;
    regCellsBaseInds = fullReg.sessionInds(regCellsHere,1);
    regCellsFromReg = fullReg.sessionInds(regCellsHere,regI+1);
    regFromRegInds = regCellsFromReg(regCellsFromReg>0);
    %Stats to get:
    
    %Distances between cells pre-registration
    [preRegDistancesAll,~] = GetAllPtToPtDistances(...
        [fullReg.centers(cellsCheckBase,1); regImage.OriginalCenters(:,1)],...
        [fullReg.centers(cellsCheckBase,2); regImage.OriginalCenters(:,2)],[]);
    preRegDistances = preRegDistancesAll(1:numBaseCells,numBaseCells+1:numBaseCells+numRegCells);
    
    %Distances between cells post-registration
    [postRegDistancesAll,~] = GetAllPtToPtDistances(...
        [fullReg.centers(cellsCheckBase,1); regImage.reg_shift_centers(:,1)],...
        [fullReg.centers(cellsCheckBase,2); regImage.reg_shift_centers(:,2)],[]);
    postRegDistances = postRegDistancesAll(1:numBaseCells,numBaseCells+1:numBaseCells+numRegCells);
    
    %cell ROI correlation Before registration not possible because of different cropping windows
        
    %cell ROI correlation after registration
    [imageCorrs] = getAllCellImageCorrelations(fullRegROIavg(cellsCheckBase),regImage.regAvg_shifted);
    
    %Cell major axis orientation
    postShiftOrientations = cell2mat(cellfun(@(x) x.Orientation,cellfun(@(x) regionprops(x,'orientation'),...
        regImage.regImage_shifted...
        ,'UniformOutput',false),'UniformOutput',false));
    registeredCellOrientations = cell2mat(cellfun(@(x) x.Orientation,cellfun(@(x) regionprops(x,'orientation'),...
        fullRegImage...
        ,'UniformOutput',false),'UniformOutput',false));
    preShiftOrientations = cell2mat(cellfun(@(x) x.Orientation,cellfun(@(x) regionprops(x,'orientation'),...
        regImage.OriginalImage...
        ,'UniformOutput',false),'UniformOutput',false));
    
    postDiffs = abs(registeredCellOrientations(regCellsBaseInds) - postShiftOrientations(regFromRegInds));
    postDiffs(postDiffs > 90) = 180 - postDiffs(postDiffs > 90);
    
    preDiffs = abs(registeredCellOrientations(regCellsBaseInds) - preShiftOrientations(regFromRegInds));
    preDiffs(preDiffs > 90) = 180 - preDiffs(preDiffs > 90);
    
    %Demo fig
    %{
    aa = figure; plot(log(postRegDistances),imageCorrs,'.k')
    reformX = mat2cell(round(exp(aa.Children.XTick),2),1,ones(1,length(aa.Children.XTick)));
    dispX = cellfun(@num2str,reformX,'UniformOutput',false);
    aa.Children.XTickLabels = dispX;
    xlabel('Distance (um)'); ylabel('ROI correlation')
    rcInds = find(regCellsHere);
    for rrI = 1:length(rcInds)
        coo = fullReg.sessionInds(rcInds(rrI),1:2);
        hold on
        plot(log(postRegDistances(coo(1),coo(2))),imageCorrs(coo(1),coo(2)),'.r')
    end
    %}
    
    outputs.manualCells.all{regI} = unexpectedRegCells; %all cells that are not purely translation, distance threshold, correlation
    outputs.manualCells.rejected{regI} = manRejCells; %Cells rejected manually
    outputs.manualCells.added{regI} = swappedInCells; %Cells added manually
    
    outputs.cellCenterDistances.preRegistration{regI} = preRegDistances;
    outputs.cellCenterDistances.postRegistration{regI} = postRegDistances;
    
    outputs.ROIcorrelations{regI} = imageCorrs;
    
    %outputs.regImageOriginal{regI} = regImage.OriginalImage;
    %outputs.regImageAVGoriginal{regI} = regImage.OriginalAvg;
end

end