function [fakeLapNumber] = AllLapNumbersCorrect(lapNumber)

fakeLapNumber = lapNumber;
ss = fieldnames(lapNumber);
for aa = 1:length(lapNumber)
    for bb = 1:length(ss)
        fakeLapNumber(aa).(ss{bb}).correct = fakeLapNumber(aa).(ss{bb}).all;
    end
end

end