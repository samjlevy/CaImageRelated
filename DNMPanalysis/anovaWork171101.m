%% Basic stuff
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
load('PFsLin.mat')
load('realDays.mat')
alwaysAboveThresh = threshAndConsec;
alwaysAboveThresh = ones(size(threshAndConsec));
[bigCorrs, cells, dayPairs, condPairs ] =...
PVcorrsAllCorrsAllCondsAllDays(TMap_gauss,RunOccMap,posThresh,alwaysAboveThresh,sortedSessionInds,Conds);
[corrMeans, corrStd, corrSEM] = processPVacacad(bigCorrs, cells, dayPairs, condPairs,realDays);

%% Need to also do this for split sessions

%% Setting up
%{
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
%}

meanCurves = cell2mat(cellfun(@(x) mean(x,2)',corrMeans,'UniformOutput',false));
%1:4 is self, 5:6 is svt, 7:8 is lvr
curvesUse = [1:4 6 9 5 10];
meanCurves = meanCurves(curvesUse,:)';
meanCurves = meanCurves(2:14,:);
meanCurvesOld = meanCurves; 
meanCurves = [];
meanCurves = [nanmean(meanCurvesOld(:,1:4),2) nanmean(meanCurvesOld(:,5:6),2) nanmean(meanCurvesOld(:,7:8),2)];
%Where is the nan coming in in col 4?

%Normally distributed
for mcI = 1:size(meanCurves,2)
    [h(mcI),p(mcI)] = kstest(zscore(meanCurves(:,mcI)));
end

pairsCheck = combnk(1:8,2);
daysApart = repmat(1:size(meanCurves,1),1,2)';
group = [zeros(size(meanCurves,1),1); ones(size(meanCurves,1),1)] +1;
h = []; atab = []; ctab = []; stats = [];
for pcI = 1:size(pairsCheck,1)
    data = [meanCurves(:,pairsCheck(pcI,1)); meanCurves(:,pairsCheck(pcI,2))];
    %[p{pcI},tbl{pcI},stats{pcI}] = anovan(data,{group, daysApart});
    [h{pcI},atab{pcI},ctab{pcI},stats{pcI}] = aoctool(daysApart, data, group,[], [], [], [],'off');
end

compID = [1 1 1 1 2 2 3 3];
compPairs = compID(pairsCheck);
types = 1:3
ughhh = repmat(1:3,3,1);
pairPerms = [repmat(1:3,1,3)' ughhh(:)];

compType = nan(size(pairsCheck,1),1);
for cpJ = 1:size(pairsCheck,1)
    for aa = 1:size(pairPerms)
    if compPairs(cpJ,1)==pairPerms(aa,1) && compPairs(cpJ,2)==pairPerms(aa,2)
        compType(cpJ) = aa;
    end
    end
end


if compPairs(pcJ,1)==1 && compPairs(pcJ,2)==1

elseif compPairs(pcJ,1)==1 && compPairs(pcJ,2)==2
    elseif compPairs(pcJ,1)==1 && compPairs(pcJ,2)==3
        
elseif compPairs(pcJ,1)==2 && compPairs(pcJ,2)==1
    
elseif compPairs(pcJ,1)==1 && compPairs(pcJ,2)==2
    

groupEffect = cellfun(@(x) x{2,6},atab);
dayEffect = cellfun(@(x) x{3,6},atab);
interaction = cellfun(@(x) x{4,6},atab);

%% Prove these are normally distributed
[h, p] = kstest(zscore(meanmean(:,1)))
[h, p] = kstest(zscore(meanmean(:,2)))
[h, p] = kstest(zscore(meanmean(:,3)))

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