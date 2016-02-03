function [PFhits, PFiffr]=IFFR_Sam(session)
% [PFhits, PFiffr]=IFFR_Sam(session)
% This function gets the in-field firing rate for a session of alternation
% data, for which tenaspis has already been run and places fields already
% described. IFFR is calculated in two ways: 1) Number of transients in a
% given pass, divided by the time in the field on that pass, and 2) Whether
% or not there was a transient in a given pass through a place field, output
% as a ratio of passes with a transient / total number of passes. Function
% is currently set up to only output the second option, though first and
% various intermediate steps can be uncommented / made modular.
%
%
% INPUT - session
%   Additionally, this function is built to run on the entire session's
%   data, though could be run on continuous or alternation blocks
%   separately
% 
% OUTPUT - Tables aligned in same format as PFepochs and similar, 3rd
% dimension is context
%
%    Hits table, number of passes in field with hits
%    Passes table - not that different from PFepochs, but separated by
%    context
%    IFFR table, with rates aligned in same format as PFepochs etc.,
% 

% Run MakeMouseSessionList if inputs require you to do so
% if nargin == 2 && ~isempty(userstr)
%     [MD, ref] = MakeMouseSessionList(userstr);
%     session = MD(session);
% end

%{
%Under construction
if ~exist('session','var')
    while ~exist('session','var')
        keyboard
    end
end
%}
%Check whether or not to plot a test field
%Under construction
%{
if exist('varargin','var') && strcmpi(varargin{1},fieldCheck)
    fieldCheck=varargin{2};
    fieldtoCheck=varargin{3};
else
    fieldCheck=0;
end
%}
%Output choice from a varargin: requires varargouts, more varargin handling


%% Load appropriate files
cd(session.Location)
tempScale=20;%frames per second
load Pos_align.mat x_adj_cm y_adj_cm
load PlaceMaps.mat FT t 
load PFstats.mat PFepochs PFnumepochs

%% This block asks the user to describe the bounds for each context type
blockTypes={'continuous'; 'delay'};
for f=1:length(blockTypes)
    numBlocks(f)=input(['How many ' blockTypes{f} ' blocks?']);  
    if numBlocks(f)>0
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
    [times,~] = ginput(numBlocks(f)*2);
    times(times<0)=0;
    close(h)
    blockInd{f}=[times([1:2:length(times)-1]) times([2:2:length(times)])];
    end
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
PFiffr=zeros(sized);

%% Get indices in PFepochs to run, so don't have to loop through entire array
check=PFnumepochs;
check(check~=0)=1;
PFinds=find(check);
%% Get onsets of firing for each row in FT
[r,~]=size(PFepochs);
FTonset=cell(r,1);
for v=1:r
    FTonset{v}=find(diff(FT(v,:))==1)+1;
end

%% Run through each pass through each field (PFepochs) and see if there was a spike there
for d=1:length(blockTypes);%context d
thisBlockInds=blockInd{d};   
for a=1:length(PFinds)%place field a
[k,l]=ind2sub(size(PFepochs),PFinds(a));%PF large matrix index location 
if exist('fieldCheck','var') && fieldCheck==1 && a==fieldToCheck
    plot(t,x_adj_cm)
end
    for b=1:PFnumepochs(PFinds(a))%pass through field b
        thisEpoch=PFepochs{PFinds(a)}(b,:);
        [q,~]=size(blockInd{d});
        for gg=1:q%generalization for number of blocks in context d
        if any(thisEpoch(1) >= thisBlockInds(gg,1)) && thisEpoch(2) <= thisBlockInds(gg,2)%|| thisEpoch(1) >= thisBlockInds(2,1) && thisEpoch(2) <= thisBlockInds(2,2)
            if exist('fieldCheck','var') && fieldCheck==1 && a==fieldToCheck
                hold on
                plot(t(thisEpoch(1)),x_adj_cm(thisEpoch(1)),'.r')
                plot(t(thisEpoch(2)),x_adj_cm(thisEpoch(2)),'.r')
            end
            %Type 1 Spikes per duration in field k, l pass b condition d
            %PFrates{k,l,d}(b)=sum(FT(i,thisEpoch(1):thisEpoch(2)))/((thisEpoch(2)-thisEpoch(1)+1)/tempScale);
            
            %Type 2 Was there a hit on pass b through field k, l condition d
            PFyes{k,l,d}(b)= any(FTonset{b} >= thisEpoch(1) & FTonset{b} <= thisEpoch(2));
        end
        end
    end
    %Rate type 1
    %{
    %PFrateAverageNO(k,l,d)=mean(PFrates{k,l,d}(PFrates{k,l,d}~=0));
    %PFrateAverage(k,l,d)=mean(PFrates{k,l,d});
    %PFrateMax(k,l,d)=max(PFrates{k,l,d});
    %}
    %Rate type 2
    PFhits(k,l,d)=sum(PFyes{k,l,d});
    PFpasses(k,l,d)=length(PFyes{k,l,d});
    PFiffr(k,l,d)=(PFhits(k,l,d)/PFpasses(k,l,d))*100;
end        
end

save PFiffr.mat PFhits PFiffr PFpasses blockInd blockTypes

end