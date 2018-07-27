function [fakeCorrect] = AllBoundsCorrect(correct)
%This just replaces all the entries in correct with ones so that all laps
%will get used

fakeCorrect = correct;

switch class(correct)
    case 'cell'
        ss = fieldnames(correct{1,1});
    case 'struct'
        ss = fieldnames(correct(1));
end

for aa = 1:length(correct)
    for bb = 1:length(ss)
        switch class(correct)
            case 'cell'
                fakeCorrect{aa}.(ss{bb})(:) = 1;
            case 'struct'
                fakeCorrect(aa).(ss{bb})(:) = 1;
        end
    end
end

end