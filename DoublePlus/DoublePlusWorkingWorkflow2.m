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


%% More detailed

%1. Track and fix positions from raw video using tried and true function:
PreProcessLEDtracking

%3. Align positions to template
% saveDir = 'F:\DoublePlus'; % workSSD
%[anchorX,anchorY,bounds] = MakeDoublePlusPosAnchor(saveDir); 
% creates an anchor file that has anchorX, anchorY, bounds, posAnchorIdeal
% - generates the pos anchor, only need this once for each maze size
%mainAnchorFile = 'F:\DoublePlus\mainPosAnchor.mat';
mainAnchorFile = 'F:\DoublePlus\smallPosAnchor.mat';
posLedPath = []; % assuming you're in the folder
AlignPosToAnchor2(posLedPath,mainAnchorFile)
%   - right now built to take the PosLED_temp.mat, but just the path, not the file
%     saves out posAnchored with x/y_adj_cm 

%3.5 Also need approx reward locations for each lap: load these from template
posAnchoredFile = 'posAnchored.mat';
rewardLocsFile = [];
GetPlusRewardLocations(posAnchoredFile,rewardLocsFile)

%4. Parse plus maze behavior: for within day, just need total sequence,
%posLEDfile = ls('*PosLED_temp.mat');
ParsePlusMazeBehavior3(posAnchoredFile); %posLEDfile,
%Takes the pos ledTemp (mostly for onMaze) and posAnchored.mat

%5. MakeQuickSpreadSheet(file)
MakeQuickPlusSpreadsheet

ParsedFramesToBrainFrames('PlusBehavior.xlsx',20)

%{
%5. Turn these tables into an excel sheet                                
MakeSpreadSheetFromBehTable

%6. Exclude some bad frames
ExcludeLapFrames
%}

%% 3. Align Imaging to position tracking. 

%2. FToffset
JustFToffset('fps_brainimage',20)

%1. Align imaging to tracking with updated function
%   - use x_adj_cm and y_adj_cm
%   - saves out Pos_brain.mat
AlignImagingToTracking2_SL('pos_file','posAnchored.mat','fps_brainimage',20,'xPositions','x_adj_cm','yPositions','y_adj_cm')

%2. Align behavior timestamps to brain time
ParsedFramesToBrainFrames('PlusBehavior.xlsx',20)

%3. Finalize: for now just copy and rename
copyfile 'PlusBehavior_BrainTime.xlsx' 'PlusBehavior_BrainTime_Finalized.xlsx'

%4. Deal with multi-part sessions
% For files from the same session, same behavior type:
CombineSameSessionPieces
% For files from the same session, diff behaviors:
MergeDifferentSessionPieces(foldersUse,cellRegInds,saveFolder)
% For files coming from different neural data; requires sessionInds
% registration to put them together, that in the same order as in folders
% use

%% 4. Add it all together to make a trial by trial!
%1. Make a dummy cell registration as a placeholder. REPLACE IN FUTURE

mainFolder = 'F:\DoublePlus\';
mouseI = 2;
load(fullfile(mainFolder,mice{mouseI},'fileData.mat'))
sessionPaths = {fileData(:).name};
for sessI = 1:length(sessionPaths); if ~strcmpi(sessionPaths{sessI}(2:3),':'); sessionPaths{sessI} = fullfile(mainFolder,mice{mouseI},sessionPaths{sessI}); end; end
sessionType = {fileData(:).sessType};
realDays = [fileData(:).sessNum];
MakeFullRegFake(sessionPaths,baseSessionInd,realDays,sessionType,'overlap')



%2. Make a data table of all sessions
%MakeAlternationDataTable1(session_paths{1})

%3. Make daybyday
mousePath = 'E:\DoublePlus\December';
getFluoresence = true;
deleteSilentCells = cd;
[~, ~] = MakeDayByDayDoublePlus2(mousePath, getFluoresence, deleteSilentCells);

%4. Make trialbytrial
correctOnly = false;
[trialbytrial, allfiles, sortedSessionInds, realdays]= MakeTBTwithinDayPlus(mousePath,getFluoresence,correctOnly);


%% 5. Fixing things we skipped earlier

% 1. Validate all behavior parsing: 
% - load trials of each sequence, plot, check for errors

% 2. Replace cell registration





