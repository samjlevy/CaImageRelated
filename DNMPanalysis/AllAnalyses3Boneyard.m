% All Analyses 3 boneyard

for mouseI = 1:numMice
    [xMax(mouseI,:), xMin(mouseI,:)] = GetTBTlims(cellTBT{mouseI});
end

saveName = fullfile(mainFolder,mice{mouseI},'PFsLin.mat');
switch exist(fullfile(mainFolder,mice{mouseI},'PFsLin.mat'),'file')
    case 0
        disp(['no placefields found for ' mice{mouseI} ', making now'])
        [~, ~, ~, ~, ~, ~] =...
            PFsLinTrialbyTrial2(cellTBT{mouseI}, xlims, cmperbin, minspeed,...
            saveName,'trialReli',trialReli{mouseI},'smooth',false);
    case 2
        disp(['found placefields for ' mice{mouseI} ', all good'])
end
%pooled placefields
 [~, ~, ~, ~, ~, ~] =...
            PFsLinTrialbyTrial2(cellTBT{mouseI}, xlims, cmperbin, minspeed,...
                saveName,'trialReli',trialReli{mouseI},'smooth',false,'condPairs',[1 3; 2 4; 1 2; 3 4]);  
