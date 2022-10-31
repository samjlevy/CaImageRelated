function behFileEditor(filePath)

load(filePath)

doneDelete = false;
lapsDel = false(numel(trialEpoch),1);
while doneDelete==false
    lapDel = str2double(input('Enter lap number to delete: ','s'));

    conf = strcmpi(input(['Delete lap ' num2str(lapDel) '? (y/n):'],'s'),'y');

    if conf == true
        lapsDel(lapDel) = true;
    end

    ddd = strcmpi(input('Done deleting laps? (y/n)','s'),'y');
    if ddd == true
        doneDelete = true;
    end
end

trialSeqs = trialSeqs(~lapsDel);
trialBounds = trialBounds(~lapsDel); 
trialEpoch = trialEpoch(~lapsDel);
trialSeqEpochs = trialSeqEpochs(~lapsDel);

save(filePath,'trialSeqs','trialSeqEpochs','trialBounds','trialEpoch')
end


