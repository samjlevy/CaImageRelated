%DoublePlusWorkingWorkflow

mainFolder = 'G:\DoublePlus';
mainFolder = 'C:\Users\Sam\Desktop\DoublePlusFinalData';
mice = {'Kerberos','Marble07','Marble11','Pandora','Styx','Titan'};

PreProcessLEDtracking

GetDoublePlusPosAnchor % - Pos.scaled 
    %positions aligned to ideal base
    
PosScaledToPosAlign


ParseDoublePlusBehavior('turn')


MakeDoublePlusBehaviorBounds
%MakeDoublePlusLimsManually




CellReg %Ziv 2017


MakeTBTwrapperDoublePlus


%% More fleshed out, but for within-day only

%1. Track and fix positions from raw video using tried and true function:
PreProcessLEDtracking

%2. FToffset
JustFToffset('fps_brainimage',20)

%3. Align positions to template
%   - right now built to take the PosLED_temp.mat, but just the path, not the file
%     saves out posAnchored with x/y_adj_cm  
AlignPosToAnchor1(posLedPath,'E:\DoublePlus\December\mainPosAnchor.mat') %For december

%4. Parse plus maze behavior: for within day, just need total sequence,
%reward get time, mark whether it was to the goal or not

%5. Turn these tables into an excel sheet 
MakeSpreadSheetFromBehTable

%6. Exclude some bad frames
ExcludeLapFrames