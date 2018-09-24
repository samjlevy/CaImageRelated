slopDiffFromZeroFtest(dataVec,days)

[slope, intercept, ~, ~] = fitLinRegSL(dataVec, days);

interceptZero = sum(dataVec - 0*days) / length(dataVec);

errorZero = dataVec - 0*days - interceptZero*ones(size(dataVec,1),size(dataVec,2));
errorSlope = dataVec - slope*days - intercept*ones(size(dataVec,1),size(dataVec,2));

RsquaredZero = sum(errorZero.^2);
RsquaredSlope = sum(errorSlope.^2);


%F = ((rss1 - rss2)/(p2 - p1)) / (rss2/(n - p2))
nPts = length(allData);
rss1 = rsquaredAsame + rsquaredBsame;
rss2 = rsquaredA + rsquaredB;

Fval = ((rss1 - rss2)/(3 - 2)) / (rss2/(nPts - 3));

dfNum = 2 - 1; %Num groups  - 1
dfDen = nPts - 2; %Num data pts. - num groups

pVal = fcdf(Fval,dfNum,dfDen,'upper');