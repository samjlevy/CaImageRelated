function [base_cellCenters, reg_cellCenters, pairedInds] = manual_reg_SL(base_path, reg_paths)
%manual_reg sam alternations;
%needs as input paths for the mask data

%micronsToPix = 1.1;
%maxMicrons = 3;
%distanceThreshold = maxMicrons*micronsToPix;
distanceThreshold = 3;

colorList = [...
    0.8500    0.3250    0.0980;...   
    0.4940    0.1840    0.5560;...
    0.4660    0.6740    0.1880;...
    0.6350    0.0780    0.1840;...
         0    0.5000         0;...
    1.0000         0         0;...
    0.7500         0    0.7500;...
    0.2500    0.2500    0.2500;...
         1         0         1;...
         0         1         1;...
         0         1         0];
   
%Load stuff, set things up     
load(fullfile(base_path,'FinalOutput.mat'),'NeuronImage')
baseImage = NeuronImage;
base_allMask = create_AllICmask(baseImage);
base_cellCenters = getAllCellCenters(baseImage);

%for regSess = 1:length(reg_paths)

reg_path = reg_paths;%{regSess};

load(fullfile(reg_path,'FinalOutput.mat'),'NeuronImage','NeuronAvg')
regImage = NeuronImage;
reg_allMask = create_AllICmask(regImage);
reg_cellCenters = getAllCellCenters(regImage);

clear NeuronImage


pairedInds = [];
%Load existing paired inds
[indFile, indDir] = uigetfile(fullfile(reg_path,'\*.mat'),'Load an existing pairedInds?');
if any(indFile)
    load(fullfile(indDir,indFile),'pairedInds')
end
gotPts = size(pairedInds,1)+1;

numBaseCells = length(baseImage);
numRegCells = length(regImage);

%Make figures and find anchor points
baseFig = figure('name','Base Session Masks','position',...
    [100 100 size(base_allMask,2)*1.5 size(base_allMask,1)*1.5]);
p(1) = imagesc(base_allMask);
title('Base Session Masks')

regFig = figure('name','Reg Session Masks','position',...
    [100+size(base_allMask,2)*1.5 100 size(reg_allMask,2)*1.5 size(reg_allMask,1)*1.5]);
q(1) = imagesc(reg_allMask);
title('Reg Session Masks')

%gotPts = 1;
colorInd = 1;
stillLabeling = 1;
reallyDone = 1;
%skipPrompt = 0;

if any(pairedInds)
    for gp = 1:(gotPts-1)
        figure(baseFig);
        hold on
        p(gp+1) = plot(base_cellCenters(pairedInds(gp,1),1), base_cellCenters(pairedInds(gp,1),2),'*');
        p(gp+1).Color = colorList(colorInd,:); 

        figure(regFig);
        hold on
        q(gp+1) = plot(reg_cellCenters(pairedInds(gp,2),1), reg_cellCenters(pairedInds(gp,2),2),'*');
        q(gp+1).Color = colorList(colorInd,:);
        
        colorInd = colorInd + 1;
        if colorInd > size(colorList,1); colorInd = 1; end
    end
end

while reallyDone == 1

while stillLabeling == 1
    
    disp(['currently have ' num2str(size(pairedInds,1)) ' anchor cells'])
    
    if gotPts <= 5
        getAcell=1;
    else
        %if skipPrompt==0
        moreCells = questdlg('Pick more cells?','More cells','Yes','No','Remove','Yes');%'Redo last'
        switch moreCells
            case 'Yes'
                getAcell = 1;
            case 'No'
                getAcell = 0;
                stillLabeling = 0;
            case 'Remove'
                figure(baseFig);
                [xBase, yBase] = ginput(1);
                [baseBad, ~] = findclosest2D ( base_cellCenters(pairedInds(:,1),1), base_cellCenters(pairedInds(:,1),2), xBase, yBase);
                 
                figure(baseFig);
                plot(base_cellCenters(pairedInds(baseBad,1),1), base_cellCenters(pairedInds(baseBad,1),2),'*y');
                figure(regFig);
                plot(reg_cellCenters(pairedInds(baseBad,2),1), reg_cellCenters(pairedInds(baseBad,2),2),'*y');
                
                pairedInds(baseBad,:) = [];
                gotPts = size(pairedInds,1) + 1;
                getAcell=0;
                %{
            case 'Redo last'
                gotPts = gotPts - 1;
                
                figure(baseFig);
                plot(base_cellCenters(pairedInds(gotPts,1),1), base_cellCenters(pairedInds(gotPts,1),2),'*y');
                figure(regFig);
                plot(reg_cellCenters(pairedInds(gotPts,2),1), reg_cellCenters(pairedInds(gotPts,2),2),'*y');
                colorInd = colorInd - 1;
                
                pairedInds(gotPts,:) = []; %#ok<AGROW>
                getAcell = 1;
                %}
        end
        %end
    end
    %skipPrompt = 0;
    
    if getAcell==1
        figure(baseFig);
        [xBase, yBase] = ginput(1);
        [baseCell, ~] = findclosest2D ( base_cellCenters(:,1), base_cellCenters(:,2), xBase, yBase);
        hold on
        p(gotPts+1) = plot(base_cellCenters(baseCell,1), base_cellCenters(baseCell,2),'*');
        p(gotPts+1).Color = colorList(colorInd,:);

        figure(regFig);
        [xReg, yReg] = ginput(1);
        [regCell, ~] = findclosest2D ( reg_cellCenters(:,1), reg_cellCenters(:,2), xReg, yReg);
        hold on
        q(gotPts+1) = plot(reg_cellCenters(regCell,1), reg_cellCenters(regCell,2),'*');
        q(gotPts+1).Color = colorList(colorInd,:);

        pairedInds(gotPts,1:2) = [baseCell, regCell]; %#ok<AGROW>
        gotPts = gotPts + 1;
        colorInd = colorInd + 1;
        if colorInd > size(colorList,1); colorInd = 1; end
    end
    
