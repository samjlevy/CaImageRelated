function [shuffTBT] = ShuffleTBT2(tbt,condsShuffle,preserveNumLaps)

% preserveNumLaps is a binary which allows preserving the number of laps in
% each of the conds being shuffled


ff = fieldnames(tbt);
shuffleField = false(length(ff),1);
for ffI = 1:length(ff)
    shuffleField(ffI,1) = length(tbt(1).(ff{ffI})) == length(tbt(1).trialsX); 
    for condI = 1:2
        shuffTBT(condI).(ff{ffI}) = [];
    end
end
shuffTBT(1).shuffSourceCond = []; shuffTBT(1).shuffSourceLaps = [];
shuffTBT(2).shuffSourceCond = []; shuffTBT(2).shuffSourceLaps = [];
shuffTBT(1).seqHere = tbt(condsShuffle(1)).seqHere;
shuffTBT(2).seqHere = tbt(condsShuffle(2)).seqHere;

for sessI = 1:9
    lapsA = find(tbt(condsShuffle(1)).sessID == sessI);
    lapsB = find(tbt(condsShuffle(2)).sessID == sessI);
    
    numTrialsA = length(lapsA);
    numTrialsB = length(lapsB);
    
    numTrials = numTrialsA + numTrialsB;
    
    sourceLaps = [lapsA; lapsB];
    sourceConds = [condsShuffle(1)*ones(numTrialsA,1); condsShuffle(2)*ones(numTrialsB,1)];
    
    shuffOrder = randperm(numTrials)';
    
    shuffLaps = sourceLaps(shuffOrder);
    shuffConds = sourceConds(shuffOrder);
    
    if preserveNumLaps == false
        numTrialsA = floor(numTrials/2);
        numTrialsB = ceil(numTrials/2);
    end
    
    destConds = [1*ones(numTrialsA,1); 2*ones(numTrialsB,1)];
    
    shuffTo{1} = destConds==1;
    shuffTo{2} = destConds==2;
    
    for condI = 1:2
        for condJ = 1:2
            srcCondH = condsShuffle(condJ);
                
            % aa = [shuffTo{condI}  shuffConds==srcCondH];
            lapsGet = shuffLaps(shuffTo{condI} & shuffConds==srcCondH);
            if length(lapsGet) ~= length(unique(lapsGet))
                keyboard
            end
            lapsGet = sort(lapsGet);
            
            for ffI = 1:length(ff)
                if shuffleField(ffI)==true
                    shuffTBT(condI).(ff{ffI}) = [shuffTBT(condI).(ff{ffI}); tbt(srcCondH).(ff{ffI})(lapsGet)];
                    %{
                    switch class(tbt(condJ).(fns{fnI}))
                        case {'double','logical'}
                            splitTBT(condI).(fns{fnI})(destLap,1) = tbt(condJ).(fns{fnI})(sourceLap,1);
                        case 'cell'
                            splitTBT(condI).(fns{fnI}){destLap,1} = tbt(condJ).(fns{fnI}){sourceLap,1};
                    end
                    %}
                end
            end
            shuffTBT(condI).shuffSourceCond = [shuffTBT(condI).shuffSourceCond; srcCondH*ones(length(lapsGet),1)];
            shuffTBT(condI).shuffSourceLaps = [shuffTBT(condI).shuffSourceLaps; lapsGet];
        end
    end
end
    
end