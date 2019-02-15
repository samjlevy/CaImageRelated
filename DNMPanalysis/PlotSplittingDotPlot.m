function PlotSplittingDotPlot(daybyday,trialbytrial,cellI,presentDays,mazeLoc,trajType


for dayI = 1:length(presentDays)
    dayJ = presentDays(dayI);
    
    switch mazeLoc
        case 'stem'
            %[framesWanted, colNum ] = CondExcelParseout( daybyday.frames{dayJ}, daybyday.txt{dayJ}, 'Start on maze', 0 )
            [start_stop_struct, include_struct, ~, pooled, correct, ~]...
                = GetBlockDNMPbehavior2( daybyday.frames{dayJ}, daybyday.txt{dayJ}, 'stem_extended', length(daybyday.all_x_adj_cm{dayJ}));
        case 'arm'
            
    end
    
    conds = {'study_l','study_r','test_l','test_r'};
    
    
    
    figure('Position',[785 265 399 447]);
    for condI = 1:4
        gg = subplot(2,2,condI);
        plot(-1*daybyday.all_y_adj_cm{dayJ}(include_struct.(conds{condI})),...
             daybyday.all_x_adj_cm{dayJ}(include_struct.(conds{condI})),'.k','MarkerSize',6)
        hold on
        
        lapsPlot = trialbytrial(condI).sessID == dayJ;
        
        spikeX = [trialbytrial(condI).trialsY{lapsPlot}];
        spikeY = [trialbytrial(condI).trialsX{lapsPlot}];
        spikePSA = [trialbytrial(condI).trialPSAbool{lapsPlot}];
        spikePSA = spikePSA(cellI,:);
        plot(-1*spikeX(spikePSA),spikeY(spikePSA),'.r','MarkerSize',9)
        
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
    end
    
    suptitleSL(['Cell ' num2str(cellI) ', Day ' num2str(dayJ) ' on ' mazeLoc])
    
end

for trialI = 1:35
    framesPlot = daybyday.frames{dayJ}(trialI,2):daybyday.frames{dayJ}(trialI,4);
    plot(-1*daybyday.all_y_adj_cm{1}(framesPlot),daybyday.all_x_adj_cm{1}(framesPlot),'k')
    hold on
end