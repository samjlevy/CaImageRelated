function [indsAligned] = ValidateEachPosAlignment(lapX,lapY,eachX,eachY,distThresh)

 xDiffs = eachX(:)-lapX(:)';
 yDiffs = eachY(:)-lapY(:)';
 
 distDiffs = hypot(xDiffs,yDiffs);
 [dd,dInd] = min(distDiffs,[],2);
 
 if sum(dd~=0)>0
     keyboard
 end
 
 dInd(dd~=0) = [];
 if length(dInd) == length(unique(dInd)) % Each pos has a unique lowest distance
     indOrder = diff(dInd);
     if sum(indOrder>0)==length(indOrder) % Order of these alignments is in order
        % This lap is good
        indsAligned = dInd;
     end
 else
     keyboard
     ll(condJJ).tbtAllInds{lapIndsEach(lapI),1} = AssignDistMatches(distDiffs,distThresh);
end

end