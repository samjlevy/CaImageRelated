function AlignImagingToTracking2_SL(varargin)
% Sam's version of aligning imaging to tracking; needs Sam's FToffset stuff
% to run. Looks at whichEndsFirst to indicate in the other what is the last
% usable frame. This is all based on time from the DVT and assumed-equal
% timing in the imaging file
folderUse = cd;
fps_brainimage = 20;
pos_file = 'Pos.mat';
if ~isempty(varargin)
for aa = 1:length(varargin)/2
    switch varargin{2*aa-1}
        case 'folderUse'
            folderUse = varargin{2*aa};
            cd(folderUse)
        case 'fps_brainimage'
            fps_brainimage = varargin{2*aa};
        case 'pos_file'
            pos_file = varargin{2*aa};
        case 'xPositions'
            x_var_name = varargin{2*aa};
        case 'yPositions'
            y_var_name = varargin{2*aa};
    end
end
end

aa = load(fullfile(folderUse,pos_file));
fn = fieldnames(aa);
if exist('x_var_name','var')
    xind = find(strcmpi(fn,x_var_name));
else
    xind = listdlg('PromptString','Which is X positions?','ListString',fn);
end
if exist('y_var_name','var')
    yind = find(strcmpi(fn,y_var_name));
else
    yind = listdlg('PromptString','Which is Y positions?','ListString',fn);
end
xAVI = aa.(fn{xind});
yAVI = aa.(fn{yind});
DVTtime = aa.DVTtime;


if ~exist('DVTtime','var')
    [DVTfile, DVTpath] = uigetfile('*.DVT', 'Select DVT file');
    pos_data = importdata(fullfile(DVTpath, DVTfile));
    time = pos_data(:,2);
else    
    time=DVTtime;
end    

%brainFrameRate = 1/fps_brainimage;
TrackingLength = length(xAVI);

if ~exist('FToffsetSam.mat','file')
    disp('Did not find Sam"s FToffset, running it now')
    [~, ~, ~ ] = JustFToffset('fps_brainimage',fps_brainimage); %FToffset LastUsable whichEndsFirst FTlength brainTime time
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
    [s,~] = listdlg('PromptString','Which field for neural data:','SelectionMode','single',...
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
xBrain = interp1( time(TrackingUse(1):TrackingUse(2)),...
                  xAVI(TrackingUse(1):TrackingUse(2)),...
                  brainTime(brainTimeUse(1):brainTimeUse(2)));
yBrain = interp1( time(TrackingUse(1):TrackingUse(2)),...
                  yAVI(TrackingUse(1):TrackingUse(2)),...
                  brainTime(brainTimeUse(1):brainTimeUse(2)));
              
brain_time = brainTime(brainTimeUse(1):brainTimeUse(2));
              
PSAboolUseIndices = FTuse(1):FTuse(2);
PSAboolAdjusted = FT(:,PSAboolUseIndices);

save Pos_brain.mat xBrain yBrain PSAboolUseIndices PSAboolAdjusted brain_time TrackingUse            
end
