%ManyTees Caiman-to-Matlab workflow

%% 1. Image processing

%1. Use inscopix Data Processing to temporally downsample videos to 10fps,
%   and spatially downsample 2x (to 720x540 x whatever)
%   - This is necessary because many of the sessions are too long
    
%2. Run the sesion through Caiman using Will's put together pipeline. 
%   - Make sure Caiman is expecting a video at 10fps, and still does a 2x
%   downsample

%3. Save Caiman outputs for use in matlab. The ones needed are:
%   - Data.C - fluoresence activity
%   - Data.S - spiking estimation (not using it yet, but may as well)
%   - Data.A - cell ROIs
%   - image size: can get it from a few places, use the one in the function

%4. Run Sam's super rough deconvolution and ROI translation algorithms. 
stdThresh = 3.5; %Num std above mean to get calcium transients at
durThresh = 5; %Minimum number of frames to call it a transient
[PSAbool] = DeconvolutionRough1(C,stdThresh,durThresh);
[cellROIs] = CaimanToMatCellROIs1(A,imSize);

%% 2. Video Position Correction
%1. Track and fix positions from raw video using tried and true function:
PreProcessLEDtracking

%2. Align positions to template
%   - right now built to take the PosLED_temp.mat,
%     saves out posAnchored with x/y_adj_cm  
AlignPosToAnchor1(posLedPath,anchorPath)

%3. Parse alternation behavior:
%   - takes in the posAnchored but operates on xAVI,yAVI within. Saves out
%     a file that has behavior table, lapDirections, stem limits
[onMazeFinal,behTable] = ParseOnMazeBehaviorMultiWrapper(posLEDfile);
still need an accuracy file for the datatable?

%4. Turn these tables into an excel sheet 
MakeSpreadSheetFromBehTable

%5. Adjust positions to final alignment (for now, no)

%% 3. Align Imaging to position tracking. 
%1. Align imaging to tracking with updated function
%   - saves out Pos_brain.mat
AlignImagingToTracking2_SL('pos_file','posAnchored.mat','fps_brainimage',10)

%2. Align behavior timestamps to brain time
ParsedFramesToBrainFrames( xls_file,10)

%3. Finalize the sheet
DNMPexcelCombiner(cd)
ExcelFinalizer(cd)
%% 4. Add it all together to make a trial by trial!
%1. Make a dummy cell registration as a placeholder. REPLACE IN FUTURE
MakeFullRegFake(sessionPaths)

%2. Make a data table of all sessions
DNMPdataTable = MakeDNMPdataTable(fullRegPath)

%3. Make daybyday
[daybyday, sortedSessionInds, useDataTable] = MakeDayByDay(basePath,accuracyThresh, getFluoresence, deleteSilentCells)

%4. Make trialbytrial
[trialbytrial, allfiles, sortedSessionInds, realdays]= MakeTrialByTrial2(basePath,taskSegment,correctOnly)










