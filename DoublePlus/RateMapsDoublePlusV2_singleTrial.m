function [TMap_unsmoothed,RunOccMap] = RateMapsDoublePlusV2_singleTrial(trialbytrial, bins, binType, minSpeed, occNanSol, saveName, circShift)

% occNanSol switches what to do with 0s in the OccMap, which will causes
% nans in the TMap. For those TMap nans, 'leaveNan' or 'zeroOut'
% circShift can either be true to randomly pick, or a number; this will
% shift the entire vector, not on a lap by lap basis

switch binType
    case 'vertices'
        % Expecting a each bin specified by a cell array with 
        % x and y coordinates for all each individual bin
        numBins = size(bins{1},1);
        
        xBinCells = mat2cell(bins{1},ones(numBins,1),size(bins{1},2));
        yBinCells = mat2cell(bins{2},ones(numBins,1),size(bins{2},2));
        binLabels = 1:numBins; if size(xBinCells,1) > size(xBinCells,2); binLabels = binLabels(:); end
        binLabelsCell = mat2cell(binLabels,ones(size(xBinCells,1),1),ones(1,size(xBinCells,2)));
    case 'lims'
        % expecting a cell array that has up to 2 arrays, with 
        % bin edges for that respective coordinate
        numBins = 1;
        for ii = length(bins)
            if isempty(bins{ii})
                numBins = numBins*1;
            else
                numBins = numBins*(size(bins{ii},1)-1);
            end
        end
end

saveThis = 1;
if isempty(saveName)
    saveThis = 0;
end

%sessions = unique(trialbytrial(1).sessID);
%numSess = length(sessions);
numCells = size(trialbytrial(1).trialPSAbool{1,1},1);
numConds = length(trialbytrial);

for condI = 1:numConds
    nTrials(condI) = length(trialbytrial(condI).trialsX);
end
maxTrials = max(nTrials);

TMap_unsmoothed = cell(numCells,maxTrials,numConds);
[TMap_unsmoothed{:}] = deal(nan(numBins,1));

%OccMap = cell(numConds, numSess);
%RunOccMap = cell(numConds, numSess);
%TMap_unsmoothed = cell(numCells, numSess, numConds);
%TCounts = cell(numCells, numSess, numConds);

for condI = 1:numConds
    numTrials = length(trialbytrial(condI).trialsX);
    for trialI = 1:numTrials    
        
        posX = trialbytrial(condI).trialsX{trialI};
        posY = trialbytrial(condI).trialsY{trialI};

        velH = [];
            
            %{
            if any(velThresh)
                velHere = [trialbytrial(condsHere(chJ)).trialVel{lapsUse{chJ},1}];
                velH = [velH velHere];
            end
            %}
        
        % deal with velocity
        %{
        good = true(1,length(posX));
        isrunning = good;                         %Running frames that were not excluded.
        if any(velThresh)
        %isrunning(velocity < minspeed) = false;
            isrunning(velH < velThresh) = false;
        end
        %}
        
        lapsSpiking = logical(trialbytrial(condI).trialPSAbool{trialI});
    
        if circShift==true
            shiftAmt = randi(size(lapsSpiking,2)-1);
            
            ls = lapsSpiking;
            lapsSpiking = [ls(:,shiftAmt+1:end) ls(:,1:shiftAmt)];
        end
        
        switch binType
            case 'vertices'
                % Vertices of each bin specified
                
                xx = cellfun(@(x,y,z) inpolygon(posX,posY,x,y),xBinCells,yBinCells,binLabelsCell,'UniformOutput',false);
                yy = cell2mat(xx);
                zz = sum(yy,1);
                if any(find(zz>1))
                    disp('Error: overlapping bins')
                    keyboard
                end
                %if any(find(zz==0))
                %    disp('Error: pos outside of a bin')
                    %keyboard
                %end
                OccMap{condI,trialI} = sum(yy,2);
                
                binIdsCell = sum(cell2mat(cellfun(@(x,y,z) z*inpolygon(posX,posY,x,y),xBinCells,yBinCells,binLabelsCell,...
                    'UniformOutput',false)),1); % Which bin is each position in
                
                % Spiking
                for cellI = 1:numCells
                    thisSpiking = yy(:,lapsSpiking(cellI,:));
                    TCounts{cellI,trialI,condI} = sum(thisSpiking,2);
                    TMap_unsmoothed{cellI,trialI,condI} = TCounts{cellI,trialI,condI} ./ OccMap{condI,trialI};
                    if strcmpi(occNanSol,'zeroOut')
                        TMap_unsmoothed{cellI,trialI,condI}(OccMap{condI,trialI}==0) = 0;
                    end
                    
                    if isempty(TMap_unsmoothed{cellI,trialI,condI})
                        keyboard
                    end
                end
              
            case 'lims'
                disp('Nope does not work yet')
                % Ready to use premade bin limits
                haveLims = cellfun(@(x) any(x,'all'),bins);
                if sum(haveLims)==1
                    if length(haveLims) == 1
                        posUse = posX;
                        linearEdges = sort(bins,'ascend');
                    else
                        switch find(haveLims)
                            case 1
                                posUse = posX;
                                linearEdges = sort(bins{1},'ascend');
                            case 2
                                posUse = posY;
                                linearEdges = sort(bins{2},'ascend');
                        end
                    end
                    
                    % 1 dimensional histcounts
                    
                else
                    % 2 dimensional histcounts
                                
                end
        end
        
    end
end
RunOccMap = OccMap;

TMap_firesAtAll = cellfun(@(x) any(x>0),TCounts);

if saveThis==1
    if ~exist('saveName','var')
        saveName = 'PFs.mat';
    end
    savePath = saveName; 
    save(savePath,'OccMap','RunOccMap', 'TMap_unsmoothed', 'TCounts','TMap_firesAtAll')
end

end
        
        
        