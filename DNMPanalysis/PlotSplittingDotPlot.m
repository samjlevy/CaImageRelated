function [figg] = PlotSplittingDotPlot(daybyday,trialbytrial,cellJ,presentDays,mazeLoc,trajPlotType,spikesPlot)
coloring = 'dynamic';
colorOrderSpikes = true;
radiusLimit = 1.5;
colorNormAll=true;

if isempty(spikesPlot)
    spikesPlot = 'limited';
end

if length(cellJ)==1
    cellJ = cellJ*ones(length(presentDays),1);
end

%cellI = 14
eachSpikeColor = []; ptsClose = []; maxRate = [];
conds = {'study_l','study_r','test_l','test_r'};
figg = [];
for dayI = 1:length(presentDays)
    
    cellI = cellJ(dayI);
    dayJ = presentDays(dayI);
    
    switch mazeLoc
        case {'stem','STEM'}
            %[framesWanted, colNum ] = CondExcelParseout( daybyday.frames{dayJ}, daybyday.txt{dayJ}, 'Start on maze', 0 )
            [start_stop_struct, include_struct, ~, pooled, correct, ~]...
                = GetBlockDNMPbehavior2( daybyday.frames{dayJ}, daybyday.txt{dayJ}, 'stem_extended', length(daybyday.all_x_adj_cm{dayJ}));
        case {'arm','ARM'}
            [start_stop_struct, include_struct, ~, pooled, correct, ~]...
                = GetBlockDNMPbehavior2( daybyday.frames{dayJ}, daybyday.txt{dayJ}, 'side_arm', length(daybyday.all_x_adj_cm{dayJ}));
    end
    
    [trajLaps, lapInclude, ~, ~, trajLapsCorrect, ~]...
                = GetBlockDNMPbehavior2( daybyday.frames{dayJ}, daybyday.txt{dayJ}, 'whole_lap', length(daybyday.all_x_adj_cm{dayJ}));
        
    figg{dayI} = figure('Position',[785 344 302 368]);%[785 265 399 447]
    for condI = 1:4
        gg = subplot(2,2,condI);
        
        lapsPlot = trialbytrial(condI).sessID == dayJ;    
        
        switch trajPlotType
            case 'dots'
                plot(-1*daybyday.all_y_adj_cm{dayJ}(include_struct.(conds{condI})),...
                daybyday.all_x_adj_cm{dayJ}(include_struct.(conds{condI})),'.k','MarkerSize',6)
                hold on
                
                rectangle('Position',[-7.5 -10 4.5 48],'LineWidth',3,'FaceColor',[0.5 0.5 0.5])
                rectangle('Position',[3 -10 4.5 48],'LineWidth',3,'FaceColor',[0.5 0.5 0.5])
        
                switch condI
                    case 1
                        plot([2.2 2.2],[40 50],'--','Color','k','LineWidth',3)
                        xlim([-5 5])
                    case 2
                        plot([-2.2 -2.2],[40 50],'--','Color','k','LineWidth',3)
                        xlim([-5 5])
                    case 3
                        xlim([-5 5])
                    case 4
                        xlim([-5 5])
                end

                ylim([0 50])
                title(conds{condI})
                gg.XTick = [];
                gg.YTick = [];
              
            case 'line'
                
                rectangle('Position',[-15 -20 30 70],'LineWidth',2.5,'FaceColor',[1 1 1])
                hold on
                
                goodLaps = trajLaps.(conds{condI});
                goodLaps = goodLaps(trajLapsCorrect.(conds{condI}),:);
                
                switch conds{condI}
                    case 'study_l'
                        plot([-3 3],[5 5],'k','LineWidth',2)
                        plot([3 3],[38 50],'k','LineWidth',2)
                        goodLaps(:,2) = goodLaps(:,2)+35;
                    case 'study_r'
                        plot([-3 3],[5 5],'k','LineWidth',2)
                        plot([-3 -3],[38 50],'k','LineWidth',2)
                        goodLaps(:,2) = goodLaps(:,2)+35;
                    case 'test_l'
                        goodLaps(:,1) = goodLaps(:,1)-10;
                        goodLaps(:,2) = goodLaps(:,2)-85;
                    case 'test_r'
                        goodLaps(:,1) = goodLaps(:,1)-10;
                        goodLaps(:,2) = goodLaps(:,2)-85;
                end
                
               
                for trialI = 1:size(goodLaps,1) 
                    framesPlot = goodLaps(trialI,1):goodLaps(trialI,2);
                    plot(-1*daybyday.all_y_adj_cm{dayJ}(framesPlot),daybyday.all_x_adj_cm{dayJ}(framesPlot),'k')
                    hold on
                end 
                
                rectangle('Position',[-9.5 -10 6.5 48],'LineWidth',2.5,'FaceColor',[0.6 0.6 0.6])
                rectangle('Position',[3 -10 6.5 48],'LineWidth',2.5,'FaceColor',[0.6 0.6 0.6])
                
                box off
                axis off
                xlim([-22 22])
                ylim([-20 52])
        end
        
        switch spikesPlot
            case 'limited'
                spikeX = -1*[trialbytrial(condI).trialsY{lapsPlot}];
                spikeY = [trialbytrial(condI).trialsX{lapsPlot}];
                spikePSA = [trialbytrial(condI).trialPSAbool{lapsPlot}];
                spikePSA = spikePSA(cellI,:);
                
                if strcmpi(coloring,'dynamic')
                    eachSpikeColor = DynamicColorMap(spikeX(spikePSA),spikeY(spikePSA),spikeX,spikeY,spikePDA,1,normLimit);
                    %now plot
                else
                    plot(spikeX(spikePSA),spikeY(spikePSA),'.r','MarkerSize',9)
                end
                
            case 'wholeLap'
                spikeX = -1*daybyday.all_y_adj_cm{dayJ}(lapInclude.(conds{condI}));
                spikeY = daybyday.all_x_adj_cm{dayJ}(lapInclude.(conds{condI}));
                spikePSA = daybyday.PSAbool{dayJ}(cellI,:);
                spikePSA = spikePSA(lapInclude.(conds{condI}));
                
                saveSpikesX{condI} = spikeX(spikePSA);
                saveSpikesY{condI} = spikeY(spikePSA);
                savePtsX{condI} = spikeX;
                savePtsY{condI} = spikeY;
                saveSpikesPSA{condI} = spikePSA;
                
                if strcmpi(coloring,'dynamic')
                    if sum(spikePSA)>0
                        [eachSpikeColor{condI},ptsClose{condI},maxRate(condI)] = DynamicColorMap(spikeX(spikePSA),spikeY(spikePSA),spikeX,spikeY,spikePSA,radiusLimit,[]);
                        if colorNormAll==false
                        
                        %now plot
                        spikeXX = spikeX(spikePSA);
                        spikeYY = spikeY(spikePSA);
                        for ptI = 1:length(spikeXX)
                            plot(spikeXX(ptI),spikeYY(ptI),'.','Color',eachSpikeColor{condI}(ptI,:),'MarkerSize',9)
                        end
                        end
                    else
                        eachSpikeColor{condI} = {};
                        ptsClose{condI} = {};
                        maxRate(condI) = 0;
                    end
                else
                    plot(spikeX(spikePSA),spikeY(spikePSA),'.r','MarkerSize',9)
                end
        end
        
        title(conds{condI})
    end
    
    if colorNormAll==true
        %maxClose = DynamicNormAll(saveSpikesX,saveSpikesY,savePtsX,savePtsY,saveSpikesPSA,radiusLimit);
        maxClose = max(maxRate);
        for condI = 1:4
            subplot(2,2,condI)
            
            %[eachSpikeColor,oc(condI)] = DynamicColorMap(saveSpikesX{condI},saveSpikesY{condI},savePtsX{condI},savePtsY{condI},saveSpikesPSA{condI},radiusLimit,maxClose);
            if ~isempty(ptsClose{condI})
                if colorOrderSpikes == true
                    eachSpikeColor{condI} = rateColorMap(ptsClose{condI},'jet',maxClose);
                    [~,rateIndexOrder] = sort(ptsClose{condI},'ascend');
                    reorderedX = saveSpikesX{condI}(rateIndexOrder);
                    reorderedY = saveSpikesY{condI}(rateIndexOrder);
                    reorderedColors = eachSpikeColor{condI}(rateIndexOrder,:);
                    for ptI = 1:length(saveSpikesX{condI})
                        plot(reorderedX(ptI),reorderedY(ptI),'.','Color',reorderedColors(ptI,:),'MarkerSize',9)
                    end
                else
                    for ptI = 1:length(saveSpikesX{condI})
                        plot(saveSpikesX{condI}(ptI),saveSpikesY{condI}(ptI),'.','Color',eachSpikeColor{condI}(ptI,:),'MarkerSize',9)
                    end
                end
            end
        end
    end
    
    suptitleSL(['Cell ' num2str(cellI) ', Day ' num2str(dayJ) ' on ' mazeLoc])
    
end