ParseDoublePlusBehavior

load Pos_align.mat
load BaseBehaviorBounds.mat


%Find positions on pedestal
%nan those out

%Find epochs through the center

%Find epochs on start arms

%Find epochs on end arms

%Jumps from arm end to arm end are lap boundaries
    %use that to find stard and ends of all laps
    
%Laps that are Start - middle - end are good

%save bad laps, but organize into:
    %- allowed correction
    %- did not allow correction
    %- aberrant behavior (went back to start, ran straight south, etc.
    
%parse these all into 
    % - get on maze
    % - start lap
    % - enter center
    % - leave center
    % - enter reward area
    % - leave maze
