Cell Registration Figures:
%A
%- 3 panels: base and reg with anchor cells marked, overlap image for those 2 sessions
%    - insets in greater detail
%B
%- 2 panels: example of manually rejected cell and manually added cell
%C
%- scatter plot of roi correlations (y axis) against cell-to-cell distances (log scale)(x axis); 
%    highlight registered cells, point out cells from above manually added/rejected
%D
%- registration broken out by cell type (splitters, stem vs. arm)
%E
%- measures of within animal variability


%% A
regImageUse = 'RegisteredImageSL.mat';
base_path = 'G:\SLIDE\Processed Data\Bellatrix\Bellatrix_160831';
reg_path = 'G:\SLIDE\Processed Data\Bellatrix\Bellatrix_160830';

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
     
load(fullfile(base_path,'FinalOutput.mat'),'NeuronImage')
baseImage = NeuronImage;
base_allMask = create_AllICmask(baseImage);
base_cellCenters = getAllCellCenters(baseImage);

load(fullfile(reg_path,'FinalOutput.mat'),'NeuronImage','NeuronAvg')
regImage = NeuronImage;
reg_allMask = create_AllICmask(regImage);
reg_cellCenters = getAllCellCenters(regImage);

clear NeuronImage

load(fullfile(reg_path,regImageUse))

baseFig = figure('name','Base Session Masks','position',...
    [100 100 size(base_allMask,2)*1.5 size(base_allMask,1)*1.5]);
p(1) = imagesc(base_allMask);
title('Base Session Masks')

regFig = figure('name','Reg Session Masks','position',...
    [100+size(base_allMask,2)*1.5 100 size(reg_allMask,2)*1.5 size(reg_allMask,1)*1.5]);
q(1) = imagesc(reg_allMask);
title('Reg Session Masks')

colorInd = 1;
for gp = 1:size(pairedInds,1)
    figure(baseFig);
    hold on
    p(gp+1) = plot(base_cellCenters(pairedInds(gp,1),1), base_cellCenters(pairedInds(gp,1),2),'x','MarkerSize',10,'LineWidth',2);
    p(gp+1).Color = colorList(colorInd,:);
    
    figure(regFig);
    hold on
    q(gp+1) = plot(reg_cellCenters(pairedInds(gp,2),1), reg_cellCenters(pairedInds(gp,2),2),'x','MarkerSize',10,'LineWidth',2);
    q(gp+1).Color = colorList(colorInd,:);
    
    colorInd = colorInd + 1;
    if colorInd > size(colorList,1); colorInd = 1; end
end

reg_allMask_shifted = create_AllICmask(regImage_shifted);
reg_shift_centers = getAllCellCenters(regImage_shifted);

[overlay,overlayRef] = imfuse(base_allMask,reg_allMask_shifted,'ColorChannels',[1 2 0]);
mixFig = figure; w=imshow(overlay,overlayRef);

colorInd = 1;
for gp = 1:size(pairedInds,1)
    figure(mixFig);
    hold on
    w(gp+1) = plot(base_cellCenters(pairedInds(gp,1),1), base_cellCenters(pairedInds(gp,1),2),'x','MarkerSize',10,'LineWidth',2);
    w(gp+1).Color = colorList(colorInd,:);
    
    colorInd = colorInd + 1;
    if colorInd > size(colorList,1); colorInd = 1; end
end
%w(1).CData is where to change color information for the fused image
%title(['Base (red) and reg (green) shifted overlay, ' num2str(sum(distance<distanceThreshold)) ' cell centers < 3um'])
%hold on
%plot(reg_shift_centers(distance<distanceThreshold,1),reg_shift_centers(distance<distanceThreshold,2),'*r')


%Zoomed insets where it's good and where it's rejected
 
%% C

mouseDefaultFolder = {'G:\SLIDE\Processed Data\Bellatrix\Bellatrix_160831';...
                      'G:\SLIDE\Processed Data\Polaris\Polaris_160831';...
                      'G:\SLIDE\Processed Data\Callisto\Calisto_161026';...
                      'G:\SLIDE\Processed Data\Nix\Nix_180502'};
                  
                  regImFile = {'RegisteredImageSL.mat';...
                               'RegisteredImageSLbuffered.mat';...
                               'RegisteredImageSLbuffered.mat';...
                               'RegisteredImageSLbuffered2.mat'};
