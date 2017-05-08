function [OccMap,RunOccMap,xEdges,xBin] = ...
    MakeOccMapLin(x,lims,good,isrunning,cmperbin)
%[OccMap,RunOccMap,xEdges,yEdges] = ...
%    MakeOccMap(x,y,lims,good,isrunning,cmperbin)
%   
%   Sam's adjustmenst to do linear place fields; only for 1d data right now
%   Makes occupancy maps given X/Y limits and position. 
%
%   INPUTS
%       X & Y: mouse position, aligned.
%
%       lims: 1x2 matrix where [xmin xmax]
%
%       good: all frames minus ones specified by exclude frames. 
%
%       isrunning: all good frames where mouse velocity exceeds minspeed.
%
%       cmperbin: centimeteres per spatial bin.
%
%   OUPUTS
%       OccMap: occupancy map (in frames counts).
%
%       RunOccMap: occupancy map where mouse is running (in frame counts). 
%
%       xEdges: edges used for histogram.
%

%% Extract limits.
    xmin = lims(1);
    xmax = lims(2); 

%% Make edges for hist2.
    Xrange = xmax-xmin; 
    
    nXBins = ceil(Xrange/cmperbin); 
    
    xEdges = (0:nXBins)*cmperbin+xmin;
 
%% Run 2D histogram function.
    OccMap = histcounts(x(good),xEdges); 
    [RunOccMap,~,xBin] = histcounts(x(isrunning),xEdges); 
end