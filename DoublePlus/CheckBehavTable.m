function CheckBehavTable(sessionFolder)

alignedTable = readtable(fullfile(sessionFolder,'PlusBehavior_BrainTime.xlsx'));

load(fullfile(sessionFolder,'Pos_brain.mat'),'xBrain','yBrain')
eachLapsStarts = cellfun(@(x) x(1), alignedTable.ArmSequence);
eachLapsEnds = cellfun(@(x) x(end), alignedTable.ArmSequence);
uniqueStarts = unique(eachLapsStarts);
uniqueEnds = unique(eachLapsEnds);
for uu = 1:numel(uniqueStarts)
    gfg = figure('Position',[244 185 560 420]);
    plot(xBrain,yBrain,'.k')
    hold on
    ptsH = alignedTable.LapStart(eachLapsStarts==uniqueStarts(uu));
    plot(xBrain(ptsH),yBrain(ptsH),'.m')
    title(['Starts from ' uniqueStarts(uu)])
    if strcmpi(input('Looks ok?','s'),'n')
        keyboard
    end
    try; close(gfg); end
end

for uu = 1:numel(uniqueEnds)
    gfg = figure('Position',[244 185 560 420]);
    plot(xBrain,yBrain,'.k')
    hold on
    ptsH = alignedTable.LapStop(eachLapsEnds==uniqueEnds(uu));
    plot(xBrain(ptsH),yBrain(ptsH),'.m')
    title(['Ends at ' uniqueEnds(uu)])
    if strcmpi(input('Looks ok?','s'),'n')
        keyboard
    end
    try; close(gfg); end
end

[inX,inY] = ginput(1)
 [ idx, distance ] = findclosest2D(xBrain(ptsH),yBrain(ptsH),inX,inY);
thisInds = find(eachLapsEnds==uniqueEnds(uu));
thisLap = thisinds(idx)


figure('Position',[244 185 560 420]);
    plot(xBrain,yBrain,'.k')
    hold on
     ptsH = alignedTable.LapStart(thisLap):alignedTable.LapStop(thisLap);
     plot(xBrain(ptsH),yBrain(ptsH),'.m')