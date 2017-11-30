function [fixedLapNumber] = AdjustLapNumbers(lapNumber)

fixedLapNumber = lapNumber;

condss = fieldnames(lapNumber);
ss = fieldnames(lapNumber(1).(condss{1}));

for ln = 1:length(lapNumber)
    for aa = 1:length(ss)
        fixedLapNumber(ln).study_l.(ss{aa}) = fixedLapNumber(ln).study_l.(ss{aa})*2-1;
        fixedLapNumber(ln).study_r.(ss{aa}) = fixedLapNumber(ln).study_r.(ss{aa})*2-1;
    
        fixedLapNumber(ln).test_l.(ss{aa}) = fixedLapNumber(ln).test_l.(ss{aa})*2;
        fixedLapNumber(ln).test_r.(ss{aa}) = fixedLapNumber(ln).test_r.(ss{aa})*2;
    end
    %{
    fixedLapNumber(ln).study_l.correct = fixedLapNumber(ln).study_l.correct*2-1;
    fixedLapNumber(ln).study_l.wrong = fixedLapNumber(ln).study_l.wrong*2-1;
    fixedLapNumber(ln).study_r.correct = fixedLapNumber(ln).study_r.correct*2-1;
    fixedLapNumber(ln).study_r.wrong = fixedLapNumber(ln).study_r.wrong*2-1;
    
    fixedLapNumber(ln).test_l.correct = fixedLapNumber(ln).test_l.correct*2;
    fixedLapNumber(ln).test_l.wrong = fixedLapNumber(ln).test_l.wrong*2;
    fixedLapNumber(ln).test_r.correct = fixedLapNumber(ln).test_r.correct*2;
    fixedLapNumber(ln).test_r.wrong = fixedLapNumber(ln).test_r.wrong*2;
    %}
end

end