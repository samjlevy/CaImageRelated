function QuickExcludeFrames(posFile,xlsFile)

load(posFile,'onMaze')

tableH = readtable(xlsFile);

fStarts = tableH.LeaveMaze;
fStops = tableH.StartOnMaze_startOfForced_;

excludeMat = [[1;fStarts], [fStops; length(onMaze)]];

for lapI = 1:size(excludeMat,1)
    onMaze(excludeMat(lapI,1):excludeMat(lapI,2)) = 0;
end

save(posFile,'onMaze','-append')

end