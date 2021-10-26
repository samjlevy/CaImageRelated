function [splitTBT,nLapsH] = SmallSplitterTBT(tbt,armPairs,lapConds,sessNums)
% Breaks up a tbt into a smaller 2-cond tbt for checking splitters

%{
armPairs is a 2x2 cell array:
{ startArm1 endArm1
  startArm2 endArm2 }
which goes with lap conds to indicate which lap type to draw this from:
[cond1, cond2]
so to get prospective splitters from north arm, this is:
armPairs = ...
{'n' 'w';...
 'n' 'e'}   
lapConds = [1 1];
or retrospective on east arms    
armPairs = ...
{'n' 'e';...
{'s' 'e'};
lapConds = [4 4];
%}

if isempty(sessNums)
    sessNums = 1:9;
    %condsCheck = unique(condPairs(:));
    %{
    condsCheck = length(tbt);
    cc = [];
    for condI = 1:length(condsCheck)
        cc = [cc; unique(tbt(condsCheck(condI)).sessID)];
    end
    sessNums = unique(cc);
    %}
end

fns = fieldnames(tbt);

for condI = 1:2
    for fnI = 1:length(fns)
        splitTBT(condI).(fns{fnI}) = [];
    end
    splitTBT(condI).seqHere = [armPairs{condI,1} '-' armPairs{condI,2}];
end

nLapsH = zeros(length(sessNums),2);

for sessI = 1:length(sessNums)
    sessH = sessNums(sessI);
    
    for condI = 1:2
        condJ = lapConds(condI);
        startH = armPairs{condI,1};
        endH = armPairs{condI,2};
        
        seqThree = cellfun(@(x) length(x)==3,tbt(condJ).lapSequence);
        sessLaps = tbt(condJ).sessID==sessH;
        
        lapsS = cellfun(@(x) x(1)==startH,tbt(condJ).lapSequence); % Laps that start with startH
        lapsE = cellfun(@(x) x(end)==endH,tbt(condJ).lapSequence); % Laps that end with endH
        
        lapsUse = find(seqThree & sessLaps & lapsS & lapsE);
        
        nLapsH(sessI,condI) = length(lapsUse);
        
        if any(lapsUse)
        for lapI = 1:length(lapsUse)
            destLap = length(splitTBT(condI).trialsX)+1;
            sourceLap = lapsUse(lapI);
            for fnI = 1:length(fns)
                switch class(tbt(condJ).(fns{fnI}))
                    case {'double','logical'}
                        splitTBT(condI).(fns{fnI})(destLap,1) = tbt(condJ).(fns{fnI})(sourceLap,1);
                    case 'cell'
                        splitTBT(condI).(fns{fnI}){destLap,1} = tbt(condJ).(fns{fnI}){sourceLap,1};
                end
            end
        end
        end
    end
end

