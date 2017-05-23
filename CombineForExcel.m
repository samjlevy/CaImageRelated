function [newAll] = CombineForExcel(newFrames, newTxt)

newAll=newTxt;
for column = 1:size(newFrames,2)
    if ~isnan(newFrames(:,column))
       for row = 1:size(newFrames,1)
           newAll{row+1,column} = newFrames(row,column);
       end
    end
end

end