function trialsCorrect = ParseCorrectAlternation(lapString)

leftTrials = cell2mat(cellfun(@(x) strcmpi(x,'l'),lapString,'UniformOutput',false));

trialsCorrect = [1; abs(diff(leftTrials))];
end