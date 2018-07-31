%These are the main ones that need to happen to standardize analaysis. 

%Mostly-validated sequence
Pix2Cm = 0.0874;
RoomStr = '201a - 2015';

JustFToffset 
    %Produces FToffsetSam.mat, Sam's verison which adjusts PSAbool 
    %around usable tracking data
AlignImagingToTracking2_SL
    %Uses FToffset to produce PSAbool and X and Y all adjusted to the same
    %time scale.
AlignPositions2_SL
    %Load results from AlignImagingToTracking2_SL
    %Uses user-defined maze corners to align all sessions to an 'ideal'
    %base, which is horizontally straightened, start-choice positive,
    %scaled to actual cm. Can handle multiple sessions
    %Right now this is hard-coded for DNMP, cheats a little bit
ParsedFramesToBrainFrames
    %Translates a sheet (columnwise) of 
    %timestamps from an AVI into brain 
    %PSAbool timestamps; needs FToffsetSam.mat
    %in folder to run. Run on original frames
DNMPtimestampsValidator 
    %Takes a position file and a spreadsheet, plots
    %each column's timestamps on top of the X/Y
    %positions to validate. If you see a bad one, click
    %near it and it will give you the lap number of
    %that point in that column
AdjustBehaviorTimes
    %Brings points across laps as close together as possible so always
    %comparing the same sections of the maze. Right now only works for
    %ginput to pick anchor point, other versions can be added
FindBadLapsWrapper
    %calls FindBadLaps
    %used to find bad points in individual bad laps, writes a new
    %spreadsheet that has the fixed timestamps
DNMPexcelCombiner(cd)
    %Combines all found Adjusted Sheets into a single one
ExcelFinalizer(cd)
    %Writes a final version of the spreadsheet that kicks out laps with
    %overlapped critical timestamps or timestamps beyond the length of
    %pos_align
matchCells
    %Sam's version of cell registration, calls manual_reg_SL to do cell
    %registration to the base session, using manual anchors and matlab's
    %projective geotransform/imwarp. Outputs fullReg.mat in base_session
    %folder with all the important reg info. Doesn't yet show how well
    %registration worked
    %fullReg.sesssionInds is the alignment of cell numbers to other
    %sessions. So (4,1) tells what number cell in FinalOutput in session 1 aligns
    %to (4,5) what number cell in FinalOutput in session 5, both for the
    %4th cell registered. Sessions are NOT chronological order be default,
    %but in order registration was performed (fullReg.BaseSession followed
    %by fullReg.RegSessions
newxlims1
    %Not well written right now, but necessary for ensuring good alignment
    %of positions across all sessions
MakeTrialByTrialWrapper
    %New version that guides you through making a full data table,
    %condensed version of all data sessions (daybyday), trialbytrial out of that
    %daybyday
MakeTrialByTrial
    %uses registration in indicators about which sessions to include to
    %build a structure that divides data into levels in the structure so
    %that x, y and spiking activity for every cell (realigned across
    %sessions according to registration) can be easily called
    %together.
    MakeDayByDay
    
AllAnalyses1
    %loads trial by trial for each folder indicated, runs all the same
    %analyses on them. Way overdone relative to what's needed in a paper
AllFigures1
    %Dependent on everything from AllAnalyses1 being in the workspace,
    %plots (again to excess) everything you could ever want to know
    
    
newxlims1 
    %for making sure that timestamps being used are outside of xlims so
    %that right amount of data is being used
GetMegaStuff2
    %Based on data in fullReg, loads all the position and spiking data from
    %each into big cell arrays for iterating through all of it
    %Session type is only for reg sessions
PoolTrialsAcrossSessions
    %Reorganizes output from GetMegaStuff into activity for individual
    %trials by session. This makes it very straightforward to analyze lots
    %of sessions in the same way and enables shuffling between conditions
    %or across sessions
PoolPSA
    %Shuffles rows of PSAbool to align cells' activity across sessions
    

%Other, smaller scripts. Many are called in other big ones, many have a
%version 2
AlignImagingToTracking_SL  %OLD
    %Produces Pos_brain.mat, Xpix and Ypix (from
    %Pos.mat) interpolated to imaging timestamps,
    %returns PSAboolAdjusted, x and y all of the same length
AlignPositions_SL(RoomStr)         
    %Right now just rotates trajectory to 0, scales
    %pix2cm, gets speed. Future versions will align all to a base struct
GetBlockDNMPbehavior
    %Compiles timestamps from a spreadsheet into a
    %struct with pairs of starts and stops, a struct
    %that is include for the whole session, and a
    %struct that is exclude for the whole session
PlacefieldsSL(MD,varargin) 
    %single tinker to will's new version to make 
    %exclude frames work
    %could add custom save names
PlacefieldStatsSL 
    %Small tinkers to get PSAbool data, etc. during pf epochs; also now
    %returns running inds which has inds from FT of this epoch
StructEqualizer 
    %Takes input as structs, goes through and makes all arrays
    %and cell arrays into equal size; assumes {1,1}/(1,1) is
    %reference point, adds rows and columns of nan or 0s as
    %appropriate to make arrays the same size
CellsInConditions
    %Tells how many hits per cell per condition
PFspatialCorrBatch
    % Spatial correlation: compares TMap_gauss within a cell across
    % conditions in good pixels; excludes cells that don't meet a firing
    % rate threshold, or arent active in the other condition
PFrateChangeBatch(PFsA, PFsB, hitThresh, posThresh) 
    %Calculates rate changes by getting means of TMap_gauss for shared 
    %pixels above position threshold
PopVectorCorr(PFsA,PFsB,posThresh,excludeSilent) 
    %Runs a population vector 
    %correlation as implemented in Leutgeb 2005. PFsX is struct
    %with maps and stats, pos thresh is requisite numbe of hits
    %in a position bin, excludeSilent is if you want to exclude
    %cells that were silent in both conditions. 
FindPlaceFiles
    %Given cmperbin and which half (empty or 0 for the regular files) will
    %return a list of place and stats files that fit that profile.
    %Alternative is to generate list of files needed when running
    %DNMPplaceFields
    
    
AlignPositions2_SL(anchor_path, cd, RoomStr)

i = 0;
i = i+1;
cd(align_paths{i})

reportedBad = DNMPtimestampsValidator( 'Pos.mat', ls('*_DNMPsheet.xlsx'), 1 )

ParsedFramesToBrainFrames(ls('*_DNMPsheet.xlsx'))

reportedBad = DNMPtimestampsValidator( 'Pos_align.mat', ls('*_DNMPsheet_BrainTime.xlsx'), 1 )

AdjustBehaviorTimes('Pos_align.mat', ls('*_DNMPsheet_BrainTime.xlsx'))

FindBadLapsWrapper('Pos_align.mat',ls('*_DNMPsheet_BrainTime_Adjusted.xlsx'),'stem_only',1)
 
DNMPexcelCombiner(cd)
    
ExcelFinalizer(cd)
    