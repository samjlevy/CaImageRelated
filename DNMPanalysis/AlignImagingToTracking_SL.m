function AlignImagingToTracking_SL(varargin)
% Sam's version of aligning imaging to tracking; needs Sam's FToffset stuff
% to run. Looks at whichEndsFirst to indicate in the other what is the last
% usable frame. This is all based on time from the DVT and assumed-equal
% timing in the imaging file

load Pos.mat DVTtime Xpix Ypix%Xpix_filt Ypix_filt
if ~exist('DVTtime','var')
    [DVTfile, DVTpath] = uigetfile('*.DVT', 'Select DVT file');
    pos_data = importdata(fullfile(DVTpath, DVTfile));
    time = pos_data(:,2);
else    
    time=DVTtime;
end    
%load Pos.mat Xpix Ypix

fps_brainimage = 20;
%brainFrameRate = 1/fps_brainimage;
TrackingLength = length(Xpix);

if ~exist('FToffsetSam.mat','file')
    disp('Did not find Sam"s FToffset, running it now')
    [~, ~, ~ ] = JustFToffset; %FToffset LastUsable whichEndsFirst FTlength brainTime time
end
load FToffsetSam.mat

if strcmpi(whichEndsFirst,'tracking') && (imaging_start_frame~=1)
    disp('Be careful, this condition has NOT been validated')
end

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
        
%both of these now come from FToffsetSam
actualFTlength = size(FT,2); %not ideal length
%brainTime = (1:FTlength)*(1/fps_brainimage);

switch whichEndsFirst
    case 'imaging'
        %LastUsable is a frame in tracking 
        FTuse = [FToffset actualFTlength];
        TrackingUse = [1 LastUsable];
    case 'tracking'
        %LastUsable is a frame for FT (i.e., FToffsetRear)
        FTuse = [FToffset LastUsable];
        TrackingUse = [1 TrackingLength];
end
brainTimeUse = FTuse;
if imaging_start_frame~=1
    brainTimeUse = brainTimeUse - (imaging_start_frame-1);
end 

%Interpolate 
%vq = interp1(x,v,xq)
x = interp1( time(TrackingUse(1):TrackingUse(2)),...
                  Xpix(TrackingUse(1):TrackingUse(2)),...
                  brainTime(brainTimeUse(1):brainTimeUse(2)));
y = interp1( time(TrackingUse(1):TrackingUse(2)),...
                  Ypix(TrackingUse(1):TrackingUse(2)),...
                  brainTime(brainTimeUse(1):brainTimeUse(2)));
              
brain_time = brainTime(brainTimeUse(1):brainTimeUse(2));
              
PSAboolUseIndices = FTuse(1):FTuse(2);
PSAboolAdjusted = FT(:,PSAboolUseIndices);

save Pos_brain.mat x y PSAboolUseIndices PSAboolAdjusted brain_time            
end
