%%If DVT doesn't work, use idTracker to get better points
%%
[trajFile,trajFolder]=uigetfile('*.mat','Choose idTracker file to convert');
[DVTfile,DVTfolder]=uigetfile('*.DVT','Choose same DVT file',trajFolder);
[AVIfile]=uigetfile('*.avi','Select same AVI file',trajFolder);
[saveFolder]=uigetdir(trajFolder,'Choose destination folder for converted file');
 
if exist(fullfile(saveFolder,'Video.txt'),'file')
    proceed=input('Video.txt already exists! Proceed anyway? y/n');
    if strcmpi(proceed,'n')
        return
    end
end

scale=input('Is scale on this video standard? (.6246) 1/0');
if scale==1
    scale=.6246;
elseif scale==0
    scale=input('Enter new scaling factor:');
end   
%%
posData = importdata(fullfile(DVTfolder,DVTfile));
load(fullfile(trajFolder,trajFile));
pos_data(:,1) = posData(:,1);%frame
pos_data(:,2)= posData(:,2);%time
if any(pos_data(end,1))==0 || any(pos_data(end,2))==0
    pos_data(end,:)=[];
end 
[r,c,s]=size(trajectories);
if r+1==length(pos_data)
    trajectories(r+1,1,1)=trajectories(end,1,1);
    trajectories(r+1,1,2)=trajectories(end,1,2);
end
trajtempX=trajectories(:,:,1);
trajtempX(isnan(trajtempX))=0;
pos_data(:,3)=trajtempX;
trajtempY=trajectories(:,:,2);
trajtempY(isnan(trajtempY))=0;
pos_data(:,4)=trajtempY;

%%
obj=VideoReader(AVIfile);
%{
obj.CurrentTime=1;
b=readFrame(obj);
figure(667)
gcf;
imagesc(flipud(b));
%}
MirrorPlane=obj.Height/2;
yAVI=pos_data(:,4);
yAVI(yAVI~=0)=yAVI(yAVI~=0)+2*(MirrorPlane-yAVI(yAVI~=0));
pos_data(:,4)=yAVI;
pos_data(:,3)=pos_data(:,3)/scale;
pos_data(:,4)=yAVI/scale;
%%
save(fullfile(saveFolder,'Video.txt'),'pos_data')
clear all
