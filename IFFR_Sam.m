function [PFhits, PFiffr]=IFFR_Sam(session,varargin)
% [PFhits, PFiffr]=IFFR_Sam(session,varargin)
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
%   data, though could be run on continuous or delayed alternation blocks
%   separately
% 
% OUTPUT - Tables aligned in same format as PFepochs and similar, 3rd
% dimension is context/block type (e.g. 1 = continuous, 2 = delayed)
%
%    Hits table, number of passes in field with hits
%    Passes table - not that different from PFepochs, but separated by
%    context
%    IFFR table, with rates aligned in same format as PFepochs etc.,
%
%   varargins:
%   - 'use_alt_PMfile': enter in alternate file to PlaceMaps.mat if you
%   wish.
%
%   - 'use_prev_blockind': 1 = lets you load the blockInd from a previous run if you
%   wish. 0 = re-run with manual selection of block starts/ends (default).
%   This loads ONLY block indexing information and will overwrite all the
%   PFiffr, PFhits, and PFpasses outputs
%
%   - 'name_append': saves Piffr.mat (default) with whatever you append
%   here, e.g. ...'name_append','_yourchoice'... gives you
%   Piffr_yourchoice.mat
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

%% Get varargins
PFstats_file = 'PFstats.mat'; % default
name_append = []; % default
use_prev_blockind = 0; % default
for j = 1:length(varargin)
   if strcmpi(varargin{j},'use_alt_PFstatsfile')
       PFstats_file = varargin{j+1};
   end
   if strcmpi(varargin{j},'use_prev_run')
       use_prev_blockind = varargin{j+1};
   end
   if strcmpi(varargin{j},'name_append')
       name_append = varargin{j+1};
   end
end

%% Create savename for Piffr file later on
savename = ['Piffr' name_append '.mat'];

%% Load appropriate files
cd(session.Location)
tempScale=20;%frames per second
load Pos_align.mat x_adj_cm y_adj_cm
load PlaceMaps.mat FT t 
load(PFstats_file, 'PFepochs', 'PFnumepochs', 'PFactive')

%% This block asks the user to describe the bounds for each context type
if use_prev_blockind == 1 % Skip manual selection of bounds if indicated
    load(savename,'blockInd','blockTypes');
elseif use_prev_blockind == 0 % Proceed with manual selection of bounds
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
keyboard

[PFepochs_blocks] = assign_block_to_epoch(PFepochs,blockInd);

for d=1:length(blockTypes);% iterate through each context/block d
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
                    PFyes{k,l,d}(b)= any(FTonset{b} >= thisEpoch(1) & FTonset{b} <= thisEpoch(2)); % Think this is an error - should pre-allocate
%                     PFyes2{k,l,d}(b) = PFactive{PFinds(a)}(b);
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
%         PFhits2(k,l,d) = sum(PFyes2{k,l,d});
        PFpasses(k,l,d)=length(PFyes{k,l,d});
%         PFpasses2(k,l,d)=length(PFyes2{k,l,d});
        PFiffr(k,l,d)=(PFhits(k,l,d)/PFpasses(k,l,d))*100;
    end
end

keyboard
save(savename, 'PFhits', 'PFiffr', 'PFpasses', 'blockInd', 'blockTypes')

end

%% Sub-function
function [PFepochs_blocks] = assign_block_to_epoch(PFepochs,blockInd)

PFepochs_blocks = cell(size(PFepochs));
for j = 1:size(PFepochs,1) % each neuron
    for k = 1:size(PFepochs,2) % each PF
        PFepochs_blocks{j,k} = zeros(size(PFepochs{j,k},1),1);
        if ~isempty(PFepochs{j,k})
            for block_type = 1:length(blockInd) % each block type
                for num_block = 1:size(blockInd{block_type},1) % each block for a given block type
                    try
                        in_block_binary = PFepochs{j,k}(:,1) > blockInd{block_type}(num_block,1) & ...
                            PFepochs{j,k}(:,2) < blockInd{block_type}(num_block,2); % decides if the epochs are within the given block
                        PFepochs_blocks{j,k}(in_block_binary) = block_type; % Assign block number to valid epochs
                    catch
                        disp('assign_block_to_epoch error catching')
                        keyboard
                    end
                    
                end
            end
        end
    end
end
end

%% Sub-function
function [PFhits2, PFpasses2] = assign_hits(PFepochs_blocks,PFactive,num_block_types)

for j = 1:size(PFactive,1)
    for k = 1:size(PFactive,2)
        for ll = 1:num_block_types
            
            PFhits2 = sum(PFactive{j,k}(PFepochs_blocks{j,k} == ll)); % Sum up all passes through neuron j, PF k in block_type ll where there was a transient
            PFpasses2 = sum(PFepochs_blocks{j,k} == ll); % Sum up al passes through neuron j, PF k in block_type
            
        end
    end
end

end