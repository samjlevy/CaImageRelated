function [fakeCorrect] = AllBoundsCorrect(correct)
%This just replaces all the entries in correct with ones so that all laps
%will get used

fakeCorrect = correct;

ss = fieldnames(correct{1,1});
for aa = 1:length(correct)
    for bb = 1:length(ss)
        fakeCorrect{aa}.(ss{bb})(:) = 1;
    end
end

end