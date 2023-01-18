% slidingWindowAccuracy


for mouseI = 1:numMice
    %load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'),'tbtAllEach')
    %cellTBTall{mouseI} = tbtAllEach;
    %clear tbtAllEach
    load(fullfile(mainFolder,mice{mouseI},'mazePerformance.mat'))
    mazeAccuracy{mouseI} = mazePerformance;
    clear mazePerformance
end

slidingWindowSize = 10;
numWindows = 10;

for mouseI = 1:6
    for sessI = 1:9
        %trialsHereN = find(cellTBTall{mouseI}(1).sessID == sessI);
        %trialsHereS = find(cellTBTall{mouseI}(3).sessID == sessI);
        try
            trialsHereN = find(strcmpi(mazeAccuracy{mouseI}{sessI}.Start,'n'));
            trialsHereS = find(strcmpi(mazeAccuracy{mouseI}{sessI}.Start,'s'));
        catch
            trialsHereN = find(strcmpi(mazeAccuracy{mouseI}{sessI}(:,2),'n'));
            trialsHereS = find(strcmpi(mazeAccuracy{mouseI}{sessI}(:,2),'s'));
        end
        if any(trialsHereS) && any(trialsHereN)

            %round(linspace(1,numel(trialsHereN),numWindows+1))
            accHn = [];
            for tStartI = 1:numel(trialsHereN)-(slidingWindowSize-1)
                %accHn(tStartI) = sum(cellTBTall{mouseI}(1).isCorrect(trialsHereN(tStartI):trialsHereN(tStartI)+(slidingWindowSize-1)))/slidingWindowSize;
                try
                    accHn(tStartI) = sum(mazeAccuracy{mouseI}{sessI}.Correct(trialsHereN(tStartI):trialsHereN(tStartI)+(slidingWindowSize-1)))/slidingWindowSize;
                catch
                    accHn(tStartI) = sum(mazeAccuracy{mouseI}{sessI}((trialsHereN(tStartI):trialsHereN(tStartI)+(slidingWindowSize-1)),4))/slidingWindowSize;
                end
            end
    
            accHs = [];
            for tStartI = 1:numel(trialsHereS)-(slidingWindowSize-1)
                %accHs(tStartI) = sum(cellTBTall{mouseI}(3).isCorrect(trialsHereS(tStartI):trialsHereS(tStartI)+(slidingWindowSize-1)))/slidingWindowSize;
                try
                    accHs(tStartI) = sum(mazeAccuracy{mouseI}{sessI}.Correct(trialsHereS(tStartI):trialsHereS(tStartI)+(slidingWindowSize-1)))/slidingWindowSize;
                catch
                    accHn(tStartI) = sum(mazeAccuracy{mouseI}{sessI}((trialsHereS(tStartI):trialsHereS(tStartI)+(slidingWindowSize-1)),4))/slidingWindowSize;
                end
            end
            
            northAccuracy{mouseI,sessI} = accHn;
            southAccuracy{mouseI,sessI} = accHs;
        end
    end
end

%{
figure;
for mouseI = 1:numMice
    % Concatenate all the pcts  
    accAllN = [];
    dayMarkerN = [];
    accAllS = [];
    dayMarkerS = [];
    for sessI = 1:9
        accH = northAccuracy{mouseI,sessI};
        accAllN = [accAllN, accH];
        dayMarkerN = [dayMarkerN, sessI*ones(1,numel(accH))];

        accH = southAccuracy{mouseI,sessI};
        accAllS = [accAllS, accH];
        dayMarkerS = [dayMarkerS, sessI*ones(1,numel(accH))];
    end
    
    
    subplot(1,2,1)
    nEachSum = cumsum(cellfun(@numel,northAccuracy(mouseI,:)));
    plot(accAllN+mouseI-1)
    for ii = 1:8
        hold on
        plot(nEachSum(ii)*[1 1],[min(accAllN) max(accAllN)]+mouseI-1,'k')
    end

    subplot(1,2,2)
    sEachSum = cumsum(cellfun(@numel,southAccuracy(mouseI,:)));
    plot(accAllS+mouseI-1)
    for ii = 1:8
        hold on
        plot(sEachSum(ii)*[1 1],[min(accAllS) max(accAllS)]+mouseI-1,'k')
    end
    
end
    %}

figure;
sumXn = 0;
sumXs = 0;
for sessI = 1:9
    nxlim = max(cellfun(@numel,northAccuracy(:,sessI)));
    sxlim = max(cellfun(@numel,southAccuracy(:,sessI)));
  
    for mouseI = 1:6    
        subplot(2,2,groupNum(mouseI))
    
        accH = northAccuracy{mouseI,sessI};
        if any(accH)
        plot([1:numel(accH)]+sumXn,accH,'Color',groupColors{groupNum(mouseI)})
        hold on
        end
    end
    sumXn = sumXn + nxlim;
    subplot(2,2,1)
    plot([1 1]*sumXn,[0 1],'k')
    subplot(2,2,2)
    plot([1 1]*sumXn,[0 1],'k')

    
    for mouseI = 1:6 
        subplot(2,2,groupNum(mouseI)+2)  
    
        accH = southAccuracy{mouseI,sessI};
        if any(accH)
        plot([1:numel(accH)]+sumXs,accH,'Color',groupColors{groupNum(mouseI)})
        hold on
        end
    end
    
    sumXs = sumXs + sxlim;
    subplot(2,2,3) % For some reason error chime here?
    plot([1 1]*sumXs,[0 1],'k')
    subplot(2,2,4) % For some reason error chime here?
    plot([1 1]*sumXs,[0 1],'k')
 
end
subplot(2,2,1); ylim([0 1.05]); title('One Maze, North Starts')
subplot(2,2,2); ylim([0 1.05]); title('Two Maze, North Starts')
subplot(2,2,3); ylim([0 1.05]); title('One Maze, South Starts')
subplot(2,2,4); ylim([0 1.05]); title('Two Maze, South Starts')