end

base_picked_centers = [base_cellCenters(pairedInds(:,1),1) base_cellCenters(pairedInds(:,1),2)];
reg_picked_centers = [reg_cellCenters(pairedInds(:,2),1) reg_cellCenters(pairedInds(:,2),2)];

%fitgeotrans
moreCells = questdlg('Alignment method?','Type','Affine','Projective','Polynomial','Affine');
switch moreCells
    case 'Affine'
        tform = fitgeotrans(reg_picked_centers,base_picked_centers,'affine');
    case 'Projective'
        tform = fitgeotrans(reg_picked_centers,base_picked_centers,'projective');
    case 'Polynomial'
        if size(pairedInds,1) >= 15
            tform = fitgeotrans(reg_picked_centers,base_picked_centers,'polynomial',4);
        else
            disp('need more points (15), using affine')
            tform = fitgeotrans(reg_picked_centers,base_picked_centers,'affine');
        end
end

%shift masks
RA = imref2d(size(base_allMask));
[regImage_shifted,~] = ...
    cellfun(@(x) imwarp(x,tform,'OutputView',RA,'InterpolationMethod','nearest'),regImage,'UniformOutput',false);
reg_allMask_shifted = create_AllICmask(regImage_shifted);

reg_shift_centers = getAllCellCenters(regImage_shifted);

%find closest: closestCell is baseCell index for each reg cell
[closestCell, distance] = findclosest2D ( base_cellCenters(:,1), base_cellCenters(:,2),...
                reg_shift_centers(:,1), reg_shift_centers(:,2));

%check effectiveness
worked = zeros(1,size(pairedInds,1));
for chCell = 1:size(pairedInds,1)
    %Does closest cell match paired Inds cells?
    worked(chCell) = closestCell(pairedInds(chCell,2)) == pairedInds(chCell,1);
end

if sum(worked)==length(worked)
    %we're good
else 
    disp(['only ' num2str(sum(worked)) ' out of ' num2str(length(worked)) ' anchor cells matched'])
end

[overlay,overlayRef] = imfuse(base_allMask,reg_allMask_shifted,'ColorChannels',[1 2 0]);
if exist('mixFig','var'); delete(mixFig); clear('mixFig'); end
mixFig = figure; imshow(overlay,overlayRef)
title(['Base (red) and reg (green) shifted overlay, ' num2str(sum(distance<distanceThreshold)) ' cell centers < 3um'])
hold on
plot(reg_shift_centers(distance<distanceThreshold,1),reg_shift_centers(distance<distanceThreshold,2),'*r')

%ask if add more points
moreCells = questdlg('Done picking cells?','Done cells','Done','No','Done');
switch moreCells
    case 'No'
        %getAcell = 1;
        stillLabeling = 1;
        %skipPrompt = 0;
        %close(mixFig)
    case 'Done'
        getAcell = 0;
        stillLabeling = 0;
        reallyDone = 0;
end

end

[ROIavg] = MakeAvgROI(regImage,NeuronAvg);
[regAvg_shifted,~] = ...
    cellfun(@(x) imwarp(x,tform,'OutputView',RA,'InterpolationMethod','nearest'),ROIavg,'UniformOutput',false);

save(fullfile(reg_path,'RegisteredImageSL2.mat'),'regImage_shifted','reg_shift_centers','regAvg_shifted','pairedInds')

close(baseFig)
close(regFig)
%end

end