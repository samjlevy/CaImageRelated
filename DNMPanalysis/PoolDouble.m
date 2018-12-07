function CSpooledDouble = PoolDouble(arr,poolingSets)
%Doesn't work 2d

CSpooledDouble = cellfun(@(x) mean(arr(:,x),2),poolingSets,'UniformOutput',false);

end