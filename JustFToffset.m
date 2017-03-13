function [FToffset, PlxEndsAfterImagingS] = JustFToffset(varargin)
%Just FT offset
for aa=1:length(varargin)
    
end    
fps_brainimage = 20; % frames/sec for brain image timestamps

DVTfileMaybe = dir('*.DVT');
if length(DVTfileMaybe) ~= 1
    disp('Did not fine 1 DVT file. Choose 1')
    [DVTfile,~] = uigetfile('*.DVT','Select which DVT file');
else
    DVTfile = DVTfileMaybe.name;
end
pos_data = importdata(DVTfile);
time = pos_data(:,2);

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
    %which is it? need lstdlg
end    
clear FTstuff

FToffset = ceil(time(1)*fps_brainimage);
PlxEndsAfterImagingS = size(FT,2)*(1/20)-time(end);

%FToffset = ceil(time(1)*fps_brainimage)/(1/fps_brainimage);

%plxStart = time(1);
%fps_brainimage = 20; % frames/sec for brain image timestamps
%nVistaDT = 1/fps_brainimage;
%FToffset = ceil(plxStart/nVistaDT); %number of imaging frames gathered when 
%plexon starts
%{

fTime = (1:size(FT,2))/SR;
fStart = findclosest(MoMtime,fTime);


plexTime = (0:length(x)-1)/SR+start_time;
pStart = findclosest(MoMtime,plexTime);


FToffset = fStart + HalfWindow + 1;
%}
end