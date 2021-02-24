function [fixedBehavior] = FindBadLapsDoublePlus(xHere,yHere,originalBehavior)

fixedBehavior = originalBehavior;
sequences = originalBehavior.ArmSequence;
[seqs,~] = unique(sequences);
disp(['Found ' num2str(length(seqs)) ' unique behavior sequences in ' num2str(length(sequences)) ' laps'])

numLaps = length(sequences);
deleteLaps = false(numLaps,1);
for seqI = 1:length(seqs)
    redoLaps = true;
    while redoLaps==true
    theseSeq = strcmpi(sequences,seqs{seqI});
    editedSequences = sequences;
    disp(['Found ' num2str(sum(theseSeq)) ' laps that have sequence ' seqs{seqI}])

    isOkSeq = input(['Is this ' seqs{seqI} ' an ok sequence? (y/n)>>'],'s');
    
    epochs.starts = originalBehavior.LapStart(theseSeq);
    epochs.stops = originalBehavior.LapStop(theseSeq);
    
    if ~strcmpi(isOkSeq,'y')
        theseLaps = find(theseSeq);
        
        disp('Showing all these laps')
        ab = figure;
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
                    newSeq = input(['Current sequence ' seqs{seqI} ', what is new sequence? >>']);
                    editedSequences{theseLaps(lapI)} = newSeq;
                end
                
                try; close(ab); end; clear ab
            end
        end
    end
    
    epochs.starts = originalBehavior.LapStart(theseSeq);
    epochs.stops = originalBehavior.LapStop(theseSeq);
    
    [fixedEpochs, reporter] = FindBadLaps(xHere, yHere, epochs);
    
    if strcmpi(input(['Edited ' num2str(sum(reporter{1})) ' laps, keep those edits? (y/n)'],'s'),'y');
        if sum(reporter{1}) > 0
        fixedLapStarts(theseSeq) = fixedEpochs(1).starts;
        fixedLapStops(theseSeq) = fixedEpochs(1).stops;
        end
    end
    if strcmpi(input('Keep any relabeled sequences? (y/n)>>','s'),'y');
        sequences = editedSequences;
    end
    
    redoLaps = false;
    if strcmpi(input('Redo those laps? (y/n)','s'),'y');
        redoLaps = true;
    end
    
    end
end


fixedBehavior.LapStarts = fixedLapStarts(:);
fixedBehavior.LapStops = fixedLapStops(:);
fixedBehavior.ArmSequence = sequences;
fixedBehavior(deleteLaps,:) = [];

end