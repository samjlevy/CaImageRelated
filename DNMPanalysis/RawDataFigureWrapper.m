function RawDataFigureWrapper(trialbytrial, DIscoresLR, DIscoresST, sortedSessionInds)

scoreThresh = 0;

numSess = length(unique(trialbytrial(1).sessID));

for sessI = 1:numSess
    lrHere = DIscoresLR(:,sessI);
    stHere = DIscoresST(:,sessI);
    
    SLcells = (lrHere < -1*scoreThresh) & (stHere < -1*scoreThresh) & (sortedSessionInds(:,sessI)>0);
    SRcells = (lrHere >    scoreThresh) & (stHere < -1*scoreThresh) & (sortedSessionInds(:,sessI)>0);
    TLcells = (lrHere < -1*scoreThresh) & (stHere >    scoreThresh) & (sortedSessionInds(:,sessI)>0);
    TRcells = (lrHere >    scoreThresh) & (stHere >    scoreThresh) & (sortedSessionInds(:,sessI)>0);
       
    otherCells = ((SLcells + SRcells + TLcells + TRcells) == 0)  & (sortedSessionInds(:,sessI)>0);
    
    cellSort = [find(SLcells); find(SRcells); find(TLcells); find(TRcells); find(otherCells)]; 
    
    cellNums = [sum(SLcells) sum(SRcells) sum(TLcells) sum(TRcells) sum(otherCells)]; 
    
    SLtbt = [trialbytrial(1).trialPSAbool{trialbytrial(1).sessID==sessI}]; SLtbt = SLtbt(cellSort,:);
    SRtbt = [trialbytrial(2).trialPSAbool{trialbytrial(2).sessID==sessI}]; SRtbt = SRtbt(cellSort,:);
    TLtbt = [trialbytrial(3).trialPSAbool{trialbytrial(3).sessID==sessI}]; TLtbt = TLtbt(cellSort,:);
    TRtbt = [trialbytrial(4).trialPSAbool{trialbytrial(4).sessID==sessI}]; TRtbt = TRtbt(cellSort,:);
    
    tbtLengths = [size(SLtbt,2) size(SRtbt,2) size(TLtbt,2) size(TRtbt,2)];
    
    for aa = 1:4
        tbtBounds(aa) = sum(tbtLengths(1:aa));
    end
    
    boundMids(1) = round(tbtLengths(1)/2);
    for bb = 2:4  
        boundMids(bb) = sum(tbtLengths(1:bb-1))+ round(tbtLengths(bb)/2);
    end
    
    for ee = 1:4
        cellBounds(ee) = sum(cellNums(1:ee));
    end
    
    allTBTs = [SLtbt SRtbt TLtbt TRtbt];
    numCells = size(allTBTs,1);
    numFrames = size(allTBTs,2);
    
    figure; 
    imagesc(allTBTs)
    hold on
    for cc = 1:3
        plot([tbtBounds(cc) tbtBounds(cc)],[0 numCells],'r') 
    end
    for dd = 1:4
        plot([0 numFrames], [cellBounds(dd) cellBounds(dd)],'g') 
    end
    title(['Cell Activity Sorted by Trial Type Bias, Day ' num2str(sessI)])
    ylabel('Cells'); xlabel('Time')
    h = gcf;
    h.Children.XTick = boundMids;
    h.Children.XTickLabel = {'Study Left', 'Study Right', 'Test Left', 'Test Right'};
end

end
    