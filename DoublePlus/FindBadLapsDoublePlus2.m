function [fixedBehavior,xFixed,yFixed] = FindBadLapsDoublePlus2(xHere,yHere,originalBehavior,finalArmBoundaries)

fixedBehavior = originalBehavior;
sequences = originalBehavior.ArmSequence;
[seqs,~] = unique(sequences);
disp(['Found ' num2str(length(seqs)) ' unique behavior sequences in ' num2str(length(sequences)) ' laps'])

% Quick check for points way off the maze
%{
quickXbound = 1.25*max(finalArmBoundaries.lgDataBins.X(:));
quickYbound = 1.25*max(finalArmBoundaries.lgDataBins.Y(:));

donePts = false;
while donePts == false
figure; plot(xHere,yHere,'.k')
hold on
[inP,onP] = inpolygon(xHere,yHere,[1 1 -1 -1]*quickXbound,[-1 1 1 -1]*quickYbound); inP = inP | onP;
plot(xHere(~inP),yHere(~inP),'.r')
anyBadPts = strcmpi(input('Any bad points you want to fix now?','s'),'y');
if anyBadPts == true
    title('Draw 5 point polygon around bad pts')
    [xB,yB] = ginput(5);
    [inB,onB] = inpolygon(xHere,yHere,xB,yB); inB = inB | onB;
    inB = inB & ~inP;
end
%}

fixedLapStarts = originalBehavior.LapStart;
fixedLapStops = originalBehavior.LapStop;

numLaps = length(sequences);
deleteLaps = false(numLaps,1);
% First pass we're just looking for labs that are wildly wrong
for seqI = 1:length(seqs)
    
    redoLaps = true;
    while redoLaps==true
    theseSeq = strcmpi(sequences,seqs{seqI});
    editedSequences = sequences;
    disp(['Found ' num2str(sum(theseSeq)) ' laps that have sequence ' seqs{seqI}])

    %isOkSeq = input(['Is this ' seqs{seqI} ' an ok sequence? (y/n)>>'],'s');
    isOkSeq = 'n';
    
    epochs.starts = originalBehavior.LapStart(theseSeq);
    epochs.stops = originalBehavior.LapStop(theseSeq);
    
    editedSeqLabels = false;
    % If this sequence label is wrong, fix it
    if ~strcmpi(isOkSeq,'y')
        theseLaps = find(theseSeq);
        
        disp(['Showing laps with sequence ' seqs{seqI}])
        ab = figure('Position',[244 185 560 420]);
        plot(xHere,yHere,'.k','MarkerSize',8)
        set(gca,'Color',[0.8 0.8 0.8]);
        hold on
        for lapI = 1:length(theseLaps)
            fHere = epochs(1).starts(lapI):epochs(1).stops(lapI);
            plot(xHere(fHere),yHere(fHere),'.m')
        end
        plot(xHere(epochs(1).starts),yHere(epochs(1).starts),'.y','MarkerSize',12)
        plot(xHere(epochs(1).stops),yHere(epochs(1).stops),'.c','MarkerSize',12)
        
        if strcmpi(input('Relabel this sequence for all these laps? (y/n)','s'),'y');
            newSeq = input('What is the correct sequence: ','s');
            [editedSequences{theseLaps}] = deal(newSeq);

            editedSeqLabels = true;
        end
        
        try; close(ab); end; clear ab
                
        if strcmpi(input('View all these laps individually? (y/n)','s'),'y');
            disp('Viewing these laps individually')
            for lapI = 1:length(theseLaps)
                ab = figure;
                plot(xHere,yHere,'.k','MarkerSize',8)
                set(gca,'Color',[0.8 0.8 0.8]);
                hold on
                fHere = epochs(1).starts(lapI):epochs(1).stops(lapI);
                plot(xHere(fHere),yHere(fHere),'.m')
                plot(xHere(fHere(1)),yHere(fHere(1)),'.y','MarkerSize',12)
                plot(xHere(fHere(end)),yHere(fHere(end)),'.c','MarkerSize',12)

                if strcmpi(input('Delete this lap? (y/n)>>','s'),'y');
                    if strcmpi(input('Really? (y/n)>>','s'),'y');
                        deleteLaps(theseLaps(lapI)) = true;
                    end
                end
                    
                if strcmpi(input('Relabel sequence for this lap?','s'),'y');
                    newSeq = input(['Current sequence ' seqs{seqI} ', what is new sequence? >>'],'s');
                    editedSequences{theseLaps(lapI)} = newSeq;
                    
                    editedSeqLabels = true;
                end
                
                try; close(ab); end; clear ab
            end
        end

        if editedSeqLabels == true
            if strcmpi(input('Keep any relabeled sequences? (y/n)>>','s'),'y')
                sequences = editedSequences;
            end
        end
    end
    
    epochs.starts = originalBehavior.LapStart(theseSeq);
    epochs.stops = originalBehavior.LapStop(theseSeq);

    redoLaps = true;
    while redoLaps == true
        [fixedEpochs, reporter] = FindBadLaps(xHere, yHere, epochs);
    
    %if length(fixedEpochs(1).starts) ~= numLaps || length(fixedEpochs(1).stops) ~= numLaps
    %    keyboard
    %end
    
        switch input('Redo those laps? (y/n)','s')
            case {'y','Y'}
                redoLaps = true;
            case {'n','N'}
                redoLaps = false;
        end
    
       %if strcmpi(input('Keep any relabeled sequences? (y/n)>>','s'),'y')
       %     sequences = editedSequences;
       % end
    end
    fixedLapStarts(theseSeq) = fixedEpochs(1).starts;
    fixedLapStops(theseSeq) = fixedEpochs(1).stops;
    
    end
end


fixedBehavior.LapStart = fixedLapStarts(:);
fixedBehavior.LapStop = fixedLapStops(:);
fixedBehavior.ArmSequence = sequences;
fixedBehavior(deleteLaps,:) = [];

end