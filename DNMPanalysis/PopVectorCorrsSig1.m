function [corrsReorgSorted] = PopVectorCorrsSig1(shuffleFolder, traitLogical, cellsUse, corrType, condPairs, dayPairs)
%For now requires that condPairs and dayPairs be input

numCondPairs = size(condPairs,1);

if exist(fullfile(shuffleFolder,'corrsReorg.mat'),'file')~=2
    disp('did not find corrsReorg, making now')
    
    possibleShuffles = dir(fullfile(shuffleFolder, 'shuff*.mat'));
    possibleShuffles([possibleShuffles(:).isdir]==1) = [];
    numShuffles = length(possibleShuffles);
    disp(['found ' num2str(numShuffles) ' shuffles'])

    load(fullfile(shuffleFolder,possibleShuffles(1).name),'TMap_unsmoothed')
    numBins = length(TMap_unsmoothed{1,1,1});

    corrsReorg = cell(1,numCondPairs);
    for cpJ = 1:numCondPairs
        corrsReorg{cpI} = nan(size(dayPairs,1),numBins,numShuffles);
    end

    for shuffI = 1:numShuffles
        load(fullfile(shuffleFolder,possibleShuffles(shuffI).name),'TMap_unsmoothed');
        [shuffCorrs, ~, ~, ~] =...
            PopVectorCorrs1(TMap_unsmoothed,traitLogical, cellsUse, corrType, condPairs, dayPairs);

        for cpI = 1:numCondPairs
            corrsReorg{cpI}(:,:,shuffI) = squeeze(shuffCorrs(:,cpI,:));
        end 
    end
    disp('done making shuffled corrs')

    save(fullfile(shuffleFolder,'corrsReorg.mat'),'corrsReorg','condPairs','dayPairs')
    %corrsReorg: {condPair}(day, bin, shuffle)
else
    disp('found corrsReorg, using it')
    load(fullfile(shuffleFolder,'corrsReorg.mat'));
end

corrsReorgSorted = cell(1,numCondPairs);
for cpI = 1:numCondPairs
    corrsReorgSorted{cpI} = sort(corrsReorg{cpI},3,'ascend');
end

end


