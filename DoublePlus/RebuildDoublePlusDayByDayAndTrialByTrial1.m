%function RebuildDoublePlusDayByDayAndTrialByTrial1(sessionFiles)
mainFolder = 'C:\Users\Sam\Desktop\DoublePlus';
mice = {'Kerberos','Marble07','Marble11','Pandora','Styx','Titan'};
numMice = numel(mice);

mazeBoundaries = load(fullfile(mainFolder,'armBoundariesUsed.mat'));
% Get a list of all the sessions we want to fix, whether they need to be combined
combineFiles = cell(9,6);
for mouseI =1:numMice
    load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'),'allfiles')
    %dpFileList{mouseI} = allfiles;
    
    for fileI = 1:9
        folderPts = strsplit(allfiles{fileI},'\');
        fH = folderPts{end};
        
        dpFileList{fileI,mouseI} = fH;

        if strcmpi(fH(end-2:end),'all')
            cFolders = ls(fullfile(mainFolder,mice{mouseI},[fH(1:end-3) '*']));
            allFolder = [];
            for ii = 1:size(cFolders,1)
                allFolder(ii,1) = any(strfind(cFolders(ii,:),'all'));
            end
            cFolders(find(allFolder),:) = [];
            combineFiles{fileI,mouseI} = cFolders;
        end
        
    end
end

deleteAdjustedFiles = true; % set to true if we've already run this script and we need to run it again

mazeBoundaries = load(fullfile(mainFolder,'armBoundariesUsed.mat'));
%{
armLabelsN = 'mnesw';
outerBounds.X = mazeBoundaries.lgDataBins.X(mazeBoundaries.lgDataBins.labels=='m',:); outerBounds.X = outerBounds.X(:);
outerBounds.Y = mazeBoundaries.lgDataBins.Y(mazeBoundaries.lgDataBins.labels=='m',:); outerBounds.Y = outerBounds.Y(:);
outerBounds.armLabels(1:4,1) = 'm';
for armI = 1:4
    armH = armLabelsN(armI+1);
    centerBin = find(mazeBoundaries.lgDataBins.labels==armH,1,'first');
    lastBin = find(mazeBoundaries.lgDataBins.labels==armH,1,'last');
    centerX = mazeBoundaries.lgDataBins.X(centerBin,:);
    centerY = mazeBoundaries.lgDataBins.Y(centerBin,:);
    outerX = mazeBoundaries.lgDataBins.X(outerBin,:);
    outerY = mazeBoundaries.lgDataBins.Y(outerBin,:);
   
end
%}

for mouseI = 1:numMice
    for sessI = 1:9
        % Check that we have position and imaging, so we skip mouse1-s5,6
        % And we leave out the sessions that need to be merged
        sessUse = [];
        if isempty(combineFiles{sessI,mouseI})
            sessUse{1} = fullfile(mainFolder,mice{mouseI},dpFileList{sessI,mouseI});
        else
            for sss = 1:size(combineFiles{sessI,mouseI},1)
                sessUse{sss} = fullfile(mainFolder,mice{mouseI},combineFiles{sessI,mouseI}(sss,:)); 
                sessUse{sss}(sessUse{sss}==' ') = [];
            end
        end

        for sessJ = 1:numel(sessUse)
            sessionFolder = sessUse{sessJ};
            sessionFolder = fullfile(mainFolder,mice{mouseI},dpFileList{sessI,mouseI});
            %havePos = exist(fullfile(sessionFolder,'posAnchored.mat'),'file')==2;
            %if havePos
            sessionType = 'Turn Right';
            if sessI>=4 && sessI<=6; sessionType = 'Go East'; end

            cd(sessionFolder)
            if deleteAdjustedFiles == true
                try
                    RestoreOriginalTBTstuff(sessionFolder)
            catch
                disp('something wrong here?')
                keyboard
                end
            end
            % This one will take a pass through the original, parsed
            % behavior and try to "handle" it, and also align imaging
            % and tracking using the method assuming they should be the
            % same length

            behFile = 'plusMazeBehavior.mat';
            %copyfile(behFile,'plusMazeBehaviorOriginal.mat');
            %plusBehaviorChecker(behFile)

            % behFileEditor(filePath)
            frameBuffer = 10;
            nBoundRegions = 4;

            FixAlignImagingToTrackingDoublePlus1(sessionFolder,sessionType,mazeBoundaries,nBoundRegions,frameBuffer)
        end

        if ~isempty(combineFiles{sessI,mouseI})
            % Find cell reg inds
            saveFolder = fullfile(mainFolder,mice{mouseI},dpFileList{sessI,mouseI});
            cellRegInds = fullReg.sessionInds;
            for sss = 1:numel(sessUse)
                sessUse{sss} = fullfile(mainFolder,mice{mouseI},sessUse{sss});
            end
            MergeDifferentSessionPieces(sessUse,cellRegInds,saveFolder)
        end
    end
end

for mouseI = 1:numMice
    % Make the daybyday, lets make it not a single terrible struct this time
    mousePath = fullfile(mainFolder,mice{mouseI});
     
    cd(mousePath)

    movefile(fullfile(mousePath,'trialbytrial.mat'),fullfile(mousePath,'trialbytrialOriginal.mat'))

    load(fullfile(mousePath,'trialbytrialOriginal.mat'),'allfiles','sortedSessionInds')
    
    %load(fullfile(mousePath,'fullReg.mat'))
    %registrationUseNames = fullReg.RegSessions;
    %registrationUseIndices = fullReg.sessionInds;
    registrationUseNames = allfiles;
    registrationUseIndices = sortedSessionInds;
    if numel(registrationUseNames) ~= size(registrationUseIndices,2)
        disp('probably need to append baseSession')
        keyboard
    end
    deleteSilentCells = false;
    getFluorescence = true;
    
    daybydayPath = fullfile(mousePath,'daybyday.mat');
    movefile(daybydayPath,fullfile(mousePath,'daybydayOriginal.mat'))
    pathFileList = [dpFileList(:,mouseI)]; %just the 9 sessions we want to combine

    if mouseI == 1
        pathFileList{5} = [];
        pathFileList{6} = [];
    end
    [sortedSessionInds] = MakeDayByDayDoublePlus3(pathFileList, mousePath, getFluorescence, deleteSilentCells, registrationUseNames,registrationUseIndices);

    
    % Make the tbt, adding in a velocity
    
    
    velThresh = 1; % cm/s
    excludeOutOfMazeBounds = true; % delete all pts outside of maze boundaries
    MakeTBTdoublePlus3(daybydayPath,excludeOutOfMazeBounds,mazeBoundaries,velThresh)
    allfiles = pathFileList(cellfun(@any,pathFileList));
    save(fullfile(mousePath,'trialbytrial.mat'),'allfiles','-append')
    if mouseI == 1
        allfiles = pathFileList;
        load(fullfile(mousePath,'trialbytrialOriginal.mat'),'sortedSessionInds')
        save(fullfile(mousePath,'trialbytrial.mat'),'sortedSessionInds','-append')
    end

    disp('Done with another tbt!')
end

