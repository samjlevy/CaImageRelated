load('trialbytrial.mat')
xmin = 25.5;
xmax = 56;
numBins = 10;
cmperbin = (xmax-xmin)/numBins;
xlims = [xmin xmax];
numSess = length(unique(trialbytrial(1).sessID));
%xlims = [25 60]
%cmperbin = 2.5
minspeed = 0;
zeronans = 1;
posThresh = 3;
lapPctThresh = 0.25;
consecLapThresh = 3;
[dayAllUse, threshAndConsec] = GetUseCells(trialbytrial, lapPctThresh, consecLapThresh);
[Conds] = GetTBTconds(trialbytrial);
[bigCorrs, cells, dayPairs, condPairs ] =...
PVcorrsAllCorrsAllCondsAllDays(TMap_gauss,RunOccMap,posThresh,threshAndConsec,sortedSessionInds,Conds);
[corrMeans, corrStd, corrSEM] = processPVacacad(bigCorrs, cells, dayPairs, condPairs,realDays);
load('PFsLin.mat', 'TMap_gauss')
alwaysAboveThresh = threshAndConsec;
alwaysAboveThresh = ones(size(threshAndConsec));
[bigCorrs, cells, dayPairs, condPairs ] =...
PVcorrsAllCorrsAllCondsAllDays(TMap_gauss,RunOccMap,posThresh,alwaysAboveThresh,sortedSessionInds,Conds);
[corrMeans, corrStd, corrSEM] = processPVacacad(bigCorrs, cells, dayPairs, condPairs,realDays);
load('PFsLin.mat')
alwaysAboveThresh = threshAndConsec;
alwaysAboveThresh = ones(size(threshAndConsec));
[bigCorrs, cells, dayPairs, condPairs ] =...
PVcorrsAllCorrsAllCondsAllDays(TMap_gauss,RunOccMap,posThresh,alwaysAboveThresh,sortedSessionInds,Conds);
[corrMeans, corrStd, corrSEM] = processPVacacad(bigCorrs, cells, dayPairs, condPairs,realDays);
load('realDays.mat')
alwaysAboveThresh = threshAndConsec;
alwaysAboveThresh = ones(size(threshAndConsec));
[bigCorrs, cells, dayPairs, condPairs ] =...
PVcorrsAllCorrsAllCondsAllDays(TMap_gauss,RunOccMap,posThresh,alwaysAboveThresh,sortedSessionInds,Conds);
[corrMeans, corrStd, corrSEM] = processPVacacad(bigCorrs, cells, dayPairs, condPairs,realDays);
meanCurves = cell2mat(cellfun(@(x) mean(x,2)',corrMeans,'UniformOutput',false));
meanCurves(7:8,:) = [];
meanmean(1,:) = mean(meanCurves(1:4,:),1);
meanmean(2,:) = mean(meanCurves([5 8],:),1);
meanmean(3,:) = mean(meanCurves([6 7],:),1);
meanmean = meanmean';
meanmean(1,:) = []
curveID = ones(17,3) .* [1 2 3]
apartlong = repmat([1:17]',3,1)
[h,atab,ctab,stats] = aoctool(apartlong, meanmean(:), curveID(:))
[p, h] = kstest(meanmean(:,1))
[h, p] = kstest(meanmean(:,1))
[h, p] = kstest(meanmean(:,2))
[h, p] = kstest(meanmean(:,3))
aa = zscore(meanmean(:,1)
aa = zscore(meanmean(:,1))
figure; histogram(aa)
figure; histogram(aa,20)
[h, p] = kstest(aa)
aa = zscore(meanmean(:,2))
[h, p] = kstest(aa)
aa = zscore(meanmean(:,3))
[h, p] = kstest(aa)
[h,atab,ctab,stats] = aoctool(apartlong, meanmean(:,[1 2]), curveID(:))
curveID = ones(17,3) .* [1 2 3]; curveID = ones(17,2) .* [1 2]
apartlong = repmat([1:17]',3,1); apartlong = repmat([1:17]',2,1)
[h,atab,ctab,stats] = aoctool(apartlong, meanmean(:,[1 2]), curveID(:))
apartlong
curveID
meanmean(:,[1 2])
[h,atab,ctab,stats] = aoctool(apartlong, meanmean(:,[1 2])(:), curveID(:))
meanmean = meanmean(:,[1 2]);
[h,atab,ctab,stats] = aoctool(apartlong, meanmean(:), curveID(:));
model1b = mean(meanmean(:));
model1b
data = meanmean(:);
data
meanmean
indicator = [ones(17,1),zeros(17,1)];
model2b = mean(meanmean,1)
residuals1 = data-model1b;
residual2 = data-(model2b(1)+(model2b(2)-model2b(1))*indicator);
indicator = [ones(17,1);zeros(17,1)];
residuals2 = data-(model2b(1)+(model2b(2)-model2b(1))*indicator);
histogram(residuals1)
figure();histogram(residuals1)
figure();histogram(residuals2)
indicator1 = [ones(17,1);zeros(17,1)];
indicator2 = [zeros(17,1);ones(17,1)];
residuals2 = data-(indicator1*model2b(1)+indicator2*model2b(2));
figure();histogram(residuals2)
F = ((sum(residuals1.^2) - sum(residuals2.^2)) / (2 - 1)) / (sum(residuals2.^2)/(length(data) - 2 - 1)
F = ((sum(residuals1.^2) - sum(residuals2.^2)) / (2 - 1)) / (sum(residuals2.^2)/(length(data) - 2 - 1))
sum(residuals1.^2)
fcdf(F,1,length(data)-2,'upper')
residuals1 = data-mean(data);
residuals2 = [data(1:17)-(mean(data(1:17)); data(18:34) - mean(data(18:34))]
residuals2 = [data(1:17)-mean(data(1:17)); data(18:34) - mean(data(18:34))]
F = ((sum(residuals1.^2) - sum(residuals2.^2)) / (2 - 1)) / (sum(residuals2.^2)/(length(data) - 2 - 1))
[b,dev,stats] = glmfit(indicator1,data,'normal');
b
dev
stats
var(stats.resid)
residuals2
sum(residuals2.^2)
sum(stats.resid.^2)
[b,dev,stats] = glmfit(ones(34,1),data,'normal','constant','off');
b
sum(stats.resid.^2)
sum(residuals1.^2)
indicator
anova1(data,flipud(indicator+1))
meanmean = meanmean(:,[1 2]);
[h,atab,ctab,stats] = aoctool(apartlong, meanmean(:), curveID(:));
figure; histogram(stats.resid)
[b,dev,stats] = glmfit([ones(34,1),indicator1,apartlong,apartlong*indicator1],'normal','constant','off');
[b,dev,stats] = glmfit([ones(34,1),indicator1,apartlong,apartlong.*indicator1],'normal','constant','off');
[b,dev,stats] = glmfit([ones(34,1),indicator1,apartlong,apartlong.*indicator1],data,'normal','constant','off');
b
stats.resid
sum(stats.resid.^2)
design = [ones(34,1),indicator1,apartlong,apartlong.*indicator1];
plot(design*b)
design*b
figure();plot(design*b)
figure();plot(apartlong,design*b)
figure();plot(apartlong,design*b,'.')
hold on;plot(apartlong,data)
figure();plot(apartlong,design*b,'.')
hold on;plot(apartlong,data,'o')
hold on;plot(apartlong,data,'-o')
sum(stats.resid.^2)
var(stats.resid)
F = ((sum(residuals1.^2) - sum(stats.resid.^2)) / (4 - 1)) / (sum(stats.resid.^2)/(length(data) - 4 - 1))
residuals2 = stats.resid;
[b,dev,stats] = glmfit([ones(34,1),indicator1,apartlong],data,'normal','constant','off');
residuals2 = stats.resid
residuals2 = stats.resid;
[b,dev,stats] = glmfit([ones(34,1),indicator1,apartlong,apartlong.*indicator1],data,'normal','constant','off');
residuals2 = stats.resid;
[b,dev,stats] = glmfit([ones(34,1),indicator1,apartlong],data,'normal','constant','off');
residuals1 = stats.resid;
F = ((sum(residuals1.^2) - sum(residuals2.^2)) / (4 - 3)) / (sum(residuals2.^2)/(length(data) - 4 - 1))
fcdf(F,1,length(data)-4,'upper')
residuals2 = residuals1;
[b,dev,stats] = glmfit([ones(34,1),indicator1],data,'normal','constant','off');
residuals1 = stats.resid;
F = ((sum(residuals1.^2) - sum(residuals2.^2)) / (3 - 2)) / (sum(residuals2.^2)/(length(data) - 3 - 1))
fcdf(F,1,length(data)-3,'upper')
fcdf(97,1,length(data)-3,'upper')
[b,dev,stats] = glmfit([ones(34,1)],data,'normal','constant','off');
b
sum(data.^2)
F = ((3.3755 - sum(stats.resid.^2)) / (1 - 0)) / (sum(stats.resid.^2)/(length(data) - 1 - 1))
fcdf(6.63,1,34-4,'upper')
fcdf(97.83,1,34-3,'upper')
[b,dev,stats] = glmfit([ones(34,1),indicator1],data,'normal','constant','off');
rss2 = var(stats.resid);
rss1 = var(data-mean(data));
F = ((rss1-rss2)/(1))/(rss2/(34-2-1));
F
[b,dev,stats] = glmfit([ones(34,1),apartlong],data,'normal','constant','off');
residuals1 = stats.resid;
[b,dev,stats] = glmfit([ones(34,1),apartlong,indicator1],data,'normal','constant','off');
residuals2 = stats.resid;
F = ((sum(residuals1.^2) - sum(residuals2.^2)) / (3 - 2)) / (sum(residuals2.^2)/(length(data) - 3 - 1))