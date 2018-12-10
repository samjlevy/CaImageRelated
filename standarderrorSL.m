function SEM = standarderrorSL(inputVector)

SEM = nanstd(inputVector)/sqrt(length(inputVector));

end