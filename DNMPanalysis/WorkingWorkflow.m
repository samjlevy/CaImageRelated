%Better-validated sequence; uses Sam's version of stuff
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
ParsedFramesToBrainFrames
    %Translates a sheet (columnwise) of 
    %timestamps from an AVI into brain 
    %PSAbool timestamps; needs FToffsetSam.mat
    %in folder to run. Run on original frames and brain frames
DNMPtimestampsValidator 
    %Takes a position file and a spreadsheet, plots
    %each column's timestamps on top of the X/Y
    %positions to validate. If you see a bad one, click
    %near it and it will give you the lap number of
    %that point in that column
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
    