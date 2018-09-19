function veloc = PreProcGetVelocity(xAVI,yAVI,windowSearch,onMaze)
if isempty(onMaze)
    onMaze = ones(size(xAVI,1),size(xAVI,2));
end
if isempty(windowSearch)
    windowSearch = ones(size(xAVI,1),size(xAVI,2));
end
onMazeWork = onMaze(1:end-1) | onMaze(2:end);
windowWork = windowSearch(1:end-1) | windowSearch(2:end);

%onMazeWork(onMazeWork==0) = NaN;

veloc = hypot(diff(xAVI),diff(yAVI)).*onMazeWork.*windowWork;
    
end