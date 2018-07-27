function [correctBounds,lapNumber] = RemoveExcludeFrames(imagingFramesDelete,bounds,frames,lapNumber)
%Deletes the whole lap (as indicated in frames) 

correctBounds = bounds;

ss = fieldnames(bounds);

deleteFrames = cell2mat(cellfun(@any,imagingFramesDelete,'UniformOutput',false));
for sessI = 1:length(imagingFramesDelete)
    if deleteFrames(sessI) == 1
        disp(['Found frames to exlude, session ' num2str(sessI) ])
        
        badEdge = [find(imagingFramesDelete{sessI},1,'first') find(imagingFramesDelete{sessI},1,'last')];
        badFrames = [frames{sessI} >= badEdge(1) & frames{sessI} <= badEdge(2)];
        badLaps = sum(badFrames,2)>1;
        
        badLapEdge = [min(frames{sessI}(find(badLaps,1,'first'),2:end))...
                      max(frames{sessI}(find(badLaps,1,'last'),2:end))];
        
        for ff = 1:length(ss)
            badBounds = [bounds(sessI).(ss{ff}) >= badLapEdge(1) & bounds(sessI).(ss{ff}) <= badLapEdge(2)];
                        
            badBits(sessI).(ss{ff}) = sum(badBounds,2)>0;
            
            correctBounds(sessI).(ss{ff})(badBits(sessI).(ss{ff}),:) = [];
            lapNumber(sessI).(ss{ff}).correct(badBits(sessI).(ss{ff}),:) = [];
        end
    end
end
    

end