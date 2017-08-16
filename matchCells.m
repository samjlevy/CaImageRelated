function matchCells(base_path, reg_paths)

distanceThreshold = 3;
numSessions = size(reg_paths,1);

if exist(fullfile(base_path,'fullReg.mat'),'file')
    load(fullfile(base_path,'fullReg.mat'))
    load(fullfile(base_path,'fullRegImage.mat'))
    load(fullfile(base_path,'fullRegROIavg.mat'))
    
else
    load(fullfile(base_path,'FinalOutput.mat'),'NeuronImage','NeuronAvg')
    baseImage = NeuronImage;
    
    base_cellCenters = getAllCellCenters(baseImage);
    baseOrientation = cellfun(@(x) regionprops(x,'Orientation'), baseImage,'UniformOutput',false);
    
    fullReg.sessionInds = [1:length(baseImage)]'; %#ok<NBRAK>
    fullReg.BaseSession = base_path;
    fullReg.RegSessions = {};
    fullReg.centers = base_cellCenters; 
    fullReg.orientation = cell2mat(cellfun(@(x) x.Orientation, baseOrientation, 'UniformOutput',false))';
    
    fullRegImage = baseImage;
    fullRegROIavg = MakeAvgROI(NeuronImage,NeuronAvg);
    
    save(fullfile(base_path,'fullReg.mat'),'fullReg','-v7.3')
    save(fullfile(base_path,'fullRegImage.mat'),'fullRegImage','-v7.3')
    save(fullfile(base_path,'fullRegROIavg.mat'),'fullRegROIavg','-v7.3')
    disp('no fullReg found, making and saving')
end    

for rs = 1:numSessions
    if numSessions==1
        reg_path = reg_paths;
    else
        reg_path = reg_paths{rs};
    end
    if ~exist(fullfile(reg_path,'RegisteredImageSL.mat'),'file')
        disp(['did not find image registration data for ' reg_paths])
        [~, ~, ~] = manual_reg_SL(base_path, reg_paths);
    else 
        disp(['found registration for ' reg_paths])
    end
end

for regsess = 1:numSessions
    if numSessions==1
        reg_path = reg_paths;
    else
        reg_path = reg_paths{rs};
    end

    matchup = 0; already = 0;
if ~isempty(fullReg.RegSessions)
    if any(cell2mat(cellfun(@(x) strcmpi(x,reg_path),fullReg.RegSessions,'UniformOutput',false)))
        disp(['this session ' reg_path ' is already registered, skipping assignment'])
        %matchup=str2double(input('Rerun? 0/1','s'));
    else
        matchup = 1;
    end
else
    matchup = 1;
end

