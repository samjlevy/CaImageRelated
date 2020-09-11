matchCells(base_path, reg_paths, bufferEdges)
%bufferEdges should be used when there are cell masks out near the edges of
%the imaging window. During alignment, they can be pushed out of view,
%which can cause problems leading to those cells' not being registered. 

%regImageUse = 'RegisteredImageSL.mat';
regImageUse = 'RegisteredImageSL2.mat';
%regImageBufferUse = 'RegisteredImageSLbuffered.mat';
regImageBufferUse = 'RegisteredImageSLbuffered2.mat';

if (size(reg_paths,1) == 1) && ~iscell(reg_paths); reg_paths = {reg_paths}; end
    
if ~exist('bufferEdges','var'); bufferEdges = 0; end
try
    load(fullfile(reg_paths{1},regImageBufferUse),'bufferWidth')
catch
    bufferWidth = 100; %could also load this 
    disp(['No bufferWidth found, using default ' num2str(bufferWidth) ])
end

screensize = get( groot, 'Screensize' );
Aspect = 900/700;
mixFigPos = [0 250 floor(screensize(3)/2) floor(screensize(3)/2)/Aspect];
regMixFigPos = [ceil(screensize(3)/2) 250 floor(screensize(3)/2) floor(screensize(3)/2)/Aspect];

distanceThreshold = 3;
numSessions = size(reg_paths,1);

%Initial setup, including verifying buffering
if exist(fullfile(base_path,'fullReg.mat'),'file') == 2
    load(fullfile(base_path,'fullReg.mat'))
    load(fullfile(base_path,'fullRegImage.mat'))
    load(fullfile(base_path,'fullRegROIavg.mat'))
    
else
    disp('no fullReg found, making and saving')
    load(fullfile(base_path,'FinalOutput.mat'),'NeuronImage','NeuronAvg')
    baseImage = NeuronImage;
    
    if bufferEdges == 1
        bufferedNeuronImage = AddCellMaskBuffer(baseImage, bufferWidth);
    end
    baseImage = bufferedNeuronImage;
        
    base_cellCenters = getAllCellCenters(baseImage);
    baseOrientation = cellfun(@(x) regionprops(x,'Orientation'), baseImage,'UniformOutput',false);
    
    fullReg.sessionInds = [1:length(baseImage)]'; %#ok<NBRAK>
    fullReg.BaseSession = base_path;
    fullReg.BufferedEdge(1) = 1;
    fullReg.RegSessions = {};
    fullReg.centers = base_cellCenters; 
    fullReg.orientation = cell2mat(cellfun(@(x) x.Orientation, baseOrientation, 'UniformOutput',false))';
    
    fullRegImage = baseImage;
    fullRegROIavg = MakeAvgROI(fullRegImage,NeuronAvg);
    %fullRegROIavg = AddCellMaskBuffer(fullRegROIavg(fixThese), bufferWidth);
    %fullRegROIavg = AddCellMaskBuffer(fullROIavg, bufferWidth);
    
    save(fullfile(base_path,'fullReg.mat'),'fullReg','-v7.3')
    save(fullfile(base_path,'fullRegImage.mat'),'fullRegImage','-v7.3')
    save(fullfile(base_path,'fullRegROIavg.mat'),'fullRegROIavg','-v7.3')
    disp('Made new fullReg')
end    

%Check that we've aready registered sessions to each other
for rs = 1:numSessions
    reg_path = reg_paths{rs};
    
    if ~exist(fullfile(reg_path,regImageUse),'file')
        disp(['did not find image registration data for ' reg_path])
        [~, ~, ~] = manual_reg_SL(base_path, reg_path);
    else 
        disp(['found registration for ' reg_path])
    end
end

%Should add something here to verify that every entry is buffered appropriately
regImageSizes = reshape(cell2mat(cellfun(@size,fullRegImage,'UniformOutput',false)),2,length(fullRegImage))';
if length(unique(regImageSizes(:,1))) ~= 1
    disp('whoa buddy')
    keyboard
