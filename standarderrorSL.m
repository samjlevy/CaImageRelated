function SEM = standarderrorSL(inputVector)

nHere = sum(~isnan(inputVector));
SEM = nanstd(inputVector)/sqrt(nHere);

end