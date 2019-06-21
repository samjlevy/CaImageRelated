function trialbytrial = PoolTrialsAcrossSessions(bounds,all_x_adj_cm,all_y_adj_cm,all_PSAbool,RawTrace,sessionInds,lapNumber)
%Assumes fields are in the order you want

%Right Now assumes RawTrace is aligned, could fix that later

if any(sessionInds)
[~, all_PSAbool_aligned] = PoolPSA(all_PSAbool, sessionInds);
else 
    disp('sortedSessionInds is empty, not reorganizing PSAbool')
    all_PSAbool_aligned = all_PSAbool;
end

switch class(bounds)
    case 'cell'
        ss = fieldnames(bounds{1}); %should always be 4
    case 'struct'
        ss = fieldnames(bounds(1)); %should always be 4
end

for fn = 1:length(ss) %condition
    row = 0;
    for sess = 1:length(all_x_adj_cm)
        switch class(bounds)
            case 'cell'
                for lap = 1:size(bounds{sess}.(ss{fn}),1)
                    row = row + 1;
                    getInds = bounds{sess}.(ss{fn})(lap,1):bounds{sess}.(ss{fn})(lap,2);
                    trialbytrial(fn).trialsX{row,1} = all_x_adj_cm{sess}(getInds);
                    trialbytrial(fn).trialsY{row,1} = all_y_adj_cm{sess}(getInds);
                    trialbytrial(fn).trialPSAbool{row,1} = logical(all_PSAbool_aligned{sess}(:,getInds));
                    if ~isempty(RawTrace)
                        trialbytrial(fn).trialRawTrace{row,1} = RawTrace{sess}(:,getInds);
                    end
                    trialbytrial(fn).sessID(row,1) = sess;
                    trialbytrial(fn).name = ss{fn};
                    trialbytrial(fn).lapNumber(row,1) = lapNumber(sess).(ss{fn}).correct(lap);
                end
            case 'struct'
                for lap = 1:size(bounds(sess).(ss{fn}),1)
                    row = row + 1;
                    getInds = bounds(sess).(ss{fn})(lap,1):bounds(sess).(ss{fn})(lap,2);
                    trialbytrial(fn).trialsX{row,1} = all_x_adj_cm{sess}(getInds);
                    trialbytrial(fn).trialsY{row,1} = all_y_adj_cm{sess}(getInds);
                    trialbytrial(fn).trialPSAbool{row,1} = logical(all_PSAbool_aligned{sess}(:,getInds));
                    if ~isempty(RawTrace)
                        trialbytrial(fn).trialRawTrace{row,1} = RawTrace{sess}(:,getInds);
                    end
                    trialbytrial(fn).sessID(row,1) = sess;
                    trialbytrial(fn).name = ss{fn};
                    trialbytrial(fn).lapNumber(row,1) = lapNumber(sess).(ss{fn}).correct(lap);
                end
        end
    end
end

%{
ss = fieldnames(bounds{1}); %should always be 4
for fn = 1:4
    row = 0;
    for sess = 1:length(all_x_adj_cm)
        for lap = 1:size(bounds(sess).(ss{fn}),1)
            row = row + 1;
            getInds = bounds(sess).(ss{fn})(lap,1):bounds(sess).(ss{fn})(lap,2);
            trialbytrial(fn).trialsX{row,1} = all_x_adj_cm{sess}(getInds);
            trialbytrial(fn).trialsY{row,1} = all_y_adj_cm{sess}(getInds);
            trialbytrial(fn).trialPSAbool{row,1} = logical(all_PSAbool_aligned{sess}(:,getInds));
            trialbytrial(fn).sessID(row,1) = sess;
            trialbytrial(fn).name = ss{fn};
        end
    end
end
%}

end