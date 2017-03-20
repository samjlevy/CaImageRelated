function [FToffset, LastUsable, whichEndsFirst ] = JustFToffset(varargin)
%Sam's version of getting FToffset.Does not use MoMtime, uses entirety of
%tracking. Last usable is the last usable frame of which ever is longer,
%indicated as the opposite of whichever is indicated by whichEndsFirst. 
%This is all based on time from the DVT and assumed-equal timing in the 
%imaging file.

disp('NEEDS TESTING')

useXml = 0;
for aa=1:length(varargin)
    if strcmp(varargin{aa},'xml_file')
        xml_file = varargin{aa+1};
        useXml = 1;
    end
end    

fps_brainimage = 20; % frames/sec for brain image timestamps

DVTfileMaybe = dir('*.DVT');
if length(DVTfileMaybe) ~= 1
    disp('Did not find 1 DVT file. Choose 1')
    [DVTfile,~] = uigetfile('*.DVT','Select which DVT file');
else
    DVTfile = DVTfileMaybe.name;
end
pos_data = importdata(DVTfile);
time = pos_data(:,2);

switch useXml
    case 0
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
            %which is it? need lstdlg on struct fields
        end
        
        FTlength = size(FT,2);
        clear FTstuff
        clear FT
    case 1
        findLabel = '<attr name="frames">';
        fileID = fopen(xml_file);
        xmlText = textscan(fileID,'%s','Delimiter', '\n','CollectOutput', true);
        for xmlLine = 1:length(xmlText{1,1})
            if length(xmlText{1,1}{xmlLine,1}) >= length(findLabel)
            if strcmp(findLabel,xmlText{1,1}{xmlLine,1}(1:length(findLabel)))
                strEnd = strfind(xmlText{1,1}{xmlLine,1}, '</attr>');
                FTlength = str2double(xmlText{1,1}{xmlLine,1}((length(findLabel)+1):(strEnd-1)));
                break
            end
            end
        end    
end        

%FToffset gives first imaging frame >= first tracking frame
FToffset = ceil(time(1)*fps_brainimage);

brainTime = (1:FTlength)*(1/fps_brainimage);

PlexEndsAfterImaging = time(end)-FTlength*(1/fps_brainimage);
switch PlexEndsAfterImaging > 0
    case 0
        whichEndsFirst = 'tracking';
        %Last brain frame before tracking ends
        LastUsable = find(brainTime <= time(end), 1, 'last');
    case 1 
        whichEndsFirst = 'imaging';
        %First tracking frame after imaging ends
        LastUsable = find(time >= brainTime(end), 1, 'first');
end        

save FToffsetSam.mat FToffset LastUsable whichEndsFirst

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