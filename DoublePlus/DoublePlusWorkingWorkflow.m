%DoublePlusWorkingWorkflow
allDataFolder = 'G:\DoublePlus';
mainFolder = 'C:\Users\Sam\Desktop\DoublePlusFinalData';

PreProcessLEDtracking

GetDoublePlusPosAnchor % - Pos.scaled 
    %positions aligned to ideal base
    
PosScaledToPosAlign


MakeDoublePlusLimsManually
    inches.northLims = [anchorY(4) 190 ];   cm.northLims = inches.northLims*2.54/10;
    inches.southLims = [anchorY(1) -190];   cm.southLims = inches.southLims*2.54/10;
    inches.eastLims = [anchorX(3) 215];     cm.eastLims = inches.eastLims*2.54/10;
    inches.westLims = [anchorX(1) -215];    cm.westLims = inches.westLims*2.54/10;
    [anchorX,anchorY,bounds] = MakeDoublePlusPosAnchor([]);
save(fullfile(mainFolder,'behaviorBounds.mat'),'inches','cm','anchorX','anchorY','bounds')

ParseDoublePlusBehavior

CellReg %Ziv 2017


MakeDayByDayDoublePlus