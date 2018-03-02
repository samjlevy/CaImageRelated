function [xMax, xMin] = GetTBTlims(trialbytrial)

for condI = 1:length(trialbytrial)
    xMax(condI) = max([trialbytrial(condI).trialsX{:}]);
    xMin(condI) = min([trialbytrial(condI).trialsX{:}]);
end

end