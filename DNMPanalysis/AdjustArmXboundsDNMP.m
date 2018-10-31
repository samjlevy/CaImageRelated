function adjEpochs = AdjustArmXboundsDNMP(daybyday)%, stemXlims
rightDirThresh = 0.75;
armXlims = [5 35];

numSess = length(daybyday.all_x_adj_cm);

for sessI = 1:numSess
    disp(['Working on session ' num2str(sessI)])
    %figure; plot(daybyday.all_x_adj_cm{sessI},daybyday.all_y_adj_cm{sessI},'.k'); hold on
    
    sStartsInd = find(strcmpi(daybyday.txt{sessI}(1,:),'Forced Choice'));
    sStopsInd = find(strcmpi(daybyday.txt{sessI}(1,:),'Forced Reward'));
    tStartsInd = find(strcmpi(daybyday.txt{sessI}(1,:),'Free Choice'));
    tStopsInd = find(strcmpi(daybyday.txt{sessI}(1,:),'Free Reward'));
    
    [right_forced, left_forced, right_free, left_free] =...
        DNMPtrialDirections(daybyday.frames{sessI}, daybyday.txt{sessI});
    
    epochs(1).starts = daybyday.frames{sessI}(left_forced,sStartsInd);
    epochs(1).stops = daybyday.frames{sessI}(left_forced,sStopsInd);
    epochs(2).starts = daybyday.frames{sessI}(right_forced,sStartsInd);
    epochs(2).stops = daybyday.frames{sessI}(right_forced,sStopsInd);
    epochs(3).starts = daybyday.frames{sessI}(left_free,tStartsInd);
    epochs(3).stops = daybyday.frames{sessI}(left_free,tStopsInd);
    epochs(4).starts = daybyday.frames{sessI}(right_free,tStartsInd);
    epochs(4).stops = daybyday.frames{sessI}(right_free,tStopsInd);
    
    for aa = 1:4
        [epochs(aa), reporter{aa}] = FindBadLaps(...
            daybyday.all_x_adj_cm{sessI}, daybyday.all_y_adj_cm{sessI}, epochs(aa));
    end
    
    reporter = [];
    newEpochs = [];
    fixedEpochs = [];
    for ee = 1:4
        nLaps = length(epochs(ee).starts);
        for lapI = 1:nLaps
            framesHere = epochs(ee).starts(lapI):epochs(ee).stops(lapI);
            framesFlipped = fliplr(framesHere);
            
            xPosHere = daybyday.all_x_adj_cm{sessI}(framesHere);
            yPosHere = daybyday.all_y_adj_cm{sessI}(framesHere);
            
            newEpochs(ee).starts(lapI) = framesHere(find(xPosHere > max(armXlims),1,'last'));
            newEpochs(ee).stops(lapI) = framesHere(find(xPosHere < min(armXlims),1,'first'));
            %{
            gf = figure;
            plot(daybyday.all_x_adj_cm{sessI},daybyday.all_y_adj_cm{sessI},'.k')
            set(gca,'Color',[0.8 0.8 0.8]);
            hold on
            plot(xPosHere,yPosHere,'.c');
            plot(xPosHere(1),yPosHere(1),'*y');
            plot(xPosHere(end),yPosHere(end),'*y');
            newFramesHere = newEpochs(ee).starts(lapI):newEpochs(ee).stops(lapI);
            newxPosHere = daybyday.all_x_adj_cm{sessI}(newFramesHere);
            newyPosHere = daybyday.all_y_adj_cm{sessI}(newFramesHere);
            plot(newxPosHere,newyPosHere,'.r')
            plot(newxPosHere(1),newyPosHere(1),'*g');
            plot(newxPosHere(end),newyPosHere(end),'*g');
            lapG = input('is the lap good? (0/1)>>','s');
            if strcmpi(lapG,'0')
                keyboard
            end
            %}
        end
        
        %[fixedEpochs(ee), reporter] = FindBadLaps(...
        %    daybyday.all_x_adj_cm{sessI}, daybyday.all_y_adj_cm{sessI}, newEpochs(ee));
    end
    
    %Manually check for points outside of bounds
    for aa = 1:4
        [fixedEpochs(aa), reporter{aa}] = FindBadLaps(...
            daybyday.all_x_adj_cm{sessI}, daybyday.all_y_adj_cm{sessI}, newEpochs(aa));
    end
    
    %Check laps are generally going in the right direction
    goodDir = LapInOneDirection(daybyday.all_x_adj_cm{sessI}, daybyday.all_y_adj_cm{sessI},...
        fixedEpochs, 'x', 'neg');
    lapIsGoodDir = cellfun(@(x) x>rightDirThresh,goodDir,'UniformOutput',false);
    for eeI = 1:4 
        badLaps = [];
        badLaps = find(lapIsGoodDir{eeI}==0);
        if any(badLaps)
            disp('found laps in the wrong direction')
            %keyboard 
            for blI = 1:length(badLaps)
                blStart = fixedEpochs(eeI).starts(badLaps(blI));
                blStop = fixedEpochs(eeI).stops(badLaps(blI));
                bf = figure; 
                plot(daybyday.all_x_adj_cm{sessI},daybyday.all_y_adj_cm{sessI},'.k'); hold on
                plot([min(armXlims) min(armXlims)],[-20 20],'g')
                plot([max(armXlims) max(armXlims)],[-20 20],'g')
                plot(daybyday.all_x_adj_cm{sessI}(blStart:blStop),daybyday.all_y_adj_cm{sessI}(blStart:blStop),'.r')
                
                disp(['Session ' num2str(sessI) ', condition ' num2str(eeI) ', lap '...
                    num2str(badLaps(blI)) ', frames ' num2str(blStart) ' to ' num2str(blStop)])
                
                adjNow = input('adjust (a), delete (d), ignore (i)this lap? >>','s');
                switch adjNow
                    case {'a','A'}
                    doneAdj = 0;
                    while doneAdj == 0
                    [newStart, newStop] = ManualLapAdjuster(daybyday.all_x_adj_cm{sessI},...
                            daybyday.all_y_adj_cm{sessI},blStart,blStop);
                        wasGood = input('was this good (y) or redo (n)?','s');
                        if strcmpi(wasGood,'y')
                            fixedEpochs(eeI).starts(badLaps(blI)) = newStart;
                            fixedEpochs(eeI).stops(badLaps(blI)) = newStop;
                            doneAdj = 1;
                        elseif strcmpi(wasGood,'n')
                            doneAdj = 0;
                        end
                    end 
                    case {'d','D'}
                         fixedEpochs(eeI).starts(badLaps(blI)) = [];
                         fixedEpochs(eeI).stops(badLaps(blI)) = [];
                end
                try
                    close(bf);
                end
            end
        end
    end
     
    adjEpochs{sessI} = fixedEpochs;
end
    