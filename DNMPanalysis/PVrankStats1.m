function PVrankStats1(base_path, numShuffles)

load(fullfile(base_path,'trialbytrial.mat'))

[trialReli,aboveThresh] = TrialReliability(trialbytrial, 0.25);%sortedReliability
[consec, enoughConsec] = ConsecutiveLaps(trialbytrial,3);%maxConsec

newUse = cell2mat(cellfun(@(x) sum(x,2) > 0,aboveThresh,'UniformOutput',false));
newUse2 = cell2mat(cellfun(@(x) sum(x,2) > 0,enoughConsec,'UniformOutput',false));

for condT = 1:4
reorgThresh(:,:,condT) = aboveThresh{condT};
reorgConsec(:,:,condT) = enoughConsec{condT};
end
threshAndConsec = reorgThresh | reorgConsec;

dayUse = sum(reorgThresh,3);
dayUse2 = sum(reorgConsec,3);

dayAllUse = dayUse + dayUse2;

threshPerDay = sum(dayUse>0,1);
consecPerDay = sum(dayUse2>0,1); 

threshUse = sum(dayUse,2)>0;
consecUse = sum(dayUse2,2)>0;

useCells = find(threshUse+consecUse > 0);

[Conds] = GetTBTconds(trialbytrial);

useBins = 12;
maxBins = 14;
posThresh = 3;
numDays = size(TMap_gauss,3);


%Get the curves
[StudyTestCorrs, LeftRightCorrs] = GetCurves(base_path,dayUse,posThresh,maxBins, numDays);

%Do it once to get Actual
[stRsq, lrRsq] = CurvesRsquared(LeftRightCorrs, StudyTestCorrs, useBins, numDays);

%Shuffle things to get distribution
stRshuff = nan(numShuffles,1); lrRshuff = nan(numShuffles,1);
for ss = 1:numShuffles
    [stRshuff(ss), lrRshuff(ss)] = ShuffledRsquared(LeftRightCorrs, StudyTestCorrs, useBins, numDays);
end

pvalLR = sum(lrRsw>stRshuff);
pvalST = sum(stRsq>stRshuff);


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [StudyTestCorrs, LeftRightCorrs] = GetCurves(base_path,dayUse,posThresh,maxBins, numDays)
load(fullfile(base_path,'PFsLinPOOLED.mat'),'TMap_gauss','RunOccMap')
StudyTestCorrs = nan(numDays,maxBins); 
LeftRightCorrs = nan(numDays,maxBins);
for tDay = 1:numDays
    useCells = dayUse(:,tDay)>0;
    
    for ct = 1:4
        binsUse(ct,:) = RunOccMap{1,ct,tDay} > posThresh;
    end

    for binNum = 1:maxBins
        %StudyTest
        if sum(binsUse([1 2],binNum)) == 2
            PFsA = cell2mat(TMap_gauss(useCells,1,tDay)); PFsA(isnan(PFsA)) = 0;
            PFsB = cell2mat(TMap_gauss(useCells,2,tDay)); PFsB(isnan(PFsB)) = 0;
            StudyTestCorrs(tDay,binNum) = corr(PFsA(:,binNum),PFsB(:,binNum));
        end
        %LeftRight
        if sum(binsUse([3 4],binNum)) == 2
            PFsA = cell2mat(TMap_gauss(useCells,3,tDay)); PFsA(isnan(PFsA)) = 0;
            PFsB = cell2mat(TMap_gauss(useCells,4,tDay)); PFsB(isnan(PFsB)) = 0;
            LeftRightCorrs(tDay,binNum) = corr(PFsA(:,binNum),PFsB(:,binNum));
        end
    end
end

end

function [stRsq, lrRsq] = CurvesRsquared(LeftRightCorrs, StudyTestCorrs, useBins, numDays)

for bb = 1:useBins
    [~,LRorder(:,bb)] = sort(LeftRightCorrs(:,bb));
    [~,STorder(:,bb)] = sort(StudyTestCorrs(:,bb));
end
LRorder = LRorder'; STorder=STorder';

LRrankMean = mean(LRorder,1);
STrankMean = mean(STorder,1);

[~, ~, lrRsq] = LeastSquaresRegressionSL(1:numDays, LRrankMean, 0);
[~, ~, stRsq] = LeastSquaresRegressionSL(1:numDays, STrankMean, 0);
end

function [sameRank, randRanks] = ShuffledRsquared( useBins, numDays)

sameOrder = randperm(numDays);

sameranks = repmat(sameOrder',1,useBins);

for binI = 1:useBins
    diffranks(:,binI) = randperm(numDays)';
end

rankmeans = mean(sameranks,1);
[~, ~, sameRank] = LeastSquaresRegressionSL(1:numDays, rankmeans, 0);
rankmeans = mean(diffranks,1);
[~, ~, randRanks] = LeastSquaresRegressionSL(1:numDays, rankmeans, 0);

end