end
if length(unique(regImageSizes(:,2))) ~= 1
    disp('whoa buddy')
    keyboard
end
ROIavgSizes = reshape(cell2mat(cellfun(@size,fullRegROIavg,'UniformOutput',false)),2,length(fullRegROIavg))';
if length(unique(ROIavgSizes(:,1))) ~= 1
    disp('whoa buddy')
    keyboard
end
if length(unique(ROIavgSizes(:,2))) ~= 1
    disp('whoa buddy')
    keyboard
end


for regsess = 1:numSessions
    reg_path = reg_paths{regsess};
    
    regEntry = size(fullReg.RegSessions,1);
    
    regtitlepts = strsplit(reg_path,'\'); 
    rgtps = strsplit(regtitlepts{end},'_');
    %regtitle = [rgtps{1} ' ' rgtps{2}];
    regtitle = [regtitlepts{end}(1:3) ' ' regtitlepts{end}(4:end)]; %Nix version
    
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
    fullReg.RegSessions{size(fullReg.RegSessions,1)+1,1} = reg_path;

    load(fullfile(reg_path,regImageUse))
    if bufferEdges == 1
        try
            load(fullfile(reg_path,regImageBufferUse))
        catch
            disp(['Failed to find buffered image for ' regtitle ', fixing now'])
            AddRegBuffer(fullRegImage, reg_path, bufferWidth)
            load(fullfile(reg_path,regImageBufferUse))
        end
    end
    
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
    
    inRangeIndicesCells = rinds(~isnan(closestCell)); %reg cells
    unpairedRegCells = rinds(isnan(closestCell));
    %length(inRangeIndicesCells) + length(unpairedRegCells) == numRegCells
    
    bref = ones(size(fullReg.centers,1),1);
    bref(allClosestCells(inRangeIndicesCells)) = 0;
    unmatchedBaseCells = find(bref);
        
    removed = [];
    matchRemoved = [];
    
    if any(unpairedRegCells) && any(unmatchedBaseCells)
    doneManual = 0;
    skipPrompt = 0;
    zoomedIn = 0;
    zoomCenterAdjust = [0 0];
    matchZoomedIn = 0;
    matchZoomCenterAdjust = [0 0];
    
    while doneManual == 0
        if exist('baseFig','var'); delete(baseFig); clear('baseFig'); end
        if exist('regFig','var'); delete(regFig); clear('regFig'); end
        
        %Show unmatched cells
        baseUnpaired = create_AllICmask(fullRegImage(unmatchedBaseCells));
        regUnpaired = create_AllICmask(regImage_shifted(unpairedRegCells));
        if exist('mixFig','var'); delete(mixFig); clear('mixFig'); end
        [overlay,overlayRef] = imfuse(baseUnpaired,regUnpaired,'ColorChannels',[1 2 0]);
        mixFig = figure; imshow(overlay,overlayRef);
        mixFig.Position = mixFigPos;
        title(['UPAIRED base (red) and reg (green) unpaired cells; ' num2str(length(unpairedRegCells))...
            'UNPAIRED reg cell centers at ' num2str(distanceThreshold) 'um'])
        %mixFig = plotMixFig(baseUnpaired, regUnpaired, unpairedRegCells, distanceThreshold);
        mixFigChildPos = mixFig.Children.Position;
        vertLines = 150:150:size(overlay,2); horizLines = 150:150:size(overlay,1);
        hold on
        for vl = 1:length(vertLines); plot([vertLines(vl) vertLines(vl)], [0 size(overlay,1)],'w'); end
        for hl = 1:length(horizLines); plot([0 size(overlay,2)], [horizLines(hl) horizLines(hl)],'w'); end
        hold off
        
        %Show matched cells
        %basePaired = create_AllICmask(fullRegImage(fullReg.sessionInds(matchedHere,1)));
        basePaired = create_AllICmask(fullRegImage);
        regPaired = create_AllICmask(regImage_shifted(inRangeIndicesCells));
        if exist('regMixFig','var'); delete(regMixFig); clear('regMixFig'); end
        matchedBaseCells = allClosestCells(inRangeIndicesCells);
        numMatchedHere = length(matchedBaseCells);
        [regOverlay,regOverlayRef] = imfuse(basePaired,regPaired,'ColorChannels',[1 2 0]);
        regMixFig = figure; imshow(regOverlay,regOverlayRef);
        hold on
        plot(fullReg.centers(matchedBaseCells,1),fullReg.centers(matchedBaseCells,2),'*m')
        regMixFig.Position = regMixFigPos;
        title(['PAIRED base and reg cells; ' num2str(length(numMatchedHere))...
            ' registered cell centers at ' num2str(distanceThreshold) 'um'])
        %regMixFig = plotRegMixFig(basePaired, regPaired, fullReg, matchedBaseCells, distanceThreshold);
        regMixFigChildPos = regMixFig.Children.Position;
        rvertLines = 150:150:size(regOverlay,2); rhorizLines = 150:150:size(regOverlay,1);
        hold on
        for rvl = 1:length(rvertLines); plot([rvertLines(rvl) rvertLines(rvl)], [0 size(regOverlay,1)],'w'); end
        for rhl = 1:length(rhorizLines); plot([0 size(regOverlay,2)], [rhorizLines(rhl) rhorizLines(rhl)],'w'); end
        hold off
        
        %Offer editing
        workWith = questdlg('Want to edit registration?','Edit registration','Unpaired','Paired','Done','Done');
        switch workWith
            case 'Unpaired'
                didSomething = 0;
                while didSomething==0 
                    if skipPrompt==0 
                        %forceAssign = questdlg('Want to force assignments?','Force assign','Yes','No','No'); 
                        forceAssign = questdlg('Want to force assignments?','Force assign','Yes','Zoom/Unzoom','Back','Back'); 
                    end
                switch forceAssign
                    case 'Zoom/Unzoom'
                        figure(mixFig);
                        switch zoomedIn
                            case 1 %Set to original
                                zoomedIn = 0;
                                zoomCenterAdjust = [0 0];

                                zoomBot = size(overlay,1);
                                zoomTop = 1;
                                zoomLeft = 1;
                                zoomRight = size(overlay,2);

                                hold off
                                imshow(overlay,overlayRef);
                                mixFig.Position = mixFigPos; 
                                vertLines = 150:150:size(overlay,2); horizLines = 150:150:size(overlay,1);
                                hold on
                                for vl = 1:length(vertLines); plot([vertLines(vl) vertLines(vl)], [0 size(overlay,1)],'w'); end
                                for hl = 1:length(horizLines); plot([0 size(overlay,2)], [horizLines(hl) horizLines(hl)],'w'); end
                                hold off
                                
                            case 0 %Get "zoom" area
                                [zx, zy] = ginput(1); zx = round(zx); zy = round(zy);
                                zoomRange = 100;
                                zx = min([max([zx zoomRange+1]) (size(overlay,2)-zoomRange)]);
                                zy = min([max([zy zoomRange+1]) (size(overlay,1)-zoomRange)]);
                                zoomBot = zy + zoomRange - 1; %zoomBot = min([zy+zoomRange-1 size(overlay,1)]);
                                zoomTop = zy - zoomRange; %zoomTop = max([zy-zoomRange 1]);
                                zoomLeft = zx - zoomRange; %zoomLeft = max([zx-zoomRange 1]);
                                zoomRight = zx + zoomRange - 1; %zoomRight = min([zx+zoomRange-1 size(overlay,2)]);

                                zoomCenterAdjust = [zoomLeft zoomTop] - 1; %Not sure about this -1, may now matter since should only affect plotting

                                zoomRows = zoomTop:zoomBot; zoomCols = zoomLeft:zoomRight;
                                [zoomOverlay,zoomOverlayRef] = imfuse(baseUnpaired(zoomRows, zoomCols),regUnpaired(zoomRows, zoomCols),'ColorChannels',[1 2 0]);
                                imshow(zoomOverlay,zoomOverlayRef);
                                mixFig.Position = mixFigPos; 
                                %mixFig.Children.Position = mixFigChildPos;
                                %Plot cell outlines
                                zoomCentersBase = find(inpolygon(fullReg.centers(unmatchedBaseCells,1),fullReg.centers(unmatchedBaseCells,2),...
                                    [zoomLeft; zoomLeft; zoomRight; zoomRight],[zoomTop; zoomBot; zoomBot; zoomTop]));
                                zoomCentersReg = find(inpolygon(reg_shift_centers(unpairedRegCells,1),reg_shift_centers(unpairedRegCells,2),...
                                    [zoomLeft; zoomLeft; zoomRight; zoomRight],[zoomTop; zoomBot; zoomBot; zoomTop]));

                                for zcbI = 1:length(zoomCentersBase)
                                    bw = bwboundaries(fullRegImage{unmatchedBaseCells(zoomCentersBase(zcbI))}); bww = bw{1};
                                    hold on
                                    plot(bww(:,2)-zoomCenterAdjust(1),bww(:,1)-zoomCenterAdjust(2),'c','LineWidth',2)
                                end
                                for zcrI = 1:length(zoomCentersReg)
                                    bw = bwboundaries(regImage_shifted{unpairedRegCells(zoomCentersReg(zcrI))}); bww = bw{1};
                                    hold on
                                    plot(bww(:,2)-zoomCenterAdjust(1),bww(:,1)-zoomCenterAdjust(2),'m','LineWidth',2)
                                end

                                zoomedIn = 1;
                        end %zoom

                        didSomething = 0;
                    case 'Yes'
                        if zoomedIn == 1; zoomCoords = [zoomLeft zoomLeft zoomRight zoomRight zoomLeft; zoomTop zoomBot zoomBot zoomTop zoomTop];end
                        
                        %Get pair of cells to force like in manual_reg_SL
                        baseFig = figure('name','Base Session Masks');
                        %baseFig.Position = [100, 100, size(baseUnpaired,2)*1.5, size(baseUnpaired,1)*1.5]);
                        baseFig.Position = mixFigPos;
                        hold off; imagesc(baseUnpaired); title('Base Session Masks')
                        if zoomedIn==1; hold on; plot(zoomCoords(1,:),zoomCoords(2,:),'r'); hold off; end
                        bvertLines = 150:150:size(baseUnpaired,2); bhorizLines = 150:150:size(baseUnpaired,1);
                        hold on
                        for bvl = 1:length(bvertLines); plot([bvertLines(bvl) bvertLines(bvl)], [0 size(baseUnpaired,1)],'w'); end
                        for bhl = 1:length(bhorizLines); plot([0 size(baseUnpaired,2)], [bhorizLines(bhl) bhorizLines(bhl)],'w'); end
                        hold off
                        
                        regFig = figure('name','Reg Session Masks');
                        %regFig.Position = [100+size(baseUnpaired,2)*1.5 100 size(regUnpaired,2)*1.5 size(regUnpaired,1)*1.5]);
                        regFig.Position = regMixFigPos;
                        hold off; imagesc(regUnpaired); title(['Reg Session Masks for ' regtitle])
                        if zoomedIn==1; hold on; plot(zoomCoords(1,:),zoomCoords(2,:),'r'); hold off; end
                        cvertLines = 150:150:size(regUnpaired,2); chorizLines = 150:150:size(regUnpaired,1);
                        hold on
                        for cvl = 1:length(cvertLines); plot([cvertLines(cvl) cvertLines(cvl)], [0 size(regUnpaired,1)],'w'); end
                        for chl = 1:length(chorizLines); plot([0 size(regUnpaired,2)], [chorizLines(chl) chorizLines(chl)],'w'); end
                        hold off
                        
                        figure(baseFig);
                        [xBase, yBase] = ginput(1);
                        %xBase = xBase + zoomCenterAdjust(1); yBase = yBase + zoomCenterAdjust(2);
                        [baseCell, ~] = findclosest2D(fullReg.centers(unmatchedBaseCells,1),...
                            fullReg.centers(unmatchedBaseCells,2), xBase, yBase);
                        matchingBaseCell = unmatchedBaseCells(baseCell); %baseCell indexes into unmatchedBaseCells
                        hold on
                        plot(fullReg.centers(matchingBaseCell,1), fullReg.centers(matchingBaseCell,2),'*r');

                        figure(regFig);
                        [xReg, yReg] = ginput(1);
                        %xReg = xReg + zoomCenterAdjust(1); yReg = yReg + zoomCenterAdjust(2);
                        [regCell, ~] = findclosest2D(reg_shift_centers(unpairedRegCells,1),...
                            reg_shift_centers(unpairedRegCells,2), xReg, yReg);
                        matchingRegCell = unpairedRegCells(regCell);
                        hold on
                        plot(reg_shift_centers(matchingRegCell,1), reg_shift_centers(matchingRegCell,2),'*r');

                        %Add this to our matched list
                        inRangeIndicesCells = [inRangeIndicesCells matchingRegCell];
                        unpairedRegCells(regCell) = [];
                        unmatchedBaseCells(baseCell) = [];
                                
                        %Re-plot figures
                        figure(mixFig);
                        zoomedIn = 0; %Forcing unzoom, too complicated
                        hold off
                        imshow(overlay,overlayRef);
                        hold on
                        plot(fullReg.centers(matchingBaseCell,1),fullReg.centers(matchingBaseCell,2),'*c'); 
                        plot(reg_shift_centers(matchingRegCell,1),reg_shift_centers(matchingRegCell,2),'*m');
                        
                        figure(regMixFig); 
                        %basePaired = create_AllICmask(fullRegImage);
                        regPaired = create_AllICmask(regImage_shifted(inRangeIndicesCells));
                        matchedBaseCells = allClosestCells(inRangeIndicesCells);
                        numMatchedHere = length(matchedBaseCells);
                        [regOverlay,regOverlayRef] = imfuse(basePaired,regPaired,'ColorChannels',[1 2 0]);
                        imshow(regOverlay,regOverlayRef);
                        hold on
                        plot(fullReg.centers(matchedBaseCells,1),fullReg.centers(matchedBaseCells,2),'*m') 
                        plot(fullReg.centers(matchedBaseCells(end),1),fullReg.centers(matchedBaseCells(end),2),'*g')
                        title(['PAIRED base and reg cells; ' num2str(length(numMatchedHere))...
                            ' registered cell centers at ' num2str(distanceThreshold) 'um'])
                        
                        %Ask if this was an ok match
                        doneManual = 0;
                        manGood = questdlg('Was this good?','Was this good','Yes','No','Yes');
                        switch manGood
                            case 'Yes'
                                removed(size(removed,1)+1,1:2) = [matchingBaseCell matchingRegCell];
                                %inRangeIndicesCells = [inRangeIndicesCells unpairedRegCells(regCell)];
                                %unpairedRegCells(regCell) = [];
                                %unmatchedBaseCells(baseCell) = [];
                                skipPrompt=0;
                            case 'No'
                                %Need to add those cells back to our list of unmatched
                                inRangeIndicesCells(end) = [];
                                unpairedRegCells = [unpairedRegCells matchingRegCell];
                                unmatchedBaseCells = [unmatchedBaseCells; matchingBaseCell];
                                %removed(size(removed,1),1:2) = [];
                                skipPrompt=0;
                        end
                        
                        didSomething = 1;

                        %Maybe don't replot, will get replotted on loop
                        figure(mixFig);
                        hold off
                        imshow(overlay,overlayRef);
                        
                        figure(regMixFig); 
                        basePaired = create_AllICmask(fullRegImage);
                        regPaired = create_AllICmask(regImage_shifted(inRangeIndicesCells));
                        matchedBaseCells = allClosestCells(inRangeIndicesCells);
                        numMatchedHere = length(matchedBaseCells);
                        [regOverlay,regOverlayRef] = imfuse(basePaired,regPaired,'ColorChannels',[1 2 0]);
                        imshow(regOverlay,regOverlayRef);
                        hold on
                        plot(fullReg.centers(matchedBaseCells,1),fullReg.centers(matchedBaseCells,2),'*m')
                        title(['PAIRED base and reg cells; ' num2str(numMatchedHere)...
                            ' registered cell centers at ' num2str(distanceThreshold) 'um'])
                        
                        %May not even need this code anymore...
                        %{
                        if any(removed)
                            undoForce = questdlg('Undo last match?','Undo last','No','Yes','No');
                            if strcmpi(undoForce,'Yes')
                                disp('Sorry not implemented yet')
                                %code here to undo the last removal, this backwards
                                %could even show all removed silhouettes...
                                %{
                        removed(size(removed,1)+1,1:2) = [unmatchedBaseCells(baseCell) unpairedRegCells(regCell)];
                                %Move those cells appropriately
                                inRangeIndicesCells = [inRangeIndicesCells unpairedRegCells(regCell)];
                                unpairedRegCells(regCell) = [];
                                unmatchedBaseCells(baseCell) = [];
                                %}
                            end
                        end
                            %}
                    case 'Back'
                        zoomedIn = 0;
                        didSomething = 1;
                end %forceAssign/zoom
                end %didSomething
            
            case 'Paired'
                matchDidSomething = 0;
                while matchDidSomething == 0
                regEdit= questdlg('Edit matched cells?','Edit registration','Remove','Zoom/Unzoom','Back','Back');
                switch regEdit
                    case 'Remove'
                        %Get the bad pair
                        figure(regMixFig);
                        [xMatch, yMatch] = ginput(1);
                        xMatch = xMatch + matchZoomCenterAdjust(1); yMatch = yMatch + matchZoomCenterAdjust(2);
                        [matchCell, ~] = findclosest2D(fullReg.centers(matchedBaseCells,1), fullReg.centers(matchedBaseCells,2), xMatch, yMatch);
                        baseMatchCell = matchedBaseCells(matchCell);
                        regMatchCell = inRangeIndicesCells(matchCell);
                        hold on
                        plot(fullReg.centers(baseMatchCell,1), fullReg.centers(baseMatchCell,2),'*c');
                        plot(reg_shift_centers(regMatchCell,1), reg_shift_centers(regMatchCell,2),'*c');
                        
                        %Update matching/unmatching
                        unpairedRegCells = [unpairedRegCells regMatchCell];
                        unmatchedBaseCells = [unmatchedBaseCells; baseMatchCell];
                        inRangeIndicesCells(matchCell) = [];
                        matchedBaseCells = allClosestCells(inRangeIndicesCells);
                        
                        matchRemoved(size(matchRemoved,1)+1,1:2) = [baseMatchCell regMatchCell];
                        
                        %Show unmatched cells
                        baseUnpaired = create_AllICmask(fullRegImage(unmatchedBaseCells));
                        regUnpaired = create_AllICmask(regImage_shifted(unpairedRegCells));
                        if exist('mixFig','var'); delete(mixFig); clear('mixFig'); end
                        [overlay,overlayRef] = imfuse(baseUnpaired,regUnpaired,'ColorChannels',[1 2 0]);
                        mixFig = figure; imshow(overlay,overlayRef);
                        %mixFig.Position = mixFigChildPos;
                        title(['UPAIRED base (red) and reg (green) unpaired cells; ' num2str(length(unpairedRegCells))...
                            'UNPAIRED reg cell centers at ' num2str(distanceThreshold) 'um'])
                        
                        %Show matched cells
                        basePaired = create_AllICmask(fullRegImage);
                        regPaired = create_AllICmask(regImage_shifted(inRangeIndicesCells));
                        if exist('regMixFig','var'); delete(regMixFig); clear('regMixFig'); end
                        matchedBaseCells = allClosestCells(inRangeIndicesCells);
                        numMatchedHere = length(matchedBaseCells);
                        [regOverlay,regOverlayRef] = imfuse(basePaired,regPaired,'ColorChannels',[1 2 0]);
                        regMixFig = figure; imshow(regOverlay,regOverlayRef);
                        hold on
                        plot(fullReg.centers(matchedBaseCells,1),fullReg.centers(matchedBaseCells,2),'*m')
                        regMixFig.Position = regMixFigPos;
                        title(['PAIRED base and reg cells; ' num2str(numMatchedHere)...
                            ' registered cell centers at ' num2str(distanceThreshold) 'um'])
                        
                        mmanGood = questdlg('Was this good?','Was this good','Yes','No','Yes');
                        switch mmanGood
                            case 'Yes'
                                skipPrompt=0;
                            case 'No'
                                %Need to add those cells back to our list of unmatched
                                unpairedRegCells(end) = [];
                                unmatchedBaseCells(end) = [];
                                inRangeIndicesCells = [inRangeIndicesCells matchRemoved(size(matchRemoved,1),2)];
                                
                                matchedBaseCells = allClosestCells(inRangeIndicesCells);
                                
                                removed(size(removed,1),1:2) = [];
                                skipPrompt=0;
                        end
                        
                        matchDidSomething = 1; 
                    case 'Zoom/Unzoom'
                        switch matchZoomedIn
                            case 1 %Set to original
                                matchZoomedIn = 0;
                                matchZoomCenterAdjust = [0 0];

                                matchzoomBot = size(regOverlay,1);
                                matchzoomTop = 1;
                                matchzoomLeft = 1;
                                matchzoomRight = size(regOverlay,2);

                                hold off
                                imshow(regOverlay,regOverlayRef);
                                regMixFig.Position = regMixFigPos; 
                            case 0 %Get "zoom" area
                                [mzx, mzy] = ginput(1); mzx = round(mzx); mzy = round(mzy);
                                matchzoomRange = 100;
                                mzx = min([max([mzx matchzoomRange+1]) (size(overlay,2)-matchzoomRange)]);
                                mzy = min([max([mzy matchzoomRange+1]) (size(overlay,1)-matchzoomRange)]);
                                matchzoomBot = mzy + matchzoomRange - 1;
                                matchzoomTop = mzy - matchzoomRange;
                                matchzoomLeft = mzx - matchzoomRange;
                                matchzoomRight = mzx + matchzoomRange - 1;
                                
                                matchZoomCenterAdjust = [matchzoomLeft matchzoomTop] - 1; %Not sure about this -1, may now matter since should only affect plotting
                                
                                matchzoomRows = matchzoomTop:matchzoomBot; matchzoomCols = matchzoomLeft:matchzoomRight;
                                
                                [matchzoomOverlay,matchzoomOverlayRef] = imfuse(basePaired(matchzoomRows, matchzoomCols),...
                                    regPaired(matchzoomRows, matchzoomCols),'ColorChannels',[1 2 0]);
                                imshow(matchzoomOverlay,matchzoomOverlayRef);
                                regMixFig.Position = regMixFigPos;
                                
                                %Plot cell outlines
                                matchzoomCentersBase = find(inpolygon(fullReg.centers(matchedBaseCells,1),fullReg.centers(matchedBaseCells,2),...
                                    [matchzoomLeft; matchzoomLeft; matchzoomRight; matchzoomRight],...
                                    [matchzoomTop; matchzoomBot; matchzoomBot; matchzoomTop]));
                                matchzoomCentersReg = find(inpolygon(reg_shift_centers(inRangeIndicesCells,1),reg_shift_centers(inRangeIndicesCells,2),...
                                    [matchzoomLeft; matchzoomLeft; matchzoomRight; matchzoomRight],...
                                    [matchzoomTop; matchzoomBot; matchzoomBot; matchzoomTop]));
                                
                                for mzcbI = 1:length(matchzoomCentersBase)
                                    bw = bwboundaries(fullRegImage{matchedBaseCells(matchzoomCentersBase(mzcbI))}); bww = bw{1};
                                    hold on
                                    plot(bww(:,2)-matchZoomCenterAdjust(1),bww(:,1)-matchZoomCenterAdjust(2),'c','LineWidth',2)
                                end
                                for mzcrI = 1:length(matchzoomCentersReg)
                                    bw = bwboundaries(regImage_shifted{inRangeIndicesCells(matchzoomCentersReg(mzcrI))}); bww = bw{1};
                                    hold on
                                    plot(bww(:,2)-matchZoomCenterAdjust(1),bww(:,1)-matchZoomCenterAdjust(2),'m','LineWidth',2)
                                end
                                
                                matchZoomedIn = 1;
                        end
                        matchDidSomething = 0;
                    case 'Back'
                        matchZoomedIn = 0;
                        matchDidSomething = 1;
                end
                end
                
            case 'Done' %Don't edit registration
                doneManual = 1; 
        end %work with (paired or unpaired)
    end %doneManual
    
    end %any unpaired/unmatched
    
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

        for ts = 1:length(unpairedRegCells)
            regOrientation = regionprops(regImage_shifted{1,unpairedRegCells(ts)},'Orientation');
            fullReg.orientation(newInds(ts),1) = regOrientation.Orientation;
        end
        %regOrientation = cellfun(@(x) regionprops(x,'Orientation'),...
        %    {regImage_shifted{1,unpairedRegCells}},'UniformOutput',false);
        %fullReg.orientation(newInds,1) =...
        %    cell2mat(cellfun(@(x) x.Orientation, regOrientation, 'UniformOutput',false))'; %Why doesn't this work anymore?
        

        fullRegImage(1,newInds) = {regImage_shifted{1,unpairedRegCells}};
        fullRegROIavg(1,newInds) = {regAvg_shifted{1,unpairedRegCells}};

        try
            save(fullfile(base_path,'fullReg.mat'),'fullReg','-v7.3')
            save(fullfile(base_path,'fullRegImage.mat'),'fullRegImage','-v7.3')
            save(fullfile(base_path,'fullRegROIavg.mat'),'fullRegROIavg','-v7.3')
            disp('worked, saved')
        catch
            keyboard
        end
    else
        disp('Something wrong with indexing, some kind of overlap')
        keyboard
    end

    end