regStats = []; frs = []; frsImage = [];
for mouseI = 2:4
    cd(mouseDefaultFolder{mouseI})
    %[regStats{mouseI}] = CellRegStatsPostHoc(mouseDefaultFolder{mouseI});
    frs{mouseI} = load('fullReg.mat');
    frsImage{mouseI} = load('fullRegImage.mat');
end

%Pool distances, correlations, across mice
for mouseI = 1:4
    distancesPooled{mouseI} = [];
    corrsPooled{mouseI} = [];
    registeredDistances{mouseI} = [];
    registeredCorrs{mouseI} = [];
    registeredIns{mouseI} = [];
    for regI = 1:(length(frs{mouseI}.fullReg.RegSessions)-1)
        distancesPooled{mouseI} = [distancesPooled{mouseI}; regStats{mouseI}.cellCenterDistances.postRegistration{regI}(:)];
        dpCellsAdded{mouseI}(regI) = length(distancesPooled{mouseI});
        corrsPooled{mouseI} = [corrsPooled{mouseI}; regStats{mouseI}.ROIcorrelations{regI}(:)];
        cpCellsAdded{mouseI}(regI) = length(corrsPooled{mouseI});
        
        
        regCellsHere = sum(frs{mouseI}.fullReg.sessionInds(:,[1 regI+1])>0,2)==2;
        rcInds = find(regCellsHere);
        matInds = frs{mouseI}.fullReg.sessionInds(rcInds,[1 regI+1]); %Base cell, regCell
        matLins = sub2ind(size(regStats{mouseI}.cellCenterDistances.postRegistration{regI}),matInds(:,1),matInds(:,2));
        registeredDistances{mouseI} = [registeredDistances{mouseI}; regStats{mouseI}.cellCenterDistances.postRegistration{regI}(matLins)];
        registeredCorrs{mouseI} = [registeredCorrs{mouseI}; regStats{mouseI}.ROIcorrelations{regI}(matLins)];
        dpCellsAddedReg{mouseI}(regI) = length(registeredDistances{mouseI});
        cpCellsAddedReg{mouseI}(regI) = length(registeredCorrs{mouseI});
        registeredIns{mouseI}{regI} = matInds;
    end
end
figure; 
for mouseI = 1:4
    bb = subplot(2,2,mouseI);
    plot(log(distancesPooled{mouseI}),corrsPooled{mouseI},'.k','MarkerSize',6)
    hold on
    plot(log(registeredDistances{mouseI}),registeredCorrs{mouseI},'.r','MarkerSize',6)
    reformX = mat2cell(round(exp(bb.XTick),2),1,ones(1,length(bb.XTick)));
    dispX = cellfun(@(x) num2str(x),reformX,'UniformOutput',false);
    bb.XTickLabels = dispX;
    xlabel('Distance (um)'); ylabel('ROI correlation')
end

cc = figure; 
for mouseI = 1:4
    plot(log(distancesPooled{mouseI}),corrsPooled{mouseI},'.k','MarkerSize',6)
    hold on
end
for mouseI = 1:4
    plot(log(registeredDistances{mouseI}),registeredCorrs{mouseI},'.r','MarkerSize',6)
end
plot(log([3 3]),[0 1],'--g')
reformX = mat2cell(round(exp(cc.Children.XTick),2),1,ones(1,length(cc.Children.XTick)));
dispX = cellfun(@(x) num2str(x),reformX,'UniformOutput',false);
cc.Children.XTickLabels = dispX;
xlabel('Distance (um)'); ylabel('ROI correlation')
ylim([-0.05 1.05])

%Find manual registered examples
for mouseI = 1:4
    anyRej = cell2mat(cellfun(@length,regStats{mouseI}.manualCells.rejected,'UniformOutput',false));
    anyAdded = cell2mat(cellfun(@any,regStats{mouseI}.manualCells.added,'UniformOutput',false));
    anySwapped = cell2mat(cellfun(@any,regStats{mouseI}.manualCells.swapped,'UniformOutput',false));
    
    allThree{mouseI} = sum([anyRej; anyAdded; anySwapped],1);
end

