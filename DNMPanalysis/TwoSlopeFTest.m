function [Fval,dfNum,dfDen,pVal] = TwoSlopeFTest(dataVecA, dataVecB, days)

%Step 1: Get the slope of all the data together (not 100% sure this is right...
allData = [dataVecA; dataVecB];
allDays = [days; days];
[allSlope, allIntercept, ~, ~] = fitLinRegSL(allData,allDays);

%Step 2: Fit linear regression to each data starting with known slope
interceptAsame = sum(dataVecA - allSlope*days) / length(dataVecA);
interceptBsame = sum(dataVecB - allSlope*days) / length(dataVecB);

%dataI = slope*dayI + intercept + errorI
%errorI = dataI - slope*dayI - intercept
errorAsame = dataVecA - allSlope*days - interceptAsame*ones(size(dataVecA,1),size(dataVecA,2));
errorBsame = dataVecB - allSlope*days - interceptBsame*ones(size(dataVecB,1),size(dataVecB,2));

rsquaredAsame = sum(errorAsame.^2);
rsquaredBsame = sum(errorBsame.^2);

%Step 3: Fit lear regresstion to each data intependently
[slopeA, interceptA, ~, ~] = fitLinRegSL(dataVecA, days);
[slopeB, interceptB, ~, ~] = fitLinRegSL(dataVecB, days);

errorA = dataVecA - slopeA*days - interceptA*ones(size(dataVecA,1),size(dataVecA,2));
errorB = dataVecB - slopeB*days - interceptB*ones(size(dataVecB,1),size(dataVecB,2));



rsquaredA = sum(errorA.^2);
rsquaredB = sum(errorB.^2);

%Step 4: run the F test comparing explained variance in independent slopes
%vs. same slope

%F = ((rss1 - rss2)/(p2 - p1)) / (rss2/(n - p2))
nPts = length(allData);
rss1 = rsquaredAsame + rsquaredBsame;
rss2 = rsquaredA + rsquaredB;

Fval = ((rss1 - rss2)/(4 - 3)) / (rss2/(nPts - 4));

dfNum = 2 - 1; %Num groups  - 1
dfDen = nPts - 2; %Num data pts. - num groups

pVal = fcdf(Fval,dfNum,dfDen,'upper');

if kstest(zscore(dataVecA))==1
    disp('Error: found that dataA not normally distributed') 
end
if kstest(zscore(dataVecB)) ==1
    disp('Error: found that dataB not normally distributed') 
end
if kstest(zscore(errorA)) ==1
    disp('Error: found that residuals A not normally distributed') 
end
if kstest(zscore(errorB)) ==1
    disp('Error: found that residuals B not normally distributed') 
end
for permI = 1:1000
    [shCorr(permI),~] = corr(errorA(randperm(length(errorA))),errorB(randperm(length(errorB))),'Type','Spearman');
end
[eCorr,~] = corr(errorA,errorB,'Type','Spearman');
if sum(eCorr > shCorr) > 950
    disp('Error: found that residuals A and B are correlated')
end


end
