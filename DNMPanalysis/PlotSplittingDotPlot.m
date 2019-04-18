function [figg] = PlotSplittingDotPlot(daybyday,trialbytrial,cellI,presentDays,mazeLoc,trajPlotType,spikesPlot)

if isempty(spikesPlot)
    spikesPlot = 'limited';
end

%cellI = 14
conds = {'study_l','study_r','test_l','test_r'};
figg = [];
for dayI = 1:length(presentDays)
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
    
    [trajLaps, ~, ~, ~, trajLapsCorrect, ~]...
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
                spikeX = [trialbytrial(condI).trialsY{lapsPlot}];
                spikeY = [trialbytrial(condI).trialsX{lapsPlot}];
                spikePSA = [trialbytrial(condI).trialPSAbool{lapsPlot}];
                spikePSA = spikePSA(cellI,:);
                plot(-1*spikeX(spikePSA),spikeY(spikePSA),'.r','MarkerSize',9)
            case 'wholeLap'
                spikeX = -1*daybyday.all_y_adj_cm{dayJ}(include_struct.(conds{condI}));
                spikeY = daybyday.all_x_adj_cm{dayJ}(include_struct.(conds{condI}));
                spikePSA = daybyday.PSAbool{dayJ}(cellI,:);
                spikePSA = spikePSA(include_struct.(conds{condI}));
                plot(spikeX(spikePSA),spikeY(spikePSA),'.r','MarkerSize',9)
        end
        
        title(conds{condI})
    end
    
    suptitleSL(['Cell ' num2str(cellI) ', Day ' num2str(dayJ) ' on ' mazeLoc])
    
end