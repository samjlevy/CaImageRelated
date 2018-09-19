function [posAndVelFig] = PreProcUpdatePosAndVel(xAVI,yAVI,onMaze,definitelyGood,velThresh,posAndVelFig)
border = 0.05;
boxHeight = (1-border*4) / 3;
boxWidth = 1-border*2;
plotOnMaze = onMaze; 
plotOnMaze(plotOnMaze==0) = NaN;
%defGoodWork = definitelyGood==0;

veloc = PreProcGetVelocity(xAVI,yAVI,[],onMaze);
%veloc = hypot(diff(xAVI.*plotOnMaze,1),diff(yAVI.*plotOnMaze,1));

figsOpen = findall(0,'type','figure');
if length(figsOpen)~=0
isPosVel = strcmp({figsOpen.Name},'posAndVelFig');
elseif length(figsOpen)==0
    isPosVel=0;
end

if sum(isPosVel)==1
    %We're good
    posAndVelFig = figsOpen(isPosVel);
elseif sum(isPosVel)==0
    posAndVelFig = figure('Position',[267 152 1582 758],'Name','posAndVelFig'); 
elseif sum(isPosVel) > 1
    manCorrInds = find(isPosVel);
    close(figsOpen(manCorrInds(2:end)))
    try
        clear(figsOpen(manCorrInds(2:end)))
    catch 
        disp('delete posvelfigs did not work')
    end
end

figure(posAndVelFig);
subplot('Position',[border border*3+boxHeight*2 boxWidth boxHeight])
plot(xAVI.*plotOnMaze)
title('X position'); %xlabel('Frame Number')
subplot('Position',[border border*2+boxHeight*1 boxWidth boxHeight])
plot(yAVI.*plotOnMaze)
title('Y position'); %xlabel('Frame Number')
subplot('Position',[border border*1+boxHeight*0 boxWidth boxHeight])
plot(veloc)
hold on
plot([1 length(veloc)],[velThresh velThresh],'r')
badVel = veloc > velThresh;
fn = 1:length(badVel);
plot(fn(badVel),veloc(badVel),'or')
title('Velocity'); xlabel('Frame Number')
hold off

end