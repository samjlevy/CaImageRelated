%DoublePlusWorkingWorkflow
mainFolder = 'G:\DoublePlus';
mainFolder = 'C:\Users\Sam\Desktop\DoublePlusFinalData';
mice = {'Kerberos','Marble07','Marble11','Pandora','Styx','Titan'};

PreProcessLEDtracking

GetDoublePlusPosAnchor % - Pos.scaled 
    %positions aligned to ideal base
    
PosScaledToPosAlign


ParseDoublePlusBehavior('turn')


MakeDoublePlusLimsManually
    MakeDoublePlusBehaviorBounds




CellReg %Ziv 2017


MakeDayByDayDoublePlus
