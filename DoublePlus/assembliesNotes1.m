for sessI = 1:3

%sessI = 3;
Activitymatrix = [];
for condI = 1:2%condsUse
    Activitymatrix = [Activitymatrix, trialbytrialAll(condI).trialPSAbool{trialbytrialAll(condI).sessID==sessI}];
    %Activitymatrix = [Activitymatrix, cellTBTall{1}(condI).trialPSAbool{cellTBTall{1}(condI).sessID==sessI}];
end    
  %Patterns = assembly_patterns(Activitymatrix);
ppp{sessI} = assembly_patterns(Activitymatrix);
end

for ii = 1:16
    for jj = 1:28
    [rr(ii,jj),pp(ii,jj)] = corr(ppp{1}(:,ii),ppp{2}(:,jj),'type','Pearson');
    end
end
    


Activities = assembly_activity(ppp{3},Activitymatrix);


figure; stem(Patterns(dayUseAll{2}(:,sessI),1))


% Look for "same assembly" by correlation of weights
% If there are cells that change assembly, do those cells also remap?