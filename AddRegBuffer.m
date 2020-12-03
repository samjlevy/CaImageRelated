function AddRegBuffer(baseImage, reg_path, bufferWidth)
%This program adds buffer space so registration runs safely

load(fullfile(reg_path,'RegisteredImageSL2.mat'),'pairedInds')
load(fullfile(reg_path,'FinalOutput.mat'),'NeuronImage','NeuronAvg')

bufferedRegImage = AddCellMaskBuffer(NeuronImage, bufferWidth);

base_cellCenters = getAllCellCenters(baseImage,false);
reg_cellCenters = getAllCellCenters(bufferedRegImage,false);

base_picked_centers = [base_cellCenters(pairedInds(:,1),1) base_cellCenters(pairedInds(:,1),2)]; %#ok<*IDISVAR,NODEF>
reg_picked_centers = [reg_cellCenters(pairedInds(:,2),1) reg_cellCenters(pairedInds(:,2),2)];

tform = fitgeotrans(reg_picked_centers,base_picked_centers,'affine');

base_allMask = create_AllICmask(baseImage);
RA = imref2d(size(base_allMask));
[regImage_shifted,~] = ...
    cellfun(@(x) imwarp(x,tform,'OutputView',RA,'InterpolationMethod','nearest'),...
    bufferedRegImage,'UniformOutput',false);
reg_allMask_shifted = create_AllICmask(regImage_shifted);
reg_shift_centers = getAllCellCenters(regImage_shifted,false);

%Doesn't seem to be working
[ROIavg] = MakeAvgROI(bufferedRegImage,NeuronAvg);
[regAvg_shifted,~] = ...
    cellfun(@(x) imwarp(x,tform,'OutputView',RA,'InterpolationMethod','nearest'),ROIavg,'UniformOutput',false);
save(fullfile(reg_path,'RegisteredImageSLbuffered2.mat'),'pairedInds',...
                                                        'reg_shift_centers',...
                                                        'regImage_shifted',...
                                                        'bufferWidth',...
                                                        'regAvg_shifted','-v7.3')

                                                    
end