function [slope, intercept, fitLine, rr, pSlope, pInt] = fitLinRegSL(yData, xData)

yData = yData(:);
%numDays = length(data);

if isempty(xData)
    xData = (1:length(yData))';
end
xData = xData(:);

%model = [ones(numDays,1) [1:numDays]'.*data];
%[b,~,r,~,stats] = regress(data, model);

lm = fitlm(table(xData(:),yData(:)),'linear');

%slope = b(2);
%intercept = b(1);

intercept = lm.Coefficients.Estimate(1);
slope = lm.Coefficients.Estimate(2);
rr = lm.Rsquared;

pInt = lm.Coefficients.pValue(1);
pSlope = lm.Coefficients.pValue(2);

fitLine = [xData(:), xData(:)*slope+intercept];
end