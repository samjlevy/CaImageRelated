condsUse = [1 3 4];

refDay = 3;
changeDay = 4;

% Could do this with every pair of days against day 3, 
refDays = [1:8];
changeDays = [2:9];

%perfRho = cell(numel(changeDays),numel(condsUse));
%[perfRho{:,:}] = deal(nan(numMice,nArmBins));
nRefTrials = 10;
nWindowTrials = 5;

lapsNumsHere = [];
perfHere = [];
perfP = [];
tmapRho = [];
for dpI = 1:numel(changeDays)
    refDay = refDays(dpI);
    changeDay = changeDays(dpI);
for mouseI = 1:numMice
for condI = 1:numel(condsUse)
    condJ = condsUse(condI);
    
    % Cells use...?
    % Registered both days, above thresh one
    haveCellBothDays = sum(cellSSI{mouseI}(:,[refDay changeDay]) > 0,2) == 2;
    aboveThreshOne = sum(dayUseAll{mouseI}(:,[refDay changeDay]) > 0,2) > 0;
    cellsUse = haveCellBothDays & aboveThreshOne;
    
    % Bins this arm
    binsH = lgDataBins.labels == armLabels{condJ};
    binsUse{1} = lgDataBins.X(binsH,:);
    binsUse{2} = lgDataBins.Y(binsH,:);
    
    % Reference sess trials
    %refTrials = find(cellTBT{mouseI}(condJ).sessID == refDay,10,'last'); 
    refTrials = find(cellTBT{mouseI}(condJ).sessID == refDay); 
    
    if any(refTrials)
    
    tbtSmallRef = StripTBTbyTrials(cellTBT{mouseI},condJ,refTrials);
    [refTmap,~] = RateMapsDoublePlusV2(tbtSmallRef, binsUse, 'vertices', [1], 0, 'zeroOut', [], false);
    refTmap = refTmap(:,refDay)';
    refTmap = cell2mat(refTmap)';
   
    % Trials during learning day
    changeTrialsAll = find(cellTBTall{mouseI}(condJ).sessID == changeDay);
    emptyTrials = cellfun(@isempty,cellTBTall{mouseI}(condJ).trialsX(changeTrialsAll));
    changeTrialsAll(emptyTrials) = [];
    
    nStartInds = numel(changeTrialsAll)-nWindowTrials+1;
    
    tmapRho{dpI,condI}{mouseI} = nan(numel(nStartInds),nArmBins);
    perfP{dpI,condI}{mouseI} = nan(numel(nStartInds),nArmBins);
    perfHere{dpI,condI}{mouseI} = nan(numel(nStartInds),1);
    if any(changeTrialsAll) && any(cellsUse)
        
        wStartInds = 1:1:(numel(changeTrialsAll)-nWindowTrials+1);
        %wStarts = changeTrialsAll(wStartInds);
        
        
    for wwI = 1:numel(wStartInds)
        changeTrialsUse = changeTrialsAll([wStartInds(wwI)+[0:1:(nWindowTrials-1)]]);
        
        tbtSmallChange = StripTBTbyTrials(cellTBTall{mouseI},condJ,changeTrialsUse);
        [changeTmap,~] = RateMapsDoublePlusV2(tbtSmallChange, binsUse, 'vertices', [1], 0, 'zeroOut', [], false);
        changeTmap = changeTmap(:,changeDay)';
        changeTmap = cell2mat(changeTmap)';
        
        % PV corrs
        for binI = 1:nArmBins
            [tmapRho{dpI,condI}{mouseI}(wwI,binI),perfP{dpI,condI}{mouseI}(wwI,binI)] =...
                corr(refTmap(cellsUse,binI),changeTmap(cellsUse,binI),'type','Spearman');
        end
        
        perfHere{dpI,condI}{mouseI}(wwI,1) = sum(tbtSmallChange(1).isCorrect) / numel(changeTrialsUse);
        
        lapsNumsHere{dpI,condI}{mouseI}(wwI,1) = mean(cellTBTall{mouseI}(condJ).lapNumber(changeTrialsUse));
        lapsHere{dpI,condI}{mouseI}(wwI,1) = mean(changeTrialsUse);
    end
        
    end %any changeTrials
    end %any refTrials
end
end
end

% Example
mouseI = 1; dpI = 1; condI = 1;
figure;
for binI = 1:nArmBins
    plot(1:size(tmapRho{dpI,condI}{mouseI},1),tmapRho{dpI,condI}{mouseI}(:,binI))
    hold on
