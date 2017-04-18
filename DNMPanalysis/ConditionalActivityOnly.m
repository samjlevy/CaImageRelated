function [CondActOnly] = ConditionalActivityOnly(activityMat, condLogical)

CondActOnly = zeros(size(activityMat));
for row = 1:size(activityMat,1)
    CondActOnly(row,:) = activityMat(row,:) & condLogical;
end

end