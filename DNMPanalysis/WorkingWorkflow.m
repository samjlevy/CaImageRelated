%These are the main ones that need to happen to standardize analaysis. 

%Mostly-validated sequence
Pix2Cm = 0.0874;
RoomStr = '201a - 2015';

JustFToffset 
    %Produces FToffsetSam.mat, Sam's verison which adjusts PSAbool 
    %around usable tracking data
AlignImagingToTracking_SL 
    %Produces Pos_brain.mat, Xpix and Ypix (from
    %Pos.mat) interpolated to imaging timestamps,
    %returns PSAboolAdjusted, x and y all of the same length
AlignPositions_SL         
    %Right now just rotates trajectory to 0, scales
    %pix2cm, gets speed. Future versions will align all to a base struct
AlignPositionsBatch_SL
    %This is to replace AlignPositions: uses geometric transformations to
    %align points in the original 
    %
    %
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
ExcelFinalizer
    %Writes a final version of the spreadsheet that kicks out laps with
    %overlapped critical timestamps or timestamps beyond the length of
    %pos_align
matchCells
    %Sam's version of cell registration, calls manual_reg_SL to do cell
    %registration to the base session, using manual anchors and matlab's
    %projective geotransform/imwarp. Outputs fullReg.mat in base_session
    %folder with all the important reg info. Doesn't yet show how well
    %registration worked
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
    