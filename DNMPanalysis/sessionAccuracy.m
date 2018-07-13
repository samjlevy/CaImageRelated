function [accuracy] = sessionAccuracy(allfiles)

accuracy = zeros(length(allfiles),1);
for fileN = 1:length(allfiles)
    thisDir = allfiles{fileN};
    fileList = ls(fullfile(thisDir,'*Finalized.xlsx'));
    if size(fileList,1)
        [frames, txt] = xlsread(fullfile(thisDir,fileList), 1);
    elseif size(fileList,1) > 1
        disp(['Found more than one finalized sheet in: ' allfiles{fileN}])
        return
    elseif size(fileList,1) < 1
        disp('Did not find a finalized excel file')
        return
    end

    [right_forced, left_forced, right_free, left_free] = DNMPtrialDirections(frames, txt);

    correctLaps = (right_forced & left_free) | (left_forced & right_free);

    accuracy(fileN) = sum(correctLaps)/length(correctLaps);
end

end


