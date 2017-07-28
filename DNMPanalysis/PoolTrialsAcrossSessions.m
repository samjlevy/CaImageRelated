function trialbytrial = PoolTrialsAcrossSessions(bounds,all_x_adj_cm,all_y_adj_cm,all_PSAbool,sessionInds)
%Assumes fields are in the order you want

[~, all_PSAbool_aligned] = PoolPSA(all_PSAbool, sessionInds);


ss = fieldnames(bounds{1}); %should always be 4
for fn = 1:4
    row = 0;
    for sess = 1:length(all_x_adj_cm)
        for lap = 1:size(bounds{sess}.(ss{fn}),1)
            row = row + 1;
            getInds = bounds{sess}.(ss{fn})(lap,1):bounds{sess}.(ss{fn})(lap,2);
            trialbytrial(fn).trialsX{row,1} = all_x_adj_cm{sess}(getInds);
            trialbytrial(fn).trialsY{row,1} = all_y_adj_cm{sess}(getInds);
            trialbytrial(fn).trialPSAbool{row,1} = logical(all_PSAbool_aligned{sess}(:,getInds));
            trialbytrial(fn).sessID(row,1) = sess;
        end
    end
end

end