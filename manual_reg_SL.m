function [base_cellCenters, reg_cellCenters, pairedInds] = manual_reg_SL(base_path, reg_path);
%manual_reg sam alternations;
%needs as input paths for the mask data
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
base_allMask = create_AllICmask(NeuronImage);
base_cellCenters = getAllCellCenters(NeuronImage);

load(fullfile(reg_path,'FinalOutput.mat'),'NeuronImage')
reg_allMask = create_AllICmask(NeuronImage);
reg_cellCenters = getAllCellCenters(NeuronImage);

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

end