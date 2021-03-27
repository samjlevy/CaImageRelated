function [dayAllUse, threshAndConsec, consec] = GetUseCells(trialbytrial, lapPctThresh, consecLapThresh, poolConds,xBinLims,yBinLims)

%lapPctThresh = 0.25
%consecLapThresh = 3;

[trialReli,aboveThresh,~,~] = TrialReliability(trialbytrial, lapPctThresh, poolConds,xBinLims,yBinLims);%sortedReliability

[consec, enoughConsec] = ConsecutiveLaps(trialbytrial, consecLapThresh);%maxConsec

%newUse = cell2mat(cellfun(@(x) sum(x,2) > 0,aboveThresh,'UniformOutput',false));
%newUse2 = cell2mat(cellfun(@(x) sum(x,2) > 0,enoughConsec,'UniformOutput',false));

for condT = 1:length(trialbytrial)
reorgThresh(:,:,condT) = aboveThresh{condT};
reorgConsec(:,:,condT) = enoughConsec{condT};
end
threshAndConsec = reorgThresh | reorgConsec;

%dayUse = sum(reorgThresh,3);
%dayUse2 = sum(reorgConsec,3);

%dayAllUse = dayUse + dayUse2;
dayAllUse = logical(sum(threshAndConsec,3));

end