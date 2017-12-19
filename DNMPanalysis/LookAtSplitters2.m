function [rates, normrates, rateDiff] = LookAtSplitters2(TMap_unsmoothed)
%includes a basic splitting which is sum of differences in firing rates,
%and normalized across the number of bins where there was activity in at
%least one of the conditions

numSess = size(TMap_unsmoothed,3);
numConds = size(TMap_unsmoothed,2);
numCells = size(TMap_unsmoothed,1);
numBins = length(TMap_unsmoothed{1,1,1});

for sessI = 1:numSess
    for cellI = 1:numCells
        SLrates = TMap_unsmoothed{cellI,1,sessI};
        SRrates = TMap_unsmoothed{cellI,2,sessI};
        TLrates = TMap_unsmoothed{cellI,3,sessI};
        TRrates = TMap_unsmoothed{cellI,4,sessI};
        
 
        StudyLvR = SRrates-SLrates;
        rateDiff.StudyLvR{cellI,sessI} = StudyLvR;
        splitStudyLvR(cellI,sessI) = sum(StudyLvR);
            %Somehow need to adjust this for total amount of firing
        baStudyLvR = SRrates~=0 | SLrates~=0;
        normStudyLvR(cellI,sessI) = splitStudyLvR(cellI,sessI)/sum(baStudyLvR);
        
        TestLvR = TRrates-TLrates;
        rateDiff.TestLvR{cellI,sessI} = TestLvR;
        splitTestLvR(cellI,sessI) = sum(TestLvR);
        baTestLvR = TRrates~=0 | TLrates~=0;
        normTestLvR(cellI,sessI) = splitTestLvR(cellI,sessI)/sum(baTestLvR);
        
        LeftSvT = TLrates-SLrates; 
        rateDiff.LeftSvT{cellI,sessI} = LeftSvT;
        splitLeftSvT(cellI,sessI) = sum(LeftSvT);
        baLeftSvT = TLrates~=0 | SLrates~=0;
        normLeftSvT(cellI,sessI) = splitLeftSvT(cellI,sessI)/sum(baLeftSvT);
        
        RightSvT = TRrates-SRrates;
        rateDiff.RightSvT{cellI,sessI} = RightSvT;
        splitRightSvT(cellI,sessI) = sum(RightSvT);
        baRightSvT = TRrates~=0 | TLrates~=0;
        normRightSvT(cellI,sessI) = splitRightSvT(cellI,sessI)/sum(baRightSvT);
    end
end

rates.StudyLvR = splitStudyLvR;
rates.TestLvR = splitTestLvR;
rates.LeftSvT = splitLeftSvT;
rates.RightSvT = splitRightSvT;

normrates.StudyLvR = normStudyLvR;
normrates.TestLvR = normTestLvR;
normrates.LeftSvT = normLeftSvT;
normrates.RightSvT = normRightSvT;

end
       
       %{
            %Doesn't really work, ends up with Infs a lot
            StudyLvR = SLrates./SRrates; StudyLvR(isnan(StudyLvR))=1;
            StudyLvR(cellI,sessI) = sum(log(StudyLvR));
            
            TestLvR = TLrates./TRrates; TestLvR(isnan(TestLvR))=1;
            TestLvR(cellI,sessI) = sum(log(TestLvR));
            
            LeftSvT = SLrates./TLrates; LeftSvT(isnan(LeftSvT))=1;
            LeftSvT(cellI,sessI) = sum(log(LeftSvT));
            
            RightSvT = SRrates./TRrates; RightSvT(isnan(RightSvT))=1;
            RightSvT(cellI,sessI) = sum(log(RightSvT));
        %}
            