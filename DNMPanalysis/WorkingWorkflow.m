%Better-validated sequence; uses Sam's version of stuff
Pix2Cm = 0.0874;
RoomStr = '201a - 2015';

cd(folder you want)
JustFToffset %Produces FToffsetSam.mat, Sam's verison which adjusts PSAbool 
             %around usable tracking data
AlignImagingToTracking_SL %Produces Pos_brain.mat, Xpix and Ypix (from
                          %Pos.mat) interpolated to imaging timestamps,
                          %returns PSAboolAdjusted, x and y all of the same
                          %length.
AlignPositions_SL         %Right now just rotates trajectory to 0, scales
                          %pix2cm, gets speed. Future versions will align
                          %all to a base struct
ParsedFramesToBrainFrames( xls_file) %Translates a sheet (columnwise) of 
                                     %timestamps from an AVI into brain 
                                     %PSAbool timestamps; needs FToffsetSam.mat
                                     %in folder to run
                                     %Run on original frams and brain
                                     %frames
DNMPtimestampsValidator %Takes a position file and a spreadsheet, plots
                        %each column's timestamps on top of the X/Y
                        %positions to validate. If you see a bad one, click
                        %near it and it will give you the lap number of
                        %that point in that column
[start_stop_struct, include_struct, exclude_struct] =...
    GetBlockDNMPbehavior( frames, txt, block_type, sessionLength);
                        %Compiles timestamps from a spreadsheet into a
                        %struct with pairs of starts and stops, a struct
                        %that is include for the whole session, and a
                        %struct that is exclude for the whole session

PlacefieldsSL(MD,varargin) %single tinker to will's new version to make 
                            %exclude frames work
                            %could add custom save names
PlacefieldStats %will's new version; could add custom file loading, saving