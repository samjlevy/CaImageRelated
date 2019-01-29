function [axH,statsOut]=PlotWithinDayDecoding(decResults,shuffledResults,sessDayDiffs,typeLabels,dimLabels,colors)

axH = figure;

dTypes = length(decResults);
dDims = length(decResults{1});

compsMake = GetAllCombs(1:dTypes, 1:dDims);
withinCompsMake = compsMake; 
acrossCompsMake = fliplr(compsMake);

allDat = [];
markers = [];
allColors = [];
allShuff = [];
shuffMarkers = [];
%for dtI = 1:length(dTypes)
%    for ddI = 1:length(dDims)
for cmI = 1:size(compsMake,1)
    dtI = compsMake(cmI,1);
    ddI = compsMake(cmI,2);
    
    datDay{dtI}{ddI} = decResults{dtI}{ddI}(sessDayDiffs{dtI}{ddI}==0);
    
    shuffTemp = shuffledResults{dtI}{ddI}(sessDayDiffs{dtI}{ddI}==0,:,:);
    shuffDay{dtI}{ddI} = shuffTemp(:);
        
    allDat = [allDat; datDay{dtI}{ddI}(:)];
    markers = [markers; cmI*ones(length(datDay{dtI}{ddI}),1)];
    allColors = [allColors; repmat(colors{dtI}{ddI},length(datDay{dtI}{ddI}),1)];
    
    allShuff = [allShuff; shuffDay{dtI}{ddI}];
    shuffMarkers = [shuffMarkers; cmI*ones(length(shuffDay{dtI}{ddI}),1)];
    
    labelsUse{cmI} = [upper(typeLabels{dtI}) ' ' upper(dimLabels{ddI})];
end

scatterBoxSL(allShuff,shuffMarkers,'xLabels',labelsUse,'transparency',0.2,'plotBox',false)
hold on
scatterBoxSL(allDat,markers,'xLabels',labelsUse,'transparency',1,'plotBox',true,'circleColors',allColors)
    
ylim([0 1.1])
ylabel('Decoding Accuracy')

%Comparisons
for wcI = 1:size(withinCompsMake,1)/2
    [p,h] = signtest(datDay{withinCompsMake(wcI*2-1,1)}{withinCompsMake(wcI*2-1,2)},...
                     datDay{withinCompsMake(wcI*2,1)}{withinCompsMake(wcI*2,2)});
    plot([wcI*2-1 wcI*2],[1.05 1.05],'k','LineWidth',2)
    text(mean([wcI*2-1 wcI*2]),1.07,['p = ' num2str(p)],'HorizontalAlignment','center')
    statsOut.within(wcI).p = p;
end

heights = [1:size(acrossCompsMake,1)/2]/10;
xPlot = [1 dDims+1];
for acI = 1:size(acrossCompsMake,1)/2
    [p,h] = signtest(datDay{acrossCompsMake(acI*2-1,1)}{acrossCompsMake(acI*2-1,2)},...
                     datDay{acrossCompsMake(acI*2,1)}{acrossCompsMake(acI*2,2)});
    plot(xPlot+acI-1,heights(acI)*[1 1],'k','LineWidth',2)
    text(mean(xPlot+acI-1),heights(acI)-0.03,['p = ' num2str(p)],'HorizontalAlignment','center')             
    statsOut.across(acI).p = p;
end


end
%{
for dtI = 1:length(decodingType)
    figure;
    datSTEMlr = decodingResultsPooled{1}{dtI}{1}(sessDayDiffs{1}{dtI}{1}==0);
    datSTEMst = decodingResultsPooled{1}{dtI}{2}(sessDayDiffs{1}{dtI}{2}==0);
    datARMlr = decodingResultsPooled{2}{dtI}{1}(sessDayDiffs{2}{dtI}{1}==0);
    datARMst = decodingResultsPooled{2}{dtI}{2}(sessDayDiffs{2}{dtI}{2}==0);
     
     
    allDat = [datSTEMlr; datSTEMst; datARMlr; datARMst];
    markers = [1*ones(length(datSTEMlr),1); 2*ones(length(datSTEMst),1); 3*ones(length(datARMlr),1); 4*ones(length(datARMst),1)];
    colors = [repmat(colorAssc{1},length(datSTEMlr),1); repmat(colorAssc{2},length(datSTEMst),1);...
                repmat(colorAssc{1},length(datARMlr),1); repmat(colorAssc{2},length(datARMst),1)];
     
    shuffSTEMlr = shuffledResultsPooled{1}{dtI}{1}(sessDayDiffs{1}{dtI}{1}==0,:,:); shuffSTEMlr = shuffSTEMlr(:);
    shuffSTEMst = shuffledResultsPooled{1}{dtI}{2}(sessDayDiffs{1}{dtI}{2}==0,:,:); shuffSTEMst = shuffSTEMst(:);
    shuffARMlr = shuffledResultsPooled{2}{dtI}{1}(sessDayDiffs{2}{dtI}{1}==0,:,:); shuffARMlr = shuffARMlr(:);
    shuffARMst = shuffledResultsPooled{2}{dtI}{2}(sessDayDiffs{2}{dtI}{2}==0,:,:); shuffARMst = shuffARMst(:);
     
    shuffDat = [shuffSTEMlr; shuffSTEMst; shuffARMlr; shuffARMst];
    shuffMarkers = [1*ones(length(shuffSTEMlr),1); 2*ones(length(shuffSTEMst),1); 3*ones(length(shuffARMlr),1); 4*ones(length(shuffARMst),1)];
     
    scatterBoxSL(shuffDat,shuffMarkers,'xLabels',{'STEM LR','STEM ST','ARM LR','ARM ST'},'transparency',0.2,'plotBox',false)
    hold on
    scatterBoxSL(allDat,markers,'xLabels',{'STEM LR','STEM ST','ARM LR','ARM ST'},'transparency',1,'plotBox',true,'circleColors',colors)
     
    title(['Within-day decoding using ' decodingType{dtI} ' cells'])
    ylim([0 1.1])
    ylabel('Decoding Accuracy')
    
    [p,h] = signtest(datSTEMlr,datSTEMst);
    plot([1 2],[1.05 1.05],'k','LineWidth',2)
    text(1.5,1.07,['p = ' num2str(p)],'HorizontalAlignment','center') 
    
    [p,h] = signtest(datARMlr,datARMst);
    plot([3 4],[1.05 1.05],'k','LineWidth',2)
    text(3.5,1.07,['p = ' num2str(p)],'HorizontalAlignment','center') 
    
    [p,h] = signtest(datSTEMlr,datARMlr);
    plot([1 3],[0.2 0.2],'k','LineWidth',2)
    text(2,0.17,['p = ' num2str(p)],'HorizontalAlignment','center') 
    
    [p,h] = signtest(datSTEMst,datARMst);
    plot([2 4],[0.1 0.1],'k','LineWidth',2)
    text(3,0.07,['p = ' num2str(p)],'HorizontalAlignment','center')     
end
%}