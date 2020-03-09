function [accuracy] = sessionAccuracyForcedUnforced(allfiles,sheetLabel)

if isempty(sheetLabel)
   sheetLabel = '*Finalized.xlsx';
end

if size(allfiles,1)==1
    allfiles = {allfiles};
end

accuracy = zeros(length(allfiles),1);
for fileN = 1:length(allfiles)
    thisDir = allfiles{fileN};
    fileList = ls(fullfile(thisDir,sheetLabel));
    if size(fileList,1)==1
       [frames, txt] = xlsread(fullfile(thisDir,fileList), 1);
       [right_forced, left_forced, right_free, left_free] = ForcedUnforcedtrialDirections(frames, txt);
       
       lastLeft = left_forced(1:end-1) | left_free(1:end-1);
       lastRight = right_forced(1:end-1) | right_free(1:end-1);
       
       thisLeft = left_free(2:end);
       thisRight = right_free(2:end);
       
       correct = (thisLeft & lastRight) | (thisRight & lastLeft);
       accuracy(fileN) = sum(correct)/length(correct);
    else
        disp(['Did not find a finalized file for ' thisDir])
        accuracy(fileN) = NaN;
    end
    
end

end