function [figHand,statsOut] = FirstHalfVsSecondHaldf(CSpooledPVcorrs,CSpooledPVdaysApart,pvNames,condSetColors,binsFromEnd)
%condSetColors needs to be 3 number format

numBins = size(CSpooledPVcorrs{1}{1},2);
numConds = length(CSpooledPVcorrs{1});

startBins = 1:binsFromEnd; startLabel = ['Bins 1-' num2str(startBins(end))];
endBins = (numBins-binsFromEnd+1):numBins; endLabel = ['Bins ' num2str(endBins(1)) '-' num2str(endBins(end))];
[labs{1:2:(numConds*2-1)}] = deal(startLabel);
[labs{2:2:(numConds*2)}] = deal(endLabel);

figHand = figure('Position',[680 147 1088 831]); qq = [];
for pvtI = 1:length(pvNames)
    qq{pvtI} = subplot(2,3,pvtI);    
    startC = [];
    endC = [];
    scatData = [];
    scatBin = [];
    scatColors = [];
    for csI = 1:numConds
        errorHere = [];
        withinDay = CSpooledPVdaysApart{pvtI}{csI}==0;
        
        startC{csI} = mean(CSpooledPVcorrs{pvtI}{csI}(withinDay,startBins),2);
        endC{csI} = mean(CSpooledPVcorrs{pvtI}{csI}(withinDay,endBins),2);
        
        [statsOut{pvtI}.signTest.pVal(csI),statsOut{pvtI}.signTest.hVal(csI)] = signtest(startC{csI},endC{csI});
        
        scatData = [scatData; startC{csI}; endC{csI}];
        scatBin = [scatBin; (csI*2-1)*ones(length(startC{csI}),1); (csI*2)*ones(length(endC{csI}),1)];
        scatColors = [scatColors; repmat(condSetColors{csI}, length(startC{csI})+length(endC{csI}),1)];
    end
    
    scatterBoxSL(scatData,scatBin,'circleColors',scatColors,'yLabel','MeanCorrelation','xLabels',labs,'Transparency',1)
    hold on
    title(pvNames{pvtI})
    for csI = 1:numConds
        plot([(csI*2)-1 (csI*2)],[0.9 0.9],'k','LineWidth',1.5)
        switch statsOut{pvtI}.signTest.hVal(csI)
            case 0
                txtPlot = ['n.s p=' num2str(statsOut{pvtI}.signTest.pVal(csI))];
            case 1
                txtPlot = ['* p=' num2str(statsOut{pvtI}.signTest.pVal(csI))];
        end
        text(csI*2-0.5,0.92,txtPlot,'HorizontalAlignment','center')
    end
    qq{pvtI}.YLim(2) = 1;
end 

end
    