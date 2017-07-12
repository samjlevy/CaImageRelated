function [base_cellCenters, reg_cellCenters, pairedInds] = manual_reg_SL(base_path, reg_path)
%manual_reg sam alternations;
%needs as input paths for the mask data

micronsToPix = 1.1;
maxMicrons = 3;
distanceThreshold = maxMicrons*micronsToPix;


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

load(fullfile(reg_path,'FinalOutput.mat'),'NeuronImage')
regImage = NeuronImage;
reg_allMask = create_AllICmask(regImage);
reg_cellCenters = getAllCellCenters(regImage);

clear NeuronImage

%Make figures and find anchor points
baseFig = figure('name','Base Session Masks','position',...
    [100 100 size(base_allMask,2)*1.5 size(base_allMask,1)*1.5]);
p(1) = imagesc(base_allMask);
title('Base Session Masks')

regFig = figure('name','Reg Session Masks','position',...
    [100+size(base_allMask,2)*1.5 100 size(reg_allMask,2)*1.5 size(reg_allMask,1)*1.5]);
q(1) = imagesc(reg_allMask);
title('Reg Session Masks')

gotPts = 1;
colorInd = 1;
stillLabeling = 1;
while stillLabeling == 1
    
    if gotPts == 1
        getAcell=1;
    else
        moreCells = questdlg('Pick more cells?','More cells','Yes','No','Redo last','Yes');
        switch moreCells
            case 'Yes'
                getAcell = 1;
            case 'No'
                getAcell = 0;
                stillLabeling = 0;
            case 'Redo last'
                gotPts = gotPts - 1;
                
                figure(baseFig);
                plot(base_cellCenters(pairedInds(gotPts,1),1), base_cellCenters(pairedInds(gotPts,1),2),'*y');
                figure(regFig);
                plot(reg_cellCenters(pairedInds(gotPts,2),1), reg_cellCenters(pairedInds(gotPts,2),2),'*y');
                colorInd = colorInd - 1;
                
                pairedInds(gotPts,1:2) = []; %#ok<AGROW>
                getAcell = 1;
        end
    end
    
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

%Find how to get from one set to the other
base_picked_centers = [base_cellCenters(pairedInds(:,1),1) base_cellCenters(pairedInds(:,1),2)];
reg_picked_centers = [reg_cellCenters(pairedInds(:,2),1) reg_cellCenters(pairedInds(:,2),2)];

tform = fitgeotrans(reg_picked_centers,base_picked_centers,'projective');%'affine'
tform2 = fitgeotrans(reg_picked_centers,base_picked_centers,'affine');

regImage_shifted = cell(1,length(regImage));
regShiftRef = cell(1,length(regImage));
for regCell = 1:length(regImage)
    [regImage_shifted{1,regCell}, regShiftRef{1,regCell}] =...
        imwarp(regImage{1,regCell}, tform);
end

reg_allMask_shifted = create_AllICmask(regImage_shifted);
reg_cellCenters_shifted = getAllCellCenters(regImage_shifted);
adjust = -1*[regShiftRef{1,1}.XWorldLimits(1), regShiftRef{1,1}.YWorldLimits(1)];
reg_cellCenters_shifted = reg_cellCenters_shifted - adjust;

[ closestCell, distance ] = findclosest2D ( base_cellCenters(:,1), base_cellCenters(:,2),...
                reg_cellCenters_shifted(:,1), reg_cellCenters_shifted(:,2));
            


worked = zeros(1,size(pairedInds,1));
for chCell = 1:size(pairedInds,1)
    %Does closest cell match paired Inds cells?
    worked(chCell) = closestCell(pairedInds(chCell,2)) == pairedInds(chCell,1);
end

if sum(worked)==length(worked)
    %we're good
else 
    %something broke
    %redo anchor cells?
end

%show figure of how well we did, offer to add points to make it better


[C,ia,ic] = unique(closestCell(distance < distanceThreshold));
%check index to closest cell (ia?) to find instances of base cell with too
%many matches


T = affine2d(tform.T);
T = projective2d(tform.T);
[reg_shift_alt(:,1),reg_shift_alt(:,2)] = transformPointsForward(T,reg_cellCenters(:,1),reg_cellCenters(:,2));



RA = imref2d(size(base_allMask));
[overlay,overlayRef] = imfuse(base_allMask,RA,reg_allMask_shifted,shiftRef,'ColorChannels',[1 2 0]);
figure; imshow(overlay,overlayRef)
title(['Base and reg shifted overlay, ' num2str(sum(distance<distanceThreshold)) ' cell centers < 3um'])
hold on
plot(reg_cellCenters_shifted(distance<distanceThreshold,1),...
        reg_cellCenters_shifted(distance<distanceThreshold,2),'*r')










end