end
xlabel('Trial'); ylabel(['PV corr ' upper(armLabels{condI})])
yyaxis right
plot(1:size(tmapRho{dpI,condI}{mouseI},1),perfHere{dpI,condI}{mouseI},'k','LineWidth',1.5)
ylabel('Performance last 5 trials')
suptitleSL('PV corr day 3 vs 4-5trials, N arm, mouse 1')

% Corr between performance and change in PV corr over this sliding window
oneEnvPVbyPerfRho = []; twoEnvPVbyPerfRho = [];
oneEnvPVbyPerfPval = []; twoEnvPVbyPerfPval = [];
oneEnvPVbyTimeRho = []; twoEnvPVbyTimeRho = [];
oneEnvPVbyTimePval = []; twoEnvPVbyTimePval = [];
oneEnvPerfRhoAgg = cell(numel(changeDays),numel(condsUse));
twoEnvPerfRhoAgg = cell(numel(changeDays),numel(condsUse));
oneEnvPerfAgg = cell(numel(changeDays),numel(condsUse));
twoEnvPerfAgg = cell(numel(changeDays),numel(condsUse));
oneEnvLapsAgg = cell(numel(changeDays),numel(condsUse));
twoEnvLapsAgg = cell(numel(changeDays),numel(condsUse));
oneEnvPerfRhoAcross = cell(numel(condsUse),1);
oneEnvPerfAcross = cell(numel(condsUse),1);
oneEnvLapsAcross = cell(numel(condsUse),1);
oneEnvPerfRhoWithin = cell(numel(condsUse),1);
oneEnvPerfWithin = cell(numel(condsUse),1);
oneEnvLapsWithin = cell(numel(condsUse),1);
twoEnvPerfRhoAcross = cell(numel(condsUse),1);
twoEnvPerfAcross = cell(numel(condsUse),1);
twoEnvLapsAcross = cell(numel(condsUse),1);
twoEnvPerfRhoWithin = cell(numel(condsUse),1);
twoEnvPerfWithin = cell(numel(condsUse),1);
twoEnvLapsWithin = cell(numel(condsUse),1);
for mouseI = 1:numMice
    for dpI = 1:numel(changeDays)
        for condI = 1:numel(condsUse)
            if ~isnan(perfHere{dpI,condI}{mouseI})
            for binI = 1:nArmBins
                xd = perfHere{dpI,condI}{mouseI};
                yd = tmapRho{dpI,condI}{mouseI}(:,binI);
                ld = lapsNumsHere{dpI,condI}{mouseI}(:);
                
                [rrHere,pvHere] = corr(xd,yd,'type','Spearman');
                %[rrHere2,pvHere2] = corr([1:size(perfRho{dpI,condI}{mouseI}(:,binI),1)]',perfRho{dpI,condI}{mouseI}(:,binI),'type','Spearman');
                [rrHere2,pvHere2] = corr(ld,yd,'type','Spearman');
                switch groupNum(mouseI)
                    case 1
                        oneEnvPVbyPerfRho{dpI,condI}(binI,mouseI) = rrHere;
                        oneEnvPVbyPerfPval{dpI,condI}(binI,mouseI) = pvHere;
                        % Correlation just with time (sliding window of trials
                        oneEnvPVbyTimeRho{dpI,condI}(binI,mouseI) = rrHere2;
                        oneEnvPVbyTimePval{dpI,condI}(binI,mouseI) = pvHere2;
                        
                        oneEnvPerfRhoAgg{dpI,condI} = [oneEnvPerfRhoAgg{dpI,condI}; yd(:)];
                        oneEnvPerfAgg{dpI,condI} = [oneEnvPerfAgg{dpI,condI}; xd(:)];
                        oneEnvLapsAgg{dpI,condI} = [oneEnvLapsAgg{dpI,condI}; ld];
                        %{
                        if sum(dpI == [3 6])==1
                            oneEnvPerfRhoAcross{condI} = [oneEnvPerfRhoAcross{condI}; yd(:)];
                            oneEnvPerfAcross{condI} = [oneEnvPerfAcross{condI}; xd(:)];
                            oneEnvLapsAcross{condI} = [oneEnvLapsAcross{condI}; ld(:)];
                        else
                            oneEnvPerfRhoWithin{condI} = [oneEnvPerfRhoWithin{condI}; yd(:)];
                            oneEnvPerfWithin{condI} = [oneEnvPerfWithin{condI}; xd(:)];
                            oneEnvLapsWithin{condI} = [oneEnvLapsWithin{condI}; ld(:)];
                        end
                        %}
                    case 2
                        twoEnvPVbyPerfRho{dpI,condI}(binI,mouseI-3) = rrHere;
                        twoEnvPVbyPerfPval{dpI,condI}(binI,mouseI-3) = pvHere;
                        twoEnvPVbyTimeRho{dpI,condI}(binI,mouseI-3) = rrHere2;
                        twoEnvPVbyTimePval{dpI,condI}(binI,mouseI-3) = pvHere2;
                        
                        twoEnvPerfRhoAgg{dpI,condI} = [twoEnvPerfRhoAgg{dpI,condI}; yd(:)];
                        twoEnvPerfAgg{dpI,condI} = [twoEnvPerfAgg{dpI,condI}; xd(:)];
                        twoEnvLapsAgg{dpI,condI} = [twoEnvLapsAgg{dpI,condI}; ld];
                        %{
                        if sum(dpI == [3 6])==1
                            twoEnvPerfRhoAcross{condI} = [twoEnvPerfRhoAcross{condI}; yd(:)];
                            twoEnvPerfAcross{condI} = [twoEnvPerfAcross{condI}; xd(:)];
                            twoEnvLapsAcross{condI} = [twoEnvLapsAcross{condI}; ld(:)];
                        else
                            twoEnvPerfRhoWithin{condI} = [twoEnvPerfRhoWithin{condI}; yd(:)];
                            twoEnvPerfWithin{condI} = [twoEnvPerfWithin{condI}; xd(:)];
                            twoEnvLapsWithin{condI} = [twoEnvLapsWithin{condI}; ld(:)];
                        end
                        %}
                end
            end
            end
        end
    end
end

dpI = 3;
for dpI = 1:numel(changeDays)
figure('Position',[107.5000 64.5000 818 732.5000]);
for condI = 1:numel(condsUse)
subplot(3,2,condI*2-1)
plot(oneEnvPerfAgg{dpI,condI},oneEnvPerfRhoAgg{dpI,condI},'.','MarkerFaceColor',groupColors{1},'MarkerEdgeColor',groupColors{1})
% could replace that with scatterbox
[rrr,ppp] = corr(oneEnvPerfAgg{dpI,condI},oneEnvPerfRhoAgg{dpI,condI},'type','Spearman');
xlabel('Performance'); ylabel('PV Corr (rho)'); title([upper(armLabels{condsUse(condI)}) ' OneMaze, rho=' num2str(rrr) ', p=' num2str(ppp)])
%ylim([-0.2 0.6]); xlim([-0.05 1.05])
subplot(3,2,condI*2)
plot(twoEnvPerfAgg{dpI,condI},twoEnvPerfRhoAgg{dpI,condI},'.','MarkerFaceColor',groupColors{2},'MarkerEdgeColor',groupColors{2})
[rrr,ppp] = corr(twoEnvPerfAgg{dpI,condI},twoEnvPerfRhoAgg{dpI,condI},'type','Spearman');
xlabel('Performance'); ylabel('PV Corr (rho)'); title([upper(armLabels{condsUse(condI)}) ' TwoMaze, rho=' num2str(rrr) ', p=' num2str(ppp)])
ylim([-0.2 0.6]); xlim([-0.05 1.05])
end
suptitleSL(['Performance Day ' num2str(refDays(dpI)) ' vs. ' num2str(changeDays(dpI))])

figure('Position',[718.5000 62.5000 818 732.5000]);
for condI = 1:numel(condsUse)
subplot(3,2,condI*2-1)
plot(oneEnvLapsAgg{dpI,condI},oneEnvPerfRhoAgg{dpI,condI},'.','MarkerFaceColor',groupColors{1},'MarkerEdgeColor',groupColors{1})
% could replace that with scatterbox
[rrr,ppp] = corr(oneEnvLapsAgg{dpI,condI},oneEnvPerfRhoAgg{dpI,condI},'type','Spearman');
xlabel('Mean Lap Number'); ylabel('PV Corr (rho)'); title([upper(armLabels{condsUse(condI)}) ' OneMaze, rho=' num2str(rrr) ', p=' num2str(ppp)])
%ylim([-0.2 0.6]); xlim([-0.05 1.05])
subplot(3,2,condI*2)
plot(twoEnvLapsAgg{dpI,condI},twoEnvPerfRhoAgg{dpI,condI},'.','MarkerFaceColor',groupColors{2},'MarkerEdgeColor',groupColors{2})
[rrr,ppp] = corr(twoEnvLapsAgg{dpI,condI},twoEnvPerfRhoAgg{dpI,condI},'type','Spearman');
xlabel('Mean Lap Number'); ylabel('PV Corr (rho)'); title([upper(armLabels{condsUse(condI)}) ' TwoMaze, rho=' num2str(rrr) ', p=' num2str(ppp)])
%ylim([-0.2 0.6]); xlim([-0.05 1.05])
end
suptitleSL(['Laps Day ' num2str(refDays(dpI)) ' vs. ' num2str(changeDays(dpI))])
end

% Within/Across aggregated
figure('Position',[107.5000 64.5000 818 732.5000]);
for condI = 1:numel(condsUse)
subplot(3,2,condI*2-1)
plot(oneEnvPerfAcross{condI},oneEnvPerfRhoAcross{condI},'.','MarkerFaceColor',groupColors{1},'MarkerEdgeColor',groupColors{1})
% could replace that with scatterbox
[rrr,ppp] = corr(oneEnvPerfAcross{condI},oneEnvPerfRhoAcross{condI},'type','Spearman');
xlabel('Performance'); ylabel('PV Corr (rho)'); title([upper(armLabels{condsUse(condI)}) ' OneMaze, rho=' num2str(rrr) ', p=' num2str(ppp)])
%ylim([-0.2 0.6]); xlim([-0.05 1.05])
subplot(3,2,condI*2)
plot(twoEnvPerfAcross{condI},twoEnvPerfRhoAcross{condI},'.','MarkerFaceColor',groupColors{2},'MarkerEdgeColor',groupColors{2})
[rrr,ppp] = corr(twoEnvPerfAcross{condI},twoEnvPerfRhoAcross{condI},'type','Spearman');
xlabel('Performance'); ylabel('PV Corr (rho)'); title([upper(armLabels{condsUse(condI)}) ' TwoMaze, rho=' num2str(rrr) ', p=' num2str(ppp)])
%ylim([-0.2 0.6]); xlim([-0.05 1.05])
end
suptitleSL(['Performance Day Pairs Across rule'])


figure('Position',[107.5000 64.5000 818 732.5000]);
for condI = 1:numel(condsUse)
subplot(3,2,condI*2-1)
plot(oneEnvPerfWithin{condI},oneEnvPerfRhoWithin{condI},'.','MarkerFaceColor',groupColors{1},'MarkerEdgeColor',groupColors{1})
% could replace that with scatterbox
[rrr,ppp] = corr(oneEnvPerfWithin{condI},oneEnvPerfRhoWithin{condI},'type','Spearman');
xlabel('Performance'); ylabel('PV Corr (rho)'); title([upper(armLabels{condsUse(condI)}) ' OneMaze, rho=' num2str(rrr) ', p=' num2str(ppp)])
%ylim([-0.2 0.6]); xlim([-0.05 1.05])
subplot(3,2,condI*2)
plot(twoEnvPerfWithin{condI},twoEnvPerfRhoWithin{condI},'.','MarkerFaceColor',groupColors{2},'MarkerEdgeColor',groupColors{2})
[rrr,ppp] = corr(twoEnvPerfWithin{condI},twoEnvPerfRhoWithin{condI},'type','Spearman');
xlabel('Performance'); ylabel('PV Corr (rho)'); title([upper(armLabels{condsUse(condI)}) ' TwoMaze, rho=' num2str(rrr) ', p=' num2str(ppp)])
%ylim([-0.2 0.6]); xlim([-0.05 1.05])
end
suptitleSL(['Performance Day Pairs Within rule'])




for dpI = 1:numel(changeDays)
    figure('Position',[306 253 930.5000 322.5000]);
    for condI = 1:numel(condsUse)
        subplot(2,3,condI)
        %subplot(1,3,condI)
        for binI = 1:nArmBins
            datA = oneEnvPVbyPerfRho{dpI,condI}(binI,:); datAp = oneEnvPVbyPerfPval{dpI,condI}(binI,:);
            datB = twoEnvPVbyPerfRho{dpI,condI}(binI,:); datBp = twoEnvPVbyPerfPval{dpI,condI}(binI,:);
            plot(binI*ones(numel(datA),1),datA,'.','MarkerFaceColor',groupColors{1},'MarkerEdgeColor',groupColors{1})
            hold on
            plot(binI*ones(numel(datB),1),datB,'.','MarkerFaceColor',groupColors{2},'MarkerEdgeColor',groupColors{2})
            % Pvals
            pGood = datAp(:) < 0.05;
            plot(binI*ones(sum(pGood),1),datA(pGood),'*','MarkerFaceColor',groupColors{1},'MarkerEdgeColor',groupColors{1})
            pGood = datBp(:) < 0.05;
            plot(binI*ones(sum(pGood),1),datB(pGood),'*','MarkerFaceColor',groupColors{2},'MarkerEdgeColor',groupColors{2})
        end
        xlabel('Bin Number'); ylabel('rho value'); xlim([0.5 nArmBins+0.5]); ylim([-1 1])
        title(['Arm ' armLabels{condsUse(condI)}])
        
        subplot(2,3,condI+3)
        for binI = 1:nArmBins
            datA = oneEnvPVbyTimeRho{dpI,condI}(binI,:); datAp = oneEnvPVbyTimePval{dpI,condI}(binI,:);
            datB = twoEnvPVbyTimeRho{dpI,condI}(binI,:); datBp = twoEnvPVbyTimePval{dpI,condI}(binI,:);
            plot(binI*ones(numel(datA),1),datA,'.','MarkerFaceColor',groupColors{1},'MarkerEdgeColor',groupColors{1})
            hold on
            plot(binI*ones(numel(datB),1),datB,'.','MarkerFaceColor',groupColors{2},'MarkerEdgeColor',groupColors{2})
            % Pvals
            pGood = datAp(:) < 0.05;
            plot(binI*ones(sum(pGood),1),datA(pGood),'*','MarkerFaceColor',groupColors{1},'MarkerEdgeColor',groupColors{1})
            pGood = datBp(:) < 0.05;
            plot(binI*ones(sum(pGood),1),datB(pGood),'*','MarkerFaceColor',groupColors{2},'MarkerEdgeColor',groupColors{2})
        end
        xlabel('Bin Number'); ylabel('rho value'); xlim([0.5 nArmBins+0.5]); ylim([-1 1])
        title(['Arm ' armLabels{condsUse(condI)}])
        %}
    end
    
    suptitleSL(['Similarity day ' num2str(changeDays(dpI)) ' to day ' num2str(refDay) ', top performance bottom lap number'])
end

for dpI = 1:4
    for condI = 1:numel(condsUse)
    datHereA = oneEnvPVbyPerfRho{dpI,condI}(:);
    datHereB = twoEnvPVbyPerfRho{dpI,condI}(:);
    datHereC = oneEnvPVbyTimeRho{dpI,condI}(:);
    datHereD = twoEnvPVbyTimeRho{dpI,condI}(:);
    
    sigPa = sum(oneEnvPVbyPerfPval{dpI,condI}(:)<0.05);
    sigPb = sum(twoEnvPVbyPerfPval{dpI,condI}(:)<0.05);
    sigPc = sum(oneEnvPVbyTimePval{dpI,condI}(:)<0.05);
    sigPd = sum(twoEnvPVbyTimePval{dpI,condI}(:)<0.05);
    
    x = [datHereA(:); datHereB(:); datHereC(:); datHereD(:)];
    grps = [ones(size(datHereA(:))); 2*ones(size(datHereB(:))); 3*ones(size(datHereC(:))); 4*ones(size(datHereD(:)))];
    
    figure;
    scatterBoxSL(x,grps,'xLabels',{['One Acc ' num2str(sigPa)],['Two Acc ' num2str(sigPb)],...
        ['One Time ' num2str(sigPc)],['Two Time ' num2str(sigPd)]})
    ylabel('rho Values')
    
    [p,tbl,stats] = kruskalwallis(x,grps)
    c = multcompare(stats) 

% Where each bin by typical indexing...
figure;
for condJ = condsUse
   binsH = lgDataBins.labels == armLabels{condJ};
    binsUse{1} = lgDataBins.X(binsH,:);
    binsUse{2} = lgDataBins.Y(binsH,:);
    
  plot(binsUse{1}(:),binsUse{2}(:),'*')
  hold on
  for binI = 1:nArmBins
      text(mean(binsUse{1}(binI,:)),mean(binsUse{2}(binI,:)),num2str(binI))
  end
end