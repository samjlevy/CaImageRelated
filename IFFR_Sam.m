function []=IFFR_Sam(userstr,session)
% This function gets the in-field firing rate for a session of alternation
% data, for which tenaspis has already been run and places fields already
% described. IFFR is calculated in two ways: 1) Number of transients in a
% given pass, divided by the time in the field on that pass, and 2) Whether
% or not there was a transient in a given pass through a place field, output
% as a ratio of passes with a transient / total number of passes. Function
% is currently set up to only output the second option, though first and
% various intermediate steps can be uncommented.
%
% INPUT - userstr
%   Additionally, this function is built to run on the entire session's
%   data, though could be run on continuous or alternation blocks
%   separately
% 
% OUTPUT - IFFR table, with rates aligned in same format as PFepochs etc.,
% 3rd matrix dimension as context (right now continuous and delayed, could
% be generalized. 
%
%
%
[MD, ref] = MakeMouseSessionList('Sam');

%% Load appropriate files
cd(MD(session).Location)
tempScale=20;%frames per second
load Pos_align.mat x_adj_cm y_adj_cm
load PlaceMaps.mat FT t pval
load PFstats.mat PFepochs PFnumepochs

%% This block asks the user to describe the bounds for each context type
blockTypes={'continuous'; 'delay'};
for f=1:length(blockTypes)
    numBlocks(f)=input(['How many ' blockTypes{f} ' blocks?']);  
    h=figure;
    subplot(2,1,1)
    plot(1:length(t),x_adj_cm)
    xlim([-5000,length(t)+5000])
    ylabel('X position')
    title(['Select block start-stop for all ' blockTypes{f} ' blocks'])
    subplot(2,1,2)
    plot(1:length(t),y_adj_cm)
    xlim([-5000,length(t)+5000])
    ylabel('Y position')
    disp(['Select block start-stop for all ' blockTypes{f} ' blocks'])
    [times,ys] = ginput(numBlocks(f)*2);
    times(times<0)=0;
    close(h)
    blockInd{f}=[times([1:2:length(times)-1]) times([2:2:length(times)])];
end

%% Preallocate for all arrays being used
sized=[size(PFepochs),length(blockTypes)];
%Rate type 1
%{ 
%PFrateAverage=zeros(sized);
%PFrateAverageNO=zeros(sized);
%PFrateMax=zeros(sized);
%PFrates2=cell(sized);
%}
%Rate type 2
PFyes=cell(size(PFepochs));
PFhits=zeros(sized);
PFblockpasses=zeros(sized);
PFiffr=zeros(sized);

%% Get indices in PFepochs to run, so don't have to loop through entire array
check=PFnumepochs;
check(check~=0)=1;
PFinds=find(check);
%% Get onsets of firing for each row in FT
[r,c]=size(PFepochs);
FTonset=cell(r,1);
parfor v=1:r
    FTonset{v}=find(diff(FT(v,:))==1)+1;
end

%% Run through each pass through each field (PFepochs) and see if there was a spike there
for d=1:length(blockTypes);
thisBlockInds=blockInd{d};   
for a=1:length(PFinds)
[k,l]=ind2sub(size(PFepochs),PFinds(a));
if fieldCheck==1 and a==fieldToCheck
    plot(t,x_adj_cm)
end
    for b=1:PFnumepochs(PFinds(a))
        thisEpoch=PFepochs{PFinds(a)}(b,:);
        %This conditional to separate by block is still hardcoded
        if any(thisEpoch(1) >= thisBlockInds(1,1)) && thisEpoch(2) <= thisBlockInds(1,2)...
                || thisEpoch(1) >= thisBlockInds(2,1) && thisEpoch(2) <= thisBlockInds(2,2)
            %Sets array entry as spikes per duration in field
            %[i,j]=ind2sub(size(PFepochs),PFinds(a));
            %PFrates{k,l,d}(b)=sum(FT(i,thisEpoch(1):thisEpoch(2)))/((thisEpoch(2)-thisEpoch(1)+1)/tempScale);
            %plot(t(thisEpoch(1)),x_adj_cm(thisEpoch(1)),'.r')
            %plot(t(thisEpoch(2)),x_adj_cm(thisEpoch(2)),'.r')
            PFyes{k,l,d}(b)= any(FTonset{v} >= thisEpoch(1) & FTonset{v} <= thisEpoch(2));
        end
    end
    PFhits(k,l,d)=sum(PFyes{k,l,d});
    PFblockpasses(k,l,d)=length(PFyes{k,l,d});
    PFiffr(k,l,d)=PFhits(k,l,d)/PFblockpasses(k,l,d);
    %PFpass(k,l,d)=length(find(PFrates2{k,l,d}))/length(PFrates2{k,l,d});
    %PFrateAverageNO(k,l,d)=mean(PFrates{k,l,d}(PFrates{k,l,d}~=0));
    %PFrateAverage(k,l,d)=mean(PFrates{k,l,d});
    %PFrateMax(k,l,d)=max(PFrates{k,l,d});
end        
end
%% Last post-processing to get means

end