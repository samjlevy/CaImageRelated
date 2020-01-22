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

%3.5 Also need approx reward locations for each lap
GetPlusRewardLocations(posAnchoredFile)

%4. Parse plus maze behavior: for within day, just need total sequence,
[onMazeFinal,behTable] = ParsePlusMazeBehavior2(posLEDfile,posAnchoredFile);
%Takes the pos ledTemp (mostly for onMaze) and posAnchored.mat

%5. MakeQuickSpreadSheet(file)
MakeQuickPlusSpreadsheet

%{
%5. Turn these tables into an excel sheet 
MakeSpreadSheetFromBehTable

%6. Exclude some bad frames
ExcludeLapFrames
%}

%% 3. Align Imaging to position tracking. 
%1. Align imaging to tracking with updated function
%   - use x_adj_cm and y_adj_cm
%   - saves out Pos_brain.mat
AlignImagingToTracking2_SL('pos_file','posAnchored.mat','fps_brainimage',20)

%2. Align behavior timestamps to brain time
ParsedFramesToBrainFrames('PlusBehavior.xlsx',20)

%3. Finalize: for now just copy and rename
copyfile 'PlusBehavior_BrainTime.xlsx' 'PlusBehavior_BrainTime_Finalized.xlsx'

%% 4. Add it all together to make a trial by trial!
%1. Make a dummy cell registration as a placeholder. REPLACE IN FUTURE
sessionPaths = {'E:\DoublePlus\December\December_191210';'E:\DoublePlus\December\December_191211'};
MakeFullRegFake(sessionPaths)

%2. Make a data table of all sessions
MakeAlternationDataTable1(session_paths{1})

%3. Make daybyday
mousePath = 'E:\DoublePlus\December';
getFluoresence = true;
deleteSilentCells = true;
[daybyday, sortedSessionInds, useDataTable] = MakeDayByDayWithinPlus(mousePath, getFluoresence, deleteSilentCells);

%4. Make trialbytrial
correctOnly = false;
[trialbytrial, allfiles, sortedSessionInds, realdays]= MakeTBTwithinDayPlus(mousePath,getFluoresence,correctOnly);