%% Reg example
goodsess = [1,3; 1,13;3,4]; %mouse, regI
mouseI = 1;
regI = 3;
imagePathA = frsImage{mouseI}.fullRegImage;
varNameA = [];
cellsUseA = 1:find(frs{mouseI}.fullReg.sessionInds(:,regI)>0,1,'last'); %cells up to there
imagePathB = fullfile(mouseDefaultFolder{mouseI}(1:2),frs{mouseI}.fullReg.RegSessions{regI}(3:end),'RegisteredImageSL.mat');

load(imagePathB,'pairedInds')
registeredCells = find(sum([sum(frs{mouseI}.fullReg.sessionInds(:,1:regI),2)>0 frs{mouseI}.fullReg.sessionInds(:,regI+1)]>0,2)==2);
regCells = [registeredCells, frs{mouseI}.fullReg.sessionInds(registeredCells,regI+1)];
cellEx = 129;
regCellsEx = regCells; regCellsEx(regCells(:,1)==cellEx,:) = [];
cellsAdded(:,2) = regStats{mouseI}.manualCells.added{regI};
for caI = 1:size(cellsAdded,1); cellsAdded(caI,1) = find(frs{mouseI}.fullReg.sessionInds(:,regI+1)==cellsAdded(caI,2)); end
regMinus = regCells;
pairedHere = logical(sum(regCells(:,1)==pairedInds(:,1)',2));
regMinus(pairedHere,:) = [];

varNameB = 'regImage_shifted';
cellsUseB = [];

otherCellsPlot{4} = regStats{mouseI}.manualCells.added{regI}; %Added in magenta
otherCellsPlot{3} = []; %Swapped in cyan
swappedCells = regStats{mouseI}.manualCells.swapped{regI};
for scI = 1:length(swappedCells); otherCellsPlot{3}(scI) = find(frs{mouseI}.fullReg.sessionInds(:,regI+1)==swappedCells(scI)); end

[figA,figB,mixFig] = PlotCellRegFigures(imagePathA,varNameA,cellsUseA,imagePathB,varNameB,cellsUseB,pairedInds);
title(['Mouse ' num2str(mouseI) ' regI = ' num2str(regI)])

%Cell reg added
hold on; 
outlineA = bwboundaries(frsImage{mouseI}.fullRegImage{cellEx});
polyA = polyshape(outlineA{1}(:,1),outlineA{1}(:,2));
load(imagePathB,'regImage_shifted')
outlineB = bwboundaries(regImage_shifted{261});
polyB = polyshape(outlineB{1}(:,1),outlineB{1}(:,2));
overlap = intersect(polyA,polyB);
patch(overlap.Vertices(:,2),overlap.Vertices(:,1),'g','EdgeColor','none','FaceAlpha',0.6)
plot(outlineA{1}(:,2),outlineA{1}(:,1),'r','LineWidth',2)
plot(outlineB{1}(:,2),outlineB{1}(:,1),'b','LineWidth',2)

%All registered cells
load(imagePathB,'regImage_shifted')
for rrI = 1:size(regMinus,1)
    outlineA = bwboundaries(frsImage{mouseI}.fullRegImage{regMinus(rrI,1)});
    polyA = polyshape(outlineA{1}(:,1),outlineA{1}(:,2));
    outlineB = bwboundaries(regImage_shifted{regMinus(rrI,2)});
    polyB = polyshape(outlineB{1}(:,1),outlineB{1}(:,2));
    overlap = intersect(polyA,polyB);
    patch(overlap.Vertices(:,2),overlap.Vertices(:,1),'m','EdgeColor','none','FaceAlpha',0.3)
end
    
%% Swapped example
%w = warning('query','last')
warning('off','MATLAB:polyshape:repairedBySimplify')

mouseI = 2;
regI = 1;
imagePathA = frsImage{mouseI}.fullRegImage;
varNameA = [];
cellsUseA = 1:find(frs{mouseI}.fullReg.sessionInds(:,regI)>0,1,'last'); %cells up to there
imagePathB = fullfile(mouseDefaultFolder{mouseI}(1:2),frs{mouseI}.fullReg.RegSessions{regI}(3:end),regImFile{mouseI});

cellsAdded = [];
cellsAdded(:,2) = regStats{mouseI}.manualCells.rejected{regI};
for caI = 1:size(cellsAdded,1); cellsAdded(caI,1) = find(frs{mouseI}.fullReg.sessionInds(:,regI+1)==cellsAdded(caI,2)); end

varNameB = 'regImage_shifted';
cellsUseB = [];

%[figA,figB,mixFig] = PlotCellRegFigures(imagePathA,varNameA,cellsUseA,imagePathB,varNameB,cellsUseB,cellsAdded);
%title(['Mouse ' num2str(mouseI) ' regI = ' num2str(regI)])

load(imagePathB,'regImage_shifted')
cellS = 1;
swappedIn = regStats{mouseI}.manualCells.swapped{regI}(cellS);
swappedFrom = regStats{mouseI}.manualCells.swappedFrom{regI}(cellS);
baseCell = find(frs{mouseI}.fullReg.sessionInds(:,regI+1) == swappedIn);

outlineBase = bwboundaries(frsImage{mouseI}.fullRegImage{baseCell});
outlineSwappedIn = bwboundaries(regImage_shifted{swappedIn});
outlineSwappedFrom = bwboundaries(regImage_shifted{swappedFrom});
outlinesReg = cellfun(@bwboundaries,regImage_shifted,'UniformOutput',false);
%2 figures: original and actually there
figure; 
subplot(1,2,1)
hold on
for roI = 1:length(outlinesReg)
    plot(outlinesReg{roI}{1}(:,2),outlinesReg{roI}{1}(:,1),'Color',[1 0.4 0.4]);
end
plot(outlineBase{1}(:,2),outlineBase{1}(:,1),'b','LineWidth',1.5)
plot(outlineSwappedFrom{1}(:,2),outlineSwappedFrom{1}(:,1),'r','LineWidth',1.5)
title(['Cell Swapped from'])

subplot(1,2,2)
hold on
for roI = 1:length(outlinesReg)
    plot(outlinesReg{roI}{1}(:,2),outlinesReg{roI}{1}(:,1),'Color',[1 0.4 0.4]);
end
plot(outlineBase{1}(:,2),outlineBase{1}(:,1),'b','LineWidth',1.5)
plot(outlineSwappedIn{1}(:,2),outlineSwappedIn{1}(:,1),'r','LineWidth',1.5)
title(['Cell Swapped in'])

suptitleSL(['mouseI ' num2str(mouseI) ' regI ' num2str(regI)])





polyA = polyshape(outlineA{1}(:,1),outlineA{1}(:,2));
    outlineB = bwboundaries(regImage_shifted{regCellsEx(rrI,2)});
    polyB = polyshape(outlineB{1}(:,1),outlineB{1}(:,2));
    overlap = intersect(polyA,polyB);


%Plot other reg cells:
registeredCells = find(sum([sum(frs{mouseI}.fullReg.sessionInds(:,1:regI),2)>0 frs{mouseI}.fullReg.sessionInds(:,regI+1)]>0,2)==2);
regCells = [registeredCells, frs{mouseI}.fullReg.sessionInds(registeredCells,regI+1)];
regCell = 139;
hold on; 
regCellsEx = regCells; regCellsEx(regCells(:,2)==regCell,:) = [];
load(imagePathB,'regImage_shifted')
for rrI = 1:size(regCellsEx,1)
    outlineA = bwboundaries(frsImage{mouseI}.fullRegImage{regCellsEx(rrI,1)});
    polyA = polyshape(outlineA{1}(:,1),outlineA{1}(:,2));
    outlineB = bwboundaries(regImage_shifted{regCellsEx(rrI,2)});
    polyB = polyshape(outlineB{1}(:,1),outlineB{1}(:,2));
    overlap = intersect(polyA,polyB);
    patch(overlap.Vertices(:,2),overlap.Vertices(:,1),'m','EdgeColor','none','FaceAlpha',0.3)
end

mixFig.Children.XLim = [157.4257 325.9753];
mixFig.Children.YLim = [105.1475 240.5437];
    


%% Added example

warning('off','MATLAB:polyshape:repairedBySimplify')

mouseI = 3;
regI = 1;
imagePathA = frsImage{mouseI}.fullRegImage;
varNameA = [];
cellsUseA = 1:find(frs{mouseI}.fullReg.sessionInds(:,regI)>0,1,'last'); %cells up to there
imagePathB = fullfile(mouseDefaultFolder{mouseI}(1:2),frs{mouseI}.fullReg.RegSessions{regI}(3:end),regImFile{mouseI});

%cellEx = 129;
%regCellsEx = regCells; regCellsEx(regCells(:,1)==cellEx,:) = [];
cellsAdded = [];
cellsAdded(:,2) = regStats{mouseI}.manualCells.added{regI};
for caI = 1:size(cellsAdded,1); cellsAdded(caI,1) = find(frs{mouseI}.fullReg.sessionInds(:,regI+1)==cellsAdded(caI,2)); end


varNameB = 'regImage_shifted';
cellsUseB = [];

[figA,figB,mixFig] = PlotCellRegFigures(imagePathA,varNameA,cellsUseA,imagePathB,varNameB,cellsUseB,cellsAdded);
title(['Mouse ' num2str(mouseI) ' regI = ' num2str(regI)])
         
%Plot other reg cells:
registeredCells = find(sum([sum(frs{mouseI}.fullReg.sessionInds(:,1:regI),2)>0 frs{mouseI}.fullReg.sessionInds(:,regI+1)]>0,2)==2);
regCells = [registeredCells, frs{mouseI}.fullReg.sessionInds(registeredCells,regI+1)];
regCell = 139;
hold on; 
regCellsEx = regCells; regCellsEx(regCells(:,2)==regCell,:) = [];
load(imagePathB,'regImage_shifted')
for rrI = 1:size(regCellsEx,1)
    outlineA = bwboundaries(frsImage{mouseI}.fullRegImage{regCellsEx(rrI,1)});
    polyA = polyshape(outlineA{1}(:,1),outlineA{1}(:,2));
    outlineB = bwboundaries(regImage_shifted{regCellsEx(rrI,2)});
    polyB = polyshape(outlineB{1}(:,1),outlineB{1}(:,2));
    overlap = intersect(polyA,polyB);
    patch(overlap.Vertices(:,2),overlap.Vertices(:,1),'m','EdgeColor','none','FaceAlpha',0.3)
end


mixFig.Children.XLim = [157.4257 325.9753];
mixFig.Children.YLim = [105.1475 240.5437];

suptitleSL(['centerdistance = ' num2str(regStats{mouseI}.cellCenterDistances.postRegistration{regI}(73, 139))...
            ' ROIcorr = ' num2str(regStats{mouseI}.ROIcorrelations{regI}(73, 139))])

%% Rejected example

mouseI = 2;
regI = 1;
imagePathA = frsImage{mouseI}.fullRegImage;
varNameA = [];
cellsUseA = 1:find(frs{mouseI}.fullReg.sessionInds(:,regI)>0,1,'last'); %cells up to there
imagePathB = fullfile(mouseDefaultFolder{mouseI}(1:2),frs{mouseI}.fullReg.RegSessions{regI}(3:end),regImFile{mouseI});

varNameB = 'regImage_shifted';
cellsUseB = [];

registeredCells = find(sum([sum(frs{mouseI}.fullReg.sessionInds(:,1:regI),2)>0 frs{mouseI}.fullReg.sessionInds(:,regI+1)]>0,2)==2);
regCells = [registeredCells, frs{mouseI}.fullReg.sessionInds(registeredCells,regI+1)];

[figA,figB,mixFig] = PlotCellRegFigures(imagePathA,varNameA,cellsUseA,imagePathB,varNameB,cellsUseB,regCells);
title(['Mouse ' num2str(mouseI) ' regI = ' num2str(regI)])

cellsRejected = [];
cellsRejected(:,2) = regStats{mouseI}.manualCells.rejected{regI};
for caI = 1:size(cellsRejected,1); cellsRejected(caI,1) = find(frs{mouseI}.fullReg.sessionInds(:,regI+1)==cellsRejected(caI,2)); end
load(imagePathB,'regImage_shifted')
for rrI = 1:size(cellsRejected,1)
    outlineA = bwboundaries(frsImage{mouseI}.fullRegImage{cellsRejected(rrI,1)});
    polyA = polyshape(outlineA{1}(:,1),outlineA{1}(:,2));
    outlineB = bwboundaries(regImage_shifted{cellsRejected(rrI,2)});
    polyB = polyshape(outlineB{1}(:,1),outlineB{1}(:,2));
    overlap = intersect(polyA,polyB);
    patch(overlap.Vertices(:,2),overlap.Vertices(:,1),'m','EdgeColor','none','FaceAlpha',0.3)
end

         


