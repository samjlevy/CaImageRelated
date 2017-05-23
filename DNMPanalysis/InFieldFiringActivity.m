function [IFFA, IFhits]=InFieldFiringActivity(activityMat, inFieldTimes, getHits)
%Activity mat can be either PSAbool or traces
%Frames can be logical (length of PSAbool) or timestamp pairs, [starts, ends]
%{
if length(frames)==size(activityMat,2)
    %Assuming it's a logical
    checkLog = unique(frames);
    if checkLog(1)==0 && checkLog(2)==1
        IFFA = activityMat(:,frames);
    end    
else
    iffaCellCols = size(frames,1);
    for framesRow = 1:iffaCellCols
        framesCheck{1,framesRow} = [frames(framesRow,1):frames(framesRow,2)];
    end    
    frames = framesCheck;
    
    IFFA = cell(size(activityMat,1),iffaCellCols);

    for cellNum=1:size(activityMat,1)
        for cellCol=1:iffaCellCols
            IFFA{cellNum,cellCol} = activityMat(cellNum,frames{1,cellCol});
        end
    end
end
%}
numCells = size(activityMat,1);
numFields = size(inFieldTimes,2);

if nargin==3
    IFhits.hits = nan(size(inFieldTimes));
    IFhits.rate = nan(size(inFieldTimes));
    IFhits.sum = nan(size(inFieldTimes));
end

IFFA = cell(1,size(frames));
for thisCell = 1:numCells
    for thisField = 1:numFields
        thesePasses = inFieldTimes{thisCell,thisField};
        if any(thesePasses)
            for thisPass = 1:size(thesePasses,1)
            thisCellIFFA{

end