if matchup==1
    fullReg.RegSessions{length(fullReg.RegSessions)+1} = reg_path;

    load(fullfile(reg_path,'RegisteredImageSL.mat'))

    numRegCells = length(regImage_shifted);
    numBaseCells = length(fullRegImage);

    %Start assigning cells
    [closestCell, distance] = findclosest2D(...
        fullReg.centers(:,1), fullReg.centers(:,2),...
        reg_shift_centers(:,1), reg_shift_centers(:,2));
    %closest cell is index in base cells for all reg cells
    allClosestCells = closestCell;
    allDistances = distance;

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
        regMatchedReg = {regAvg_shifted{1,matchedCells}};

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

    %inRangeIndicesCells = rinds(distance <= distanceThreshold);
    %unpairedRegCells = rinds((distance > distanceThreshold) | isnan(distance));
    %unmatchedBaseCells = closestCell(unpairedRegCells & ~isnan(closestCell));
    %unmatchedBaseCells = closestCell(unpairedRegCells);
    %unmatchedBaseCells(isnan(unmatchedBaseCells)) = [];
    
    inRangeIndicesCells = rinds(~isnan(closestCell));
    unpairedRegCells = rinds(isnan(closestCell));
    %length(inRangeIndicesCells) + length(unpairedRegCells) == numRegCells
    
    bref = ones(size(fullReg.centers,1),1);
    bref(allClosestCells(inRangeIndicesCells)) = 0;
    unmatchedBaseCells = find(bref);
        
    removed = [];
    %Show image of cells that aren't matched for forced matching
    if any(unpairedRegCells) && any(unmatchedBaseCells)
    doneManual = 0;
    skipPrompt=0;
    while doneManual == 0
        if exist('baseFig','var'); delete(baseFig); clear('baseFig'); end
        if exist('regFig','var'); delete(regFig); clear('regFig'); end
        
        baseUnpaired = create_AllICmask(fullRegImage(unmatchedBaseCells));
        regUnpaired = create_AllICmask(regImage_shifted(unpairedRegCells));
        [overlay,overlayRef] = imfuse(baseUnpaired,regUnpaired,'ColorChannels',[1 2 0]);

        if exist('mixFig','var'); delete(mixFig); clear('mixFig'); end
        mixFig = figure; imshow(overlay,overlayRef)
        title(['Base and unpaired reg cells, ' num2str(length(unpairedRegCells))...
            ' cell centers for ' num2str(distanceThreshold) 'um'])
        
        if skipPrompt==0
        forceAssign = questdlg('Want to force assignments?','Force assign','Yes','No','No'); 
        end
        switch forceAssign
            case 'Yes'
                %Get pair of cells to force like in manual_reg_SL
                baseFig = figure('name','Base Session Masks','position',...
                [100 100 size(baseUnpaired,2)*1.5 size(baseUnpaired,1)*1.5]);
                hold off; imagesc(baseUnpaired); title('Base Session Masks')

                regFig = figure('name','Reg Session Masks','position',...
                    [100+size(baseUnpaired,2)*1.5 100 size(regUnpaired,2)*1.5 size(regUnpaired,1)*1.5]);
                hold off; imagesc(regUnpaired); title('Reg Session Masks')
                
                figure(baseFig);
                [xBase, yBase] = ginput(1);
                [baseCell, ~] = findclosest2D(fullReg.centers(unmatchedBaseCells,1),...
                    fullReg.centers(unmatchedBaseCells,2), xBase, yBase);
                hold on
                plot(fullReg.centers(unmatchedBaseCells(baseCell),1), fullReg.centers(unmatchedBaseCells(baseCell),2),'*r');
        
                figure(regFig);
                [xReg, yReg] = ginput(1);
                [regCell, ~] = findclosest2D(reg_shift_centers(unpairedRegCells,1),...
                    reg_shift_centers(unpairedRegCells,2), xReg, yReg);
                hold on
                plot(reg_shift_centers(unpairedRegCells(regCell),1), reg_shift_centers(unpairedRegCells(regCell),2),'*r');
                
                figure(mixFig);
                hold on
                plot(fullReg.centers(unmatchedBaseCells(baseCell),1),fullReg.centers(unmatchedBaseCells(baseCell),2),'*r');
                plot(reg_shift_centers(unpairedRegCells(regCell),1),reg_shift_centers(unpairedRegCells(regCell),2),'*c');
                
                doneManual = 0;
                manGood = questdlg('Good?','Good','Yes','Redo','Cancel','Yes');
                switch manGood
                    case 'Yes'
                        %Move those cells appropriately
                        inRangeIndicesCells = [inRangeIndicesCells unpairedRegCells(regCell)];
                        unpairedRegCells(regCell) = [];
                        unmatchedBaseCells(baseCell) = [];
                        
                        removed(size(removed,1)+1,1:2) = [unmatchedBaseCells(baseCell) unpairedRegCells(regCell)];
                        
                        skipPrompt=0;
                    case 'Redo'
                        skipPrompt=1;
                    case 'Cancel'
                        skipPrompt=0;
                end
            case 'No'
                doneManual = 1;
        end
    end
    end
    matchedBaseCells = allClosestCells(inRangeIndicesCells);
    
    foundTwice = intersect(inRangeIndicesCells,unpairedRegCells);
    assigned = length(inRangeIndicesCells) + length(unpairedRegCells);
    if isempty(foundTwice) && assigned==numRegCells && max(matchedBaseCells) <= numBaseCells
        newCol = size(fullReg.sessionInds,2) + 1;
        %Assign matched cells' indices to corresponding base cells
        fullReg.sessionInds(matchedBaseCells, newCol) = inRangeIndicesCells;

        newInds = size(fullReg.sessionInds,1)+1;
        newInds = newInds:newInds+length(unpairedRegCells)-1;

        %Assign the unmatched cells as new entries
        fullReg.sessionInds(newInds, newCol) = unpairedRegCells;

        % ??? what is this for? Not working now, did it used to work?
        %fullReg.RegPairs{1,regsess} = [matchedBaseCells, inRangeIndicesCells];
        %fullReg.RegPairs{1,regsess} = [fullReg.RegPairs{1,regsess}; newInds unpairedRegCells];

        fullReg.centers(newInds, 1:2) = reg_shift_centers(unpairedRegCells,:);

        regOrientation = cellfun(@(x) regionprops(x,'Orientation'),...
            {regImage_shifted{1,unpairedRegCells}},'UniformOutput',false);
        fullReg.orientation(newInds,1) =...
            cell2mat(cellfun(@(x) x.Orientation, regOrientation, 'UniformOutput',false))';

        fullRegImage(1,newInds) = {regImage_shifted{1,unpairedRegCells}};
        fullRegROIavg(1,newInds) = {regAvg_shifted{1,unpairedRegCells}};

        try
            save(fullfile(base_path,'fullReg.mat'),'fullReg','-v7.3')
            save(fullfile(base_path,'fullRegImage.mat'),'fullRegImage','-v7.3')
            save(fullfile(base_path,'fullRegROIavg.mat'),'fullRegROIavg','-v7.3')
        catch
            keyboard
        end
    else
        disp('Something wrong with indexing, some kind of overlap')
        keyboard
    end

end
end

close(mixFig)

end