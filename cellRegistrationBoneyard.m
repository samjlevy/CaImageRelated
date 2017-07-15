

base_picked_centers = [base_cellCenters(pairedInds(:,1),1) base_cellCenters(pairedInds(:,1),2)];
reg_picked_centers = [reg_cellCenters(pairedInds(:,2),1) reg_cellCenters(pairedInds(:,2),2)];

tform = fitgeotrans(reg_picked_centers,base_picked_centers,'affine');%'projective'

[reg_allMask_shifted,shiftRef] = imwarp(reg_allMask, tform);%, 'Interp', 'nearest'

T = maketform('affine',tform.T);%'projective'
[reg_shift_cellCenters(:,1),reg_shift_cellCenters(:,2)] = tformfwd(T,reg_cellCenters(:,1),reg_cellCenters(:,2));


regImage_shifted = cell(1,length(regImage));
regImage_shifted2 = cell(1,length(regImage));
regShiftRef = cell(1,length(regImage));
for regCell = 1:length(regImage)
    [regImage_shifted{1,regCell}, regShiftRef{1,regCell}] =...
        imwarp(regImage{1,regCell}, tform);%, 'Interp', 'nearest'
    
    coords = -1*[round(regShiftRef{1,regCell}.XWorldLimits(1)), round(regShiftRef{1,regCell}.YWorldLimits(1))];
    regImage_shifted2{1,regCell} = regImage_shifted{1,regCell}(coords(2):end,coords(1):end);
end

reg_allMask_shifted2 = create_AllICmask(regImage_shifted2);

RA = imref2d(size(base_allMask));
[D,RD] = imfuse(base_allMask,RA,reg_allMask_shifted,shiftRef,'ColorChannels',[1 2 0]);
[D2,RD2] = imfuse(base_allMask,reg_allMask_shifted2,'ColorChannels',[1 2 0]);

figure; imshow(D,RD)
hold on
plot(base_picked_centers(:,1),base_picked_centers(:,2),'*c')

reg_cellCentersShifted = getAllCellCenters(regImage_shifted2);


figure; imshow(reg_allMask_shifted, shiftRef)
hold on
plot(X, Y, 'r*')
%}


baseCOM = mean(base_picked_centers,1);
regCOM = mean(reg_picked_centers,1);

xShift = regCOM(1) - baseCOM(1);
yShift = regCOM(2) - baseCOM(2);

reg_picked_shifted = reg_picked_centers - [xShift yShift];


%{
regImage_shifted_cropped = cell(1,numRegCells);
    rect = [-regShiftRef{1,regCell}.XWorldLimits(1) -regShiftRef{1,regCell}.YWorldLimits(1)...
        regShiftRef{1,regCell}.XWorldLimits(2)+regShiftRef{1,regCell}.XWorldLimits(1)...
        regShiftRef{1,regCell}.YWorldLimits(2)+regShiftRef{1,regCell}.YWorldLimits(1)];
    regImage_shifted_cropped2 = imcrop(regImage_shifted{1,regCell},rect); {1,regCell}
%}
%shift centers: remake from image vs. transform old point
T = projective2d(tform.T);%affine2d
[reg_shift_centers(:,1),reg_shift_centers(:,2)] =...
    transformPointsForward(T,reg_cellCenters(:,1),reg_cellCenters(:,2));
%reg_cellCenters_shifted = getAllCellCenters(regImage_shifted); 
%adjust = -1*[regShiftRef{1,1}.XWorldLimits(1), regShiftRef{1,1}.YWorldLimits(1)];
%reg_cellCenters_shifted = reg_cellCenters_shifted - adjust;

COMtranslation = [1 0 0; 0 1 0; -xShift -yShift 1];
tform = affine2d(COMtranslation);
[reg_allMask_shifted,shiftRef] = imwarp(reg_allMask,tform);

 figure; imshow(reg_allMask_shifted,shiftRef)
 
 
 
 
 Roriginal = imref2d(size(original));
 recovered = imwarp(distorted,tform,'OutputView',Roriginal);
 
 
 
 
