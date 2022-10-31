function plusBehaviorChecker(filePath)

load(filePath)

seqLengths = cellfun(@length,trialSeqs);

if any(seqLengths==1)
    keyboard
end

%if seqLength == 1
    % Check if this label is the same as the start of the next sequence or
    % the end of the last one

    % if so, then show this lap, the next one, and the points connecting
    % them (or previous)
    
    %ask if want to combine or delete 



%end

end