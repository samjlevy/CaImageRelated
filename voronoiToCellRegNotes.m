% Saving out registration, use with CellReg


imPathA = 'C:\Users\samwi_000\Desktop\Pandora\180629\FinalOutput.mat';
imPathB = 'C:\Users\samwi_000\Desktop\Pandora\180630\FinalOutput.mat';

load(imPathA,'NeuronImage')
NeuronImageA = AddCellMaskBuffer(NeuronImage, 100);
load(imPathB,'NeuronImage')
NeuronImageB = AddCellMaskBuffer(NeuronImage, 100);


distanceThreshold = 3;
vorTierCheck = 3;
nBlocksX = 4;
nBlocksY = 4;
pctDownsample = 0;

tic
[outputs] = voronoiRegNotes2_8fun(NeuronImageA,NeuronImageB,distanceThreshold,vorTierCheck,nBlocksX,nBlocksY,pctDownsample);
% Second input is the one that gets transformed
toc

maxYs = cellfun(@(x) max(find(sum(x,2))),NeuronImageA);
minYs = cellfun(@(x) min(find(sum(x,2))),NeuronImageA);
maxXs = cellfun(@(x) max(find(sum(x,1))),NeuronImageA);
minXs = cellfun(@(x) min(find(sum(x,1))),NeuronImageA);

maxYsB = cellfun(@(x) max(find(sum(x,2))),outputs.regShiftedImages);
minYsB = cellfun(@(x) min(find(sum(x,2))),outputs.regShiftedImages);
maxXsB = cellfun(@(x) max(find(sum(x,1))),outputs.regShiftedImages);
minXsB = cellfun(@(x) min(find(sum(x,1))),outputs.regShiftedImages);

maxY = max([maxYs(:); maxYsB(:)]) + 10;
minY = min([minYs(:); minYsB(:)]) - 10;
maxX = max([maxXs(:); maxXsB(:)]) + 10;
minX = min([minXs(:); minXsB(:)]) -10;

dimX = maxX - minX +1;
dimY = maxY - minY +1;
numCells = length(NeuronImageA);

%dimX = size(NeuronImageA{1},1);
%dimY = size(NeuronImageA{1},2);

NeuronFootprint = zeros(numCells,dimY,dimX);
for cellI = 1:numCells
    %NeuronFootprint(cellI,:,:) = NeuronImageA{cellI};
    NeuronFootprint(cellI,:,:) = NeuronImageA{cellI}(minY:maxY,minX:maxX);
end
NeuronFootprint = single(NeuronFootprint);
save('NeuronFootprint180629.mat','NeuronFootprint','-v7.3')

numCells = length(outputs.regShiftedImages);
%dimX = size(outputs.regShiftedImages{1},1);
%dimY = size(outputs.regShiftedImages{1},2);

NeuronFootprint = zeros(numCells,dimY,dimX);
for cellI = 1:numCells
    NeuronFootprint(cellI,:,:) = outputs.regShiftedImages{cellI}(minY:maxY,minX:maxX);
end
NeuronFootprint = single(NeuronFootprint);
save('NeuronFootprint180630.mat','NeuronFootprint','-v7.3')

%%
distanceThreshold = 3;
vorTierCheck = 3;
nBlocksX = 4;
nBlocksY = 4;
pctDownsample = 0;

regFolder = 'F:\DoublePlus\Kerberos';
load(fullfile(regFolder,'fullReg.mat'));
bigSessions = fullReg.RegSessions(end-8:end);
regMethod = 'voronoi'; %'manual'

baseSession = bigSessions{3};
regSessions = bigSessions([1:2,4:9]);

imPathA = baseSession;
load(fullfile(imPathA,'FinalOutput.mat'),'NeuronImage')
NeuronImageA = AddCellMaskBuffer(NeuronImage, 100); clear NeuronImage
for regI = 5:8
    imPathB = regSessions{regI};
    
    switch regMethod
        case 'voronoi'
            load(fullfile(imPathB,'FinalOutput.mat'),'NeuronImage')
            NeuronImageB = AddCellMaskBuffer(NeuronImage, 100);
            
            tic
            [outputs] = voronoiRegNotes2_8fun(NeuronImageA,NeuronImageB,distanceThreshold,vorTierCheck,nBlocksX,nBlocksY,pctDownsample);
            % Second input is the one that gets transformed
            
            maxY(regI) = max(cellfun(@(x) max(find(sum(x,2))),outputs.regShiftedImages));
            minY(regI) = min(cellfun(@(x) min(find(sum(x,2))),outputs.regShiftedImages));
            maxX(regI) = max(cellfun(@(x) max(find(sum(x,1))),outputs.regShiftedImages));
            minX(regI) = min(cellfun(@(x) min(find(sum(x,1))),outputs.regShiftedImages));
            save(fullfile(imPathB,'vorOutputs.mat'),'outputs','-v7.3')
            toc
        case 'manual'
            [~, ~, ~] = manual_reg_SL(imPathA, imPathB);
            
            % Load, etc. 
            load(fullfile(imPathB,'RegisteredImageSLBuffered2.mat'),'regImage_shifted')
            maxY(regI) = max(cellfun(@(x) max(find(sum(x,2))),regImage_shifted));
            minY(regI) = min(cellfun(@(x) min(find(sum(x,2))),regImage_shifted));
            maxX(regI) = max(cellfun(@(x) max(find(sum(x,1))),regImage_shifted));
            minX(regI) = min(cellfun(@(x) min(find(sum(x,1))),regImage_shifted));
            clear regImage_shifted
    end
    
    disp(['Done with session ' num2str(regI) ' / 8'])
