function PlacefieldsLinSL(MD,varargin)
%Placefields(MD,varargin)
%
%   Main course function for calculating place fields, based off Dave
%   Sullivan's. Looks at epochs where mouse is running and produces a
%   spatial heatmap of firing for each neuron. Also runs a permutation test
%   to ask whether a place field is better than expected by chance. This is
%   done by shuffling transient times (deck of cards shuffle) while keeping
%   position fixed, misaligning position and spiking. Mutual information
%   (see Olypher et al., 2003 and spatInfo) is calculated using real and
%   shuffled data and compared to produce p-value.
%
%   INPUTS
%       MD: session to analyze. 
%
%       optional...
%       exclude_frames: vector of frames to exclude from aligned position
%       data. Can either be the indices of the aligned data OR the indices
%       of non-aligned TENASPIS data. Only tested this first case, but the
%       code for the second case should work.
%
%       cmperbin: centimeters per spatial bin. Default = 1.
%
%       minspeed: velocity threshold for saying that the mouse is running.
%       Default = 3 cm/s.
%
%       B: number of permutation iterations for determining the legitimacy
%       of a place field. Default = 1,000.
%
%       aligned: logical telling this function whether the Pos_data
%       variable you entered has already been aligned or not. Default =
%       true. 
%
%       Pos_data: output of PreprocessMousePosition_auto, aligned or not
%       aligned. Default = Pos_align.mat.
%
%       Tenaspis_data: output of Tenaspis. Default = FinalOutput.mat.

%% Parse inputs.
    cd(MD.Location);
    
    ip = inputParser;
    ip.addRequired('MD',@(x) isstruct(x)); 
    ip.addParameter('exclude_frames',[],@(x) isnumeric(x)); 
    ip.addParameter('cmperbin',1,@(x) isscalar(x)); 
    ip.addParameter('minspeed',3,@(x) isscalar(x)); 
    ip.addParameter('B',1000,@(x) isscalar(x));
    ip.addParameter('aligned',true,@(x) islogical(x));
    ip.addParameter('Pos_data','Pos_align.mat',@(x) ischar(x));
    ip.addParameter('Tenaspis_data','FinalOutput.mat',@(x) ischar(x)); 
    ip.addParameter('save_append',[],@(x) ischar(x));
    ip.addParameter('dim_use','x',@(x) ischar(x));
    
    ip.parse(MD,varargin{:});
    
    %Compile.
    exclude_frames = ip.Results.exclude_frames;
    cmperbin = ip.Results.cmperbin;
    minspeed = ip.Results.minspeed;
    B = ip.Results.B; 
    aligned = ip.Results.aligned;
    Pos_data = ip.Results.Pos_data;
    Tenaspis_data = ip.Results.Tenaspis_data;
    dim_use = ip.Results.dim_use;
    
%% Set up.
    if aligned
        load('Pos_align.mat',...
            'PSAbool','x_adj_cm','y_adj_cm','speed','xmin','xmax','ymin','ymax'); 
        x = x_adj_cm; y = y_adj_cm; clear x_adj_cm y_adj_cm;
    else
        disp('Not aligned, probably and error now')
    end
    
    %Basic variables. 
    [nNeurons,nFrames] = size(PSAbool); 
    velocity = convtrim(speed,ones(1,2*20))./(2*20);    %Smooth velocity (cm/s).
    good = true(1,nFrames);                             %Frames that are not excluded.
    good(logical(exclude_frames)) = false;
    isrunning = good;                                   %Running frames that were not excluded. 
    isrunning(velocity < minspeed) = false;
    if sum(isrunning) < 0.33*length(isrunning)
        disp(['Warning: only ' num2str(sum(isrunning))...
            ' isrunning out of ' num2str(length(isrunning))])  
    end
    
    switch dim_use
        case 'x'
            %do nothing
        case 'y'
            x = y; xmin = ymin; xmax = ymax;
    end
    
%% Get occupancy map. 
    xmin = min(x(isrunning)); xmax = max(x(isrunning));
    %ymin = min(y(isrunning)); ymax = max(y(isrunning));
    
    lims = [xmin xmax];
    [OccMap,RunOccMap,xEdges,xBin] = ...
        MakeOccMapLin(x,lims,good,isrunning,cmperbin);
     %{
    plot(x(isrunning),y(isrunning),'.')
    for yy = 1:length(yEdges)
        hold on
        plot([xEdges(1) xEdges(end)],[yEdges(yy) yEdges(yy)],'b')
    end
    for xx = 1:length(xEdges)
        hold on
        plot([xEdges(xx) xEdges(xx)],[yEdges(1) yEdges(end)],'b')
    end
    plot(x(stem_frame_bounds.forced_r(:,1)),y(stem_frame_bounds.forced_r(:,1)),'.r')
    %}


    % Sam's whole session xBin
    TotalOccMap = histcounts2(x,y,xEdges,yEdges); 
    [TotalRunOccMap,~,~,xBinTotal,yBinTotal] =...
        histcounts2(x,y,xEdges,yEdges); 
    
    %Don't need non-isrunning epochs anymore.
    runningInds = find(isrunning);
    x = x(isrunning);
    y = y(isrunning);
    PSAbool = logical(PSAbool(:,isrunning));
    nGood = length(x); 
    
%% Construct place field and compute mutual information.
    %Preallocate.
    TCounts = cell(1,nNeurons);
    TMap_gauss = cell(1,nNeurons); 
    TMap_unsmoothed = cell(1,nNeurons); 
    pos = x;
    parfor n=1:nNeurons    
        %Make place field.
        [TMap_unsmoothed{n},TCounts{n},TMap_gauss{n}] = ...
            MakePlacefieldLin(PSAbool(n,:),pos,xEdges,yEdges,RunOccMap,...
            'cmperbin',cmperbin,'smooth',true);
    end
    
    %Compute mutual information.
    MI = spatInfo(TMap_unsmoothed,RunOccMap,PSAbool,true);
    
%% Get statistical significance of place field using mutual information.
    %Preallocate. 
    pval = nan(1,nNeurons);
    
    %Set up progress bar.
    resolution = 2;
    updateInc = round(nNeurons/(100/resolution));
    p = ProgressBar(100/resolution);
    parfor n=1:nNeurons
        
        %Predetermine transient frame shifts, disassociates transients from
        %location. 
        rTMap = cell(1,B);
        shifts = randi([0 nGood],B,1); 
        for i=1:B
            %Circular shift. 
            shuffled = circshift(PSAbool(n,:),[0 shifts(i)]);
            
            %Make place field from shifted transient vector. 
            rTMap{i} = MakePlacefield(shuffled,pos,xEdges,yEdges,...
                RunOccMap,'cmperbin',cmperbin,'smooth',false); 

        end

        %Calculate mutual information of randomized vectors. 
        rMI = spatInfo(rTMap,RunOccMap,repmat(PSAbool(n,:),[B,1]),false); 

        %Get p-value. 
        pval(n) = 1-(sum(MI(n)>rMI)/B); 
        
        if round(n/updateInc) == (n/updateInc)
            p.progress;
        end
    end
    p.stop; 
    
    save_append = ip.Results.save_append;
    savename = ['Placefields' save_append '.mat'];
    save(savename,'OccMap','RunOccMap','TCounts','TMap_gauss',...
        'TMap_unsmoothed','minspeed','isrunning','cmperbin','exclude_frames',...
        'xEdges','yEdges','xBin','yBin','pval','TotalOccMap','TotalRunOccMap',...
        'xBinTotal','yBinTotal','runningInds'); 
end