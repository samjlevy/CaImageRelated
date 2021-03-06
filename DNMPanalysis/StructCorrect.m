function corrected = StructCorrect(bounds, correct)

ss = fieldnames(bounds{1});
for sess = 1:length(bounds)
    for fn = 1:length(ss)
        switch class(correct)
            case 'cell'
                corrected{sess}.(ss{fn}) = bounds{sess}.(ss{fn})(correct{sess}.(ss{fn}),:);
            case 'struct'
                corrected(sess).(ss{fn}) = bounds(sess).(ss{fn})(correct(sess).(ss{fn}),:);
        end
    end
end

end44444