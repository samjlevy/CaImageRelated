AllFiguresDoublePlus

%% Demo figure for task setup



%% Performance figure

figure; hold on
patch([3.5 6.5 6.5 3.5],[0.5 0.5 1 1],[0.9 0.7 0.1294],'EdgeColor','none','FaceAlpha',0.4)
for smouseI = 1:size(sameMice,1)
    plot(realDays{sameMice(smouseI)},accuracy{sameMice(smouseI)},'.b','MarkerSize',8)
    plot(realDays{sameMice(smouseI)},accuracy{sameMice(smouseI)},'b','LineWidth',1.5)
end
for dmouseI = 1:size(sameMice,1)
    plot(realDays{diffMice(dmouseI)},accuracy{diffMice(dmouseI)},'.r','MarkerSize',8)
    plot(realDays{diffMice(dmouseI)},accuracy{diffMice(dmouseI)},'r','LineWidth',1.5)
end 
xlim([0.5 9.5])
xlabel('Day Number')
ylabel('Performance')
title('Performance over time, b = same, r = diff')

%% PV corr figure
%armAlignment = GetDoublePlusArmAlignment;
%condNames = {cellTBT{1}.name};
xBins = 1:numBins;

for dpI = 1:numDayPairs
figure; 
    for cpI = 1:4
        subplot(2,2,cpI); hold on
        allCorrsSame = sameMicePVcorrs{dpI,cpI};
        meanCorrSame = sameMicePVcorrsMeans{dpI,cpI};
        allCorrsDiff = diffMicePVcorrs{dpI,cpI};
        meanCorrDiff = diffMicePVcorrsMeans{dpI,cpI};

        switch condNames{cpI}
            case {'south','east'}
                %don't fliplr: ascending linearEdges (binEdges) will be order
                %of pfs/pvcorrs
            case {'north','west'}
                %yes fliplr: ascending linearEdges is reverse of behavior
                allCorrsSame = fliplr(allCorrsSame); meanCorrSame = fliplr(meanCorrSame);
                allCorrsDiff = fliplr(allCorrsDiff); meanCorrDiff = fliplr(meanCorrDiff);
        end

        plot(repmat(xBins,length(sameMice),1),allCorrsSame,'.c','MarkerSize',4)
        plot(repmat(xBins,length(diffMice),1),allCorrsDiff,'.m','MarkerSize',4)

        plot(xBins,meanCorrSame,'.-b','MarkerSize',6)
        plot(xBins,meanCorrDiff,'.-r','MarkerSize',6)

        ylabel('Correlation Value')
        switch condNames{cpI}
            case {'north','south'} 
                xlabel('START      CENTER')
            case {'east','west'}
                xlabel('CENTER     REWARD')
        end
        title(['PVcorrs ' condNames{cpI} ' arm'])
        
    end
    suptitleSL(['Day pair ' num2str(dayPairs(dpI,:)) ', red=diff blue=same'])
end

%% PV corr by chunk of trials