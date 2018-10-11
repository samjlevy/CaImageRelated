function [armBoundaries, centerBoundary, ends] = MakeDoublePlusBehaviorBounds

[anchorX,anchorY,bounds] = MakeDoublePlusPosAnchor([]);

centerBuffer = 1.5*10; %pix per inch

inches.northLims = [anchorY(4)+centerBuffer 190 ];   cm.northLims = inches.northLims*2.54/10;
inches.southLims = [anchorY(1)-centerBuffer -190];   cm.southLims = inches.southLims*2.54/10;
inches.eastLims = [anchorX(3)+centerBuffer 215];     cm.eastLims = inches.eastLims*2.54/10;
inches.westLims = [anchorX(1)-centerBuffer -215];    cm.westLims = inches.westLims*2.54/10;
armBoundaries.north = [cm.westLims(1) cm.northLims(1); cm.eastLims(1) cm.northLims(1);...
                       cm.eastLims(1) cm.northLims(2); cm.westLims(1) cm.northLims(2)];
armBoundaries.south = [cm.westLims(1) cm.southLims(1); cm.eastLims(1) cm.southLims(1);...
                       cm.eastLims(1) cm.southLims(2); cm.westLims(1) cm.southLims(2)];
armBoundaries.east = [cm.eastLims(1) cm.northLims(1); cm.eastLims(1) cm.southLims(1);...
                      cm.eastLims(2) cm.southLims(1); cm.eastLims(2) cm.northLims(1)];
armBoundaries.west = [cm.westLims(1) cm.northLims(1); cm.westLims(1) cm.southLims(1);...
                      cm.westLims(2) cm.southLims(1); cm.westLims(2) cm.northLims(1)];
                  
centerBoundary = [cm.westLims(1) cm.northLims(1); cm.eastLims(1) cm.northLims(1);...
                  cm.eastLims(1) cm.southLims(1); cm.westLims(1) cm.southLims(1)];

ends.north = [-20 armBoundaries.north(4,2); 20 armBoundaries.north(4,2);...
              20 armBoundaries.north(4,2)+30; -20 armBoundaries.north(4,2)+30];
ends.south = [-20 armBoundaries.south(4,2); 20 armBoundaries.south(4,2);...
              20 armBoundaries.south(4,2)-30; -20 armBoundaries.south(4,2)-30];
ends.east =  [armBoundaries.east(4,1) 20; armBoundaries.east(4,1)+30 20;...
              armBoundaries.east(4,1)+30 -20; armBoundaries.east(4,1) -20];         
ends.west =  [armBoundaries.west(4,1) 20; armBoundaries.west(4,1)-30 20;...
              armBoundaries.west(4,1)-30 -20; armBoundaries.west(4,1) -20];         
          
%save(fullfile(mainFolder,'behaviorBounds.mat'),'inches','cm','anchorX','anchorY','bounds')
end