end

try; close(mixFig); end %#ok<TRYNC,NOSEM>
try; close(regMixFig); end %#ok<TRYNC,NOSEM>

end
%{
function mixFig = plotMixFig(baseUnpaired, regUnpaired, unpairedRegCells, distanceThreshold)

[overlay,overlayRef] = imfuse(baseUnpaired,regUnpaired,'ColorChannels',[1 2 0]);
mixFig = figure; imshow(overlay,overlayRef);
mixFig.Position = [50 250 900 700];
title(['UPAIRED base (red) and reg (green) unpaired cells; ' num2str(length(unpairedRegCells))...
    'UNPAIRED reg cell centers at ' num2str(distanceThreshold) 'um'])

end
function regMixFig = plotRegMixFig( basePaired, regPaired, fullReg, matchedBaseCells)
        
matchedHere = length(matchedBaseCells);
[regOverlay,regOverlayRef] = imfuse(basePaired,regPaired,'ColorChannels',[1 2 0]);
regMixFig = figure; imshow(regOverlay,regOverlayRef);
hold on
plot(fullReg.centers(matchedBaseCells,1),fullReg.centers(matchedBaseCells,2),'*m')
regMixFig.Position = [900 250 900 700];
title(['PAIRED base and reg cells; ' num2str(length(matchedHere))...
    ' registered cell centers at ' num2str(distanceThreshold) 'um'])
end
%}