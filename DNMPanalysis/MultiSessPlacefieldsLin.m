function MultiSessPlacefieldsLin( allfiles, all_x_adj_cm, all_y_adj_cm, sessionInds, all_PSAbool, cmperbin, all_useLogical, useActual)
numSessions = length(allfiles); 
%allInc = cell(4,length(allfiles));
pooled = cell(length(allfiles),1);
for file = 1:length(allfiles)
    bta = dir(fullfile(allfiles{file},'*BrainTime_Adjusted.xlsx'));
    if length(bta)==1
        bta = bta.name;
    elseif length(bta) > 1
        isRight = cell2mat(cellfun(@(x) any(strfind(x,'~$')),{bta.name},'UniformOutput',false));
        if sum(isRight)==1
            bta = bta(isRight).name;
        end
    else 
        disp('could not find brainTime_adjusted file')
        return
    end
    [bounds{file},~,~, pooled{file},correct{file}] =...
    GetBlockDNMPbehavior( fullfile(allfiles{file},bta), 'stem_only', length(all_x_adj_cm{1,file}));

    %allInc{1,file} = pooled{file}.include.forced & pooled{file}.include.left; %studyLeft
    %allInc{2,file} = pooled{file}.include.forced & pooled{file}.include.right; %studyRight
    %allInc{3,file} = pooled{file}.include.free & pooled{file}.include.left;%testLeft
    %allInc{4,file} = pooled{file}.include.free & pooled{file}.include.right; %testRight    
end

correctBounds = StructCorrect(bounds, correct);

trialbytrial = PoolTrialsAcrossSessions(correctBounds,all_x_adj_cm,all_y_adj_cm,all_PSAbool,sessionInds);

[sortedReliability,aboveThresh] = TrialReliability(trialbytrial, 0.5);
newUseActual = cell2mat(cellfun(@(x) sum(x,2) > 0,aboveThresh,'UniformOutput',false));

PFsLinTrialbyTrial(trialbytrial,aboveThresh);


rastPlot = figure('name','Raster Plot','Position',[100 50 1000 800]);
PlotRasterMultiSess2(trialbytrial, thisCell, sessionInds, sortedReliability,rastPlot);

dotHeat = figure;

dotlocs = [5 6; 7 8; 13 14; 15 16];
heatlocs = [1 2; 3 4; 9 10; 11 12];
titles = {'Study Left'; 'Study Right'; 'Test Left'; 'Test Right'};
for cellI = 1:length(useActual)
    thisCell = useActual(cellI);

    ManyDotPlots(trialbytrial, thisCell, sessionInds, aboveThresh, dotHeat, [4 4], dotlocs) %titles
    ManyHeatPlots(mapLoc, thisCell, figHand, [4 4], heatlocs,titles)
    
    % set to landscape or portrait
% if hfig.Position(3) > hfig.Position(4)
%     hfig.PaperOrientation = 'landscape';
% else
%     hfig.PaperOrientation = 'portrait';
% end
resolution_use = '-r600'; %'-r600' = 600 dpi - might not be necessary
hfig.Renderer = 'painters'; % This makes sure weird stuff doesn't happen when you save lots of data points by using openGL rendering
save_file = fullfile(location, filename);
print(hfig, save_file,'-dpdf',resolution_use, varargin{:});
% print(hfig, save_file,'-dpdf','-bestfit',resolution_use)

end

append_pdfs(output file, input files)


    
    
%make lin place fields

%plot heatmaps

plotX = [trialbytrial(condType).trialsX{:}];
plotY = [trialbytrial(condType).trialsY{:}];
blockBool = [trialbytrial(condType).trialPSAbool{:}];
spikeX = plotX(blockBool(14,:));
spikeY = plotY(blockBool(14,:));
ddd


end

end