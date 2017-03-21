function AlignImagingToTracking_SL(varargin)
% Sam's version of aligning imaging to tracking; needs Sam's FToffset stuff
% to run. Looks at whichEndsFirst to indicate in the other what is the last
% usable frame. This is all based on time from the DVT and assumed-equal
% timing in the imaging file

load Pos.mat DVTtime Xpix_filt Ypix_filt
time=DVTtime;
%load Pos.mat Xpix Ypix

fps_brainimage = 20;
%brainFrameRate = 1/fps_brainimage;
TrackingLength = length(Xpix_filt);

if ~exist('file','FToffsetSam')
    disp('Didn"t find Sam"s FToffset, running it now')
    [~, ~, ~ ] = JustFToffset;
end
load FToffsetSam.mat

FTfileMaybe = dir('FinalOutput.mat');
if length(FTfileMaybe) ~= 1
    disp('Did not find 1 FT/PSAbool file. Show me where it is')
    [FTfile,~] = uigetfile('*.mat','Select file with FT/PSAbool');
else 
    FTfile = FTfileMaybe.name;
end
        
FTstuff = load(FTfile);
names = fieldnames(FTstuff);
if sum(strcmpi('PSAbool',names))==1
    FT=FTstuff.PSAbool;
elseif sum(strcmpi('FT',names))==1    
    FT=FTstuff.PSAbool;
else
    names = fieldnames(FTstuff);
    [s,~] = listdlg('PromptString','Which field:','SelectionMode','single',...
                'ListString',names);
    eval(['FT = FTstuff.' names{s} ';'])
end
        
FTlength = size(FT,2);
brainTime = (1:FTlength)*(1/fps_brainimage);

switch whichEndsFirst
    case 'imaging'
        %LastUsable is a frame in tracking 
        FTuse = [FToffset FTlength];
        TrackingUse = [1 LastUsable];
    case 'tracking'
        %LastUsable is a frame for FT (i.e., FToffsetRear)
        TrackingUse = [1 TrackingLength];
        FTuse = [FToffset LastUsable];
end

%Interpolate 
%vq = interp1(x,v,xq)
brainX = interp1( time(TrackingUse(1):TrackingUse(2)),...
                  Xpix_filt(TrackingUse(1):TrackingUse(2)),...
                  brainTime(FTuse(1):FTuse(2)));
brainY = interp1( time(TrackingUse(1):TrackingUse(2)),...
                  Ypix_filt(TrackingUse(1):TrackingUse(2)),...
                  brainTime(FTuse(1):FTuse(2)));
              
FTuseIndices = FTuse(1):FTuse(2);

save Pos_brain.mat brainX brainY FTuseIndices              
end
