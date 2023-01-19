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
            startsHere = mazeAccuracy{mouseI}{sessI}.Start;
        catch
            startsHere = mazeAccuracy{mouseI}{sessI}{:,2};
        end

        switch class(startsHere)
            case 'categorical'
                trialsHereN = find((startsHere == 'N') | (startsHere == 'n'));
                trialsHereS = find((startsHere == 'S') | (startsHere == 's'));
            %case 'table'

            otherwise
                disp(['Other class ' num2str(mouseI) ' ' num2str(sessI)])
        end
%{
        try
            trialsHereN = find(strcmpi(mazeAccuracy{mouseI}{sessI}.Start,'n'));
            trialsHereS = find(strcmpi(mazeAccuracy{mouseI}{sessI}.Start,'s'));
        catch
            trialsHereN = find(strcmpi(mazeAccuracy{mouseI}{sessI}(:,2),'n'));
            trialsHereS = find(strcmpi(mazeAccuracy{mouseI}{sessI}(:,2),'s'));
        end
%}
        if any(trialsHereS) && any(trialsHereN)

            %round(linspace(1,numel(trialsHereN),numWindows+1))
            try
                correctHere = mazeAccuracy{mouseI}{sessI}.Correct;
            catch
                correctHere = mazeAccuracy{mouseI}{sessI}{:,4};
            end
            correctHere = logical(correctHere);

            accHn = [];
            correctHereN = correctHere(trialsHereN);
            for tStartI = 1:numel(trialsHereN)-(slidingWindowSize-1)
                %accHn(tStartI) = sum(cellTBTall{mouseI}(1).isCorrect(trialsHereN(tStartI):trialsHereN(tStartI)+(slidingWindowSize-1)))/slidingWindowSize;
                %{
                try
                    accHn(tStartI) = sum(mazeAccuracy{mouseI}{sessI}.Correct(trialsHereN(tStartI):trialsHereN(tStartI)+(slidingWindowSize-1)))/slidingWindowSize;
                catch
                    accHn(tStartI) = sum(mazeAccuracy{mouseI}{sessI}((trialsHereN(tStartI):trialsHereN(tStartI)+(slidingWindowSize-1)),4))/slidingWindowSize;
                end
                %}
                %accHn(tStartI) = sum(correctHere(trialsHereN(tStartI):trialsHereN(tStartI)+(slidingWindowSize-1)))/slidingWindowSize;

                accHn(tStartI) = sum(correctHereN(tStartI:(tStartI+(slidingWindowSize-1))))/slidingWindowSize;
            end
    
            accHs = [];
            correctHereS = correctHere(trialsHereS);
            for tStartI = 1:numel(trialsHereS)-(slidingWindowSize-1)
                %accHs(tStartI) = sum(cellTBTall{mouseI}(3).isCorrect(trialsHereS(tStartI):trialsHereS(tStartI)+(slidingWindowSize-1)))/slidingWindowSize;
                %{
                try
                    accHs(tStartI) = sum(mazeAccuracy{mouseI}{sessI}.Correct(trialsHereS(tStartI):trialsHereS(tStartI)+(slidingWindowSize-1)))/slidingWindowSize;
                catch
                    accHn(tStartI) = sum(mazeAccuracy{mouseI}{sessI}((trialsHereS(tStartI):trialsHereS(tStartI)+(slidingWindowSize-1)),4))/slidingWindowSize;
                end
                %}
                %accHs(tStartI) = sum(correctHere(trialsHereS(tStartI):trialsHereS(tStartI)+(slidingWindowSize-1)))/slidingWindowSize;
                accHs(tStartI) = sum(correctHereS(tStartI:(tStartI+(slidingWindowSize-1))))/slidingWindowSize;
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

% Plot for each animal with north and south overlaid? 
daySizes = max([cellfun(@numel,northAccuracy);cellfun(@numel,southAccuracy)],[],1);
daySizesAgg = cumsum(daySizes);
dayMidLocs = daySizes/2 + [0 daySizesAgg(1:8)];
dayTicksLabels = [1:9; daySizes+10]; dayTicksLabels = dayTicksLabels(:); dayTicksLabels = arrayfun(@num2str,dayTicksLabels,'UniformOutput',false);
dayTicks = [dayMidLocs; daySizesAgg]; dayTicks = dayTicks(:);
figure;
for mouseI = 1:numMice
    subplot(numMice,1,mouseI)
    for sessI = 2:9
        plot(daySizesAgg(sessI-1)*[1 1],[0 1],'k--')
        hold on
    end
    for sessI = 1:9
        plot((1:numel(northAccuracy{mouseI,sessI}))+sum(daySizes(1:(sessI-1))),northAccuracy{mouseI,sessI},'Color',groupColors{groupNum(mouseI)},'LineStyle',':','LineWidth',1.5)
        hold on
    end
    for sessI = 1:9
        plot((1:numel(southAccuracy{mouseI,sessI}))+sum(daySizes(1:(sessI-1))),southAccuracy{mouseI,sessI},'Color',groupColors{groupNum(mouseI)})
        hold on
    end
    ylabel(['Mouse ' num2str(mouseI)])
    xlim([1 daySizesAgg(end)])
    ylim([0 1.05])
    box off

    if mouseI == numMice
        set(gca,'XTick',dayTicks)
        set(gca,'XTickLabels',dayTicksLabels)
    else
        set(gca,'XTick',[])
    end
end
