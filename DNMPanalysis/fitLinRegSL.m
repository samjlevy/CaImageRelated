function [slope, intercept, fitLine, rr, pSlope, pInt] = fitLinRegSL(data, realDays)

data = data(:);
%numDays = length(data);

if isempty(realDays)
    realDays = (1:length(data))';
end

%model = [ones(numDays,1) [1:numDays]'.*data];
%[b,~,r,~,stats] = regress(data, model);

lm = fitlm(table(realDays(:),data(:)),'linear');

%slope = b(2);
%intercept = b(1);

intercept = lm.Coefficients.Estimate(1);
slope = lm.Coefficients.Estimate(2);
rr = lm.Rsquared;

fitLine = [realDays'; realDays'*slope+intercept]';

%Get pvals for slope and intercept
end