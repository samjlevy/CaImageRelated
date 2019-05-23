function [statsOut,eachDayDiffs,dayN] = ComparisonToDayN(dataVec,dayDiffs,dayN)

%Tell it which day to compare to. If nothing there,
%if you have positive and negative, compare to 0. If only one, 
%get the part closest to zero
if isempty(dayN)
    if sum(dataVec>0)>0 && sum(dataVec<0)>0
        dayN=0;
    elseif sum(dataVec<0)==0
        dayN = min(dayDiffs);
    elseif sum(dataVec>0)==0
        dayN = max(dayDiffs);
    end
end

eachDayDiffs = unique(dayDiffs);
eachDayDiffs(eachDayDiffs==dayN) = [];
dayNdata = dataVec(dayDiffs==dayN);
statsOut.signRanks.pVal = NaN(1,length(eachDayDiffs));
statsOut.signRanks.hVal = NaN(1,length(eachDayDiffs));
statsOut.signRanks.zVal = NaN(1,length(eachDayDiffs));
statsOut.rankSums.pVal = NaN(1,length(eachDayDiffs));
statsOut.rankSums.hVal = NaN(1,length(eachDayDiffs));
statsOut.rankSums.zVal = NaN(1,length(eachDayDiffs));
for ddI = 1:length(eachDayDiffs)
     thisData = dataVec(dayDiffs==eachDayDiffs(ddI));
     
     %Sign rank
     if length(dayNdata)==length(thisData)
         [p,h,stats] = signrank(dayNdata,thisData);
         statsOut.signRanks.pVal(ddI) = p;
         statsOut.signRanks.hVal(ddI) = h;
         try statsOut.signRanks.zVal(ddI) = stats.zval; end
     end
     
     %Rank sum
     [p,h,stats] = ranksum(dayNdata,thisData);
     statsOut.rankSums.pVal(ddI) = p;
     statsOut.rankSums.hVal(ddI) = h;
     try statsOut.rankSums.zVal(ddI) = stats.zval; end   
end

end