end

maxY(9) = max(cellfun(@(x) max(find(sum(x,2))),NeuronImageA));
minY(9) = min(cellfun(@(x) min(find(sum(x,2))),NeuronImageA));
maxX(9) = max(cellfun(@(x) max(find(sum(x,1))),NeuronImageA));
minX(9) = min(cellfun(@(x) min(find(sum(x,1))),NeuronImageA));

maxXX = max(maxX)+10;
maxYY = max(maxY)+10;
minXX = min(minX)-10;
minYY = min(minY)-10;

dimX = maxXX - minXX +1;
dimY = maxYY - minYY +1;

msgbox('done')

save('vorResults.mat','maxY','maxX','minY','minX')

footprintsFolder = 'F:\DoublePlus\Kerberos\KerberosFootprints';
numCells = length(NeuronImageA);
NeuronFootprint = zeros(numCells,dimY,dimX);
for cellI = 1:numCells
    %NeuronFootprint(cellI,:,:) = NeuronImageA{cellI};
    NeuronFootprint(cellI,:,:) = NeuronImageA{cellI}(minYY:maxYY,minXX:maxXX);
end
NeuronFootprint = logical(NeuronFootprint);
save(fullfile(footprintsFolder,['NeuronFootprint' baseSession(end-5:end) '.mat']),'NeuronFootprint','-v7.3')

% this needs to run so that it looks for RegisteredImage, and if that's not
% there then it uses vorOutputs
for regI = 1:8
    imPathB = regSessions{regI};
    
    if exist(fullfile(imPathB,'RegisteredImageSLBuffered2.mat'),'file')
        regMethod = 'manual';
    else
        regMethod = 'voronoi';
    end
    
    switch regMethod
        case 'voronoi'
            load(fullfile(imPathB,'vorOutputs.mat'))
            numCells = length(outputs.regShiftedImages);
            NeuronFootprint = zeros(numCells,dimY,dimX);
            for cellI = 1:numCells
                NeuronFootprint(cellI,:,:) = outputs.regShiftedImages{cellI}(minYY:maxYY,minXX:maxXX);
            end
        case 'manual'
            load(fullfile(imPathB,'RegisteredImageSLBuffered2.mat'),'regImage_shifted')
            numCells = length(regImage_shifted);
            NeuronFootprint = zeros(numCells,dimY,dimX);
            for cellI = 1:numCells
                NeuronFootprint(cellI,:,:) = regImage_shifted{cellI}(minYY:maxYY,minXX:maxXX);
            end
    end
    
    NeuronFootprint = logical(NeuronFootprint);
    
    save(fullfile(footprintsFolder,['NeuronFootprint' regSessions{regI}(end-5:end) '.mat']),'NeuronFootprint','-v7.3')
end
disp('Done saving')
msgbox('Done')
    
    
    
%% 
aligned_data_struct.number_of_sessions = 2;
aligned_data_struct.spatial_footprints = {}; % each of our neuron footprint arrays from above
aligned_data_struct.results_directory = ''; % ch, folder
aligned_data_struct.figures_directory = ''; % ch, folder
aligned_data_struct.microns_per_pixel = 1.1; % I think, verify this...
aligned_data_struct.imaging_technique = 'one_photon'; % or 'two_photon'
aligned_data_struct.footprints_projections = {}; % sum along neuron dimension (1) to generate projection
aligned_data_struct.sessions_list = {'Session 1 - C:\Users\samwi_000\Desktop\Pandora\NeuronFootprint180629.mat', 'etc'}; 
aligned_data_struct.file_names = {'C:\Users\samwi_000\Desktop\Pandora\NeuronFootprint180629.mat','etc'};
aligned_data_struct.reference_session_index = 1; % which session is your base, in order provided
aligned_data_struct.alignmet_type = 'Translations and Rotations'; % probably doesn't matter?
aligned_data_struct.centroid_locations = {[centersX centersY], []}; 
aligned_data_struct.spatial_footprints = {}; % same as above, but post alignment?
aligned_data_struct.centroid_locations = {};
aligned_data_struct.spatial_footprints_corrected = {}; % the footprints again post alignment
aligned_data_struct.adjusted_footprints_projections = {}; 
aligned_data_struct.footprints_projections_corrected = {};
aligned_data_struct.adjusted_x_size = []; % number columns in image
aligned_data_struct.adjusted_y_size = []; % number rows in image
aligned_data_struct.overlapping_FOV = []; % a binary mask which I guess just says how they overlapped? Make all 1s for our case
aligned_data_struct.maximal_cross_correlation = []; % Figure out what this is, is it necessary...
aligned_data_struct.alignment_translations = []; % in this case a 3x2 array, zeros in first column and 2nd column all < 0.08 ???
aligned_data_struct.adjustment_zero_padding = []; % in this case 2x2 zeros ???

