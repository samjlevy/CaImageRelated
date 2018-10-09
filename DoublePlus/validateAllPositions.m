validateAllPositions

[anchorX,anchorY,bounds] = MakeDoublePlusPosAnchor([]);
for mouseI = 1:length(mice)
    cd(fullfile(mainFolder,mice{mouseI}))
    sessHere = dir;
    sessHere(1:2) = [];
    figure;
    for sessI = 1:length(sessHere)
        load(fullfile(mainFolder,mice{mouseI},sessHere(sessI).name,'PosScaled.mat'),'xAlign','yAlign','onMaze')
        plot(xAlign(onMaze),yAlign(onMaze),'.','MarkerSize',4)
        hold on
    end
    plot(anchorX,anchorY,'*r','MarkerSize',7)
    title(mice{mouseI})
end

[armBoundaries, centerBoundary] = MakeDoublePlusBehaviorBounds;
for mouseI = 1:length(mice)
    cd(fullfile(mainFolder,mice{mouseI}))
    sessHere = dir;
    sessHere(1:2) = [];
    figure;
    for sessI = 1:length(sessHere)
        load(fullfile(mainFolder,mice{mouseI},sessHere(sessI).name,'Pos_align.mat'),'x_adj_cm','y_adj_cm')
        plot(x_adj_cm,y_adj_cm,'.','MarkerSize',4)
        hold on
    end
    plot(armBoundaries.north(:,1),armBoundaries.north(:,2),'r')
    plot(armBoundaries.south(:,1),armBoundaries.south(:,2),'r')
    plot(armBoundaries.east(:,1),armBoundaries.east(:,2),'r')
    plot(armBoundaries.west(:,1),armBoundaries.west(:,2),'r')
    plot(centerBoundary(:,1),centerBoundary(:,2),'g')
    title(mice{mouseI})
end


