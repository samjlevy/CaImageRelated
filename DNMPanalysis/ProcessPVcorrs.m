function [meanCorrOutOfShuff,pvCorrsOutOfShuff,meanCorrsOutShuff,numCorrsOutShuff,corrsOutCOM,lims95] =...
          ProcessPVcorrs(numPerms,pThresh,shuffMeanCorr,meanCorr,shuffPVcorrs,pvCorrs)

lims95 = [ceil(numPerms*(pThresh/2)) floor(numPerms-numPerms*(pThresh/2))];
%lims95 = [2 9];
%Mean sort shuffles, check if real is outside of shuffled
shuffMeanCorrSorted = cellfun(@sort,shuffMeanCorr,'UniformOutput',false);

upperMeanShuff = cellfun(@(x) x(lims95(2)),shuffMeanCorrSorted,'UniformOutput',false);
lowerMeanShuff = cellfun(@(x) x(lims95(1)),shuffMeanCorrSorted,'UniformOutput',false);

meanCorrOutOfShuff = cell2mat(cellfun(@(a,x,y) (a>x || a<y),meanCorr,upperMeanShuff, lowerMeanShuff,'UniformOutput',false));

%Indiv bins sort shuffles, check if real is outside of shuffled
shuffCorrsSorted = cellfun(@sort,shuffPVcorrs,'UniformOutput',false);
upperCorrShuff = cellfun(@(x) x(max(lims95),:),shuffCorrsSorted,'UniformOutput',false);
lowerCorrShuff = cellfun(@(x) x(min(lims95),:),shuffCorrsSorted,'UniformOutput',false);

aboveUpper = cellfun(@(a,x) a>x,pvCorrs,upperCorrShuff,'UniformOutput',false);
belowLower = cellfun(@(a,y) a<y,pvCorrs,lowerCorrShuff,'UniformOutput',false);

pvCorrsOutOfShuff = cellfun(@(e,f) (e+f)==1,belowLower,aboveUpper,'UniformOutput',false);
meanCorrsOutShuff = cell2mat(cellfun(@(g,h) mean(g(h)),pvCorrs,pvCorrsOutOfShuff,'UniformOutput',false));
numCorrsOutShuff = cell2mat(cellfun(@sum,pvCorrsOutOfShuff,'UniformOutput',false));
corrsOutCOM = cellfun(@FiringCOM,pvCorrsOutOfShuff,'UniformOutput',false);

bothOutError = cell2mat(cellfun(@(e,f) sum(e+f==2),belowLower,aboveUpper,'UniformOutput',false));
if any(sum(bothOutError,1))
    disp(['error: ' num2str(mouseI) ', some corr on both sides of confidence interval'])
    keyboard
end

end