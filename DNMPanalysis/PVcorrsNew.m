%This is set up to only include cells in each comparison that fired in at
%least one of the compared conditions. Should limit the number of cells
%that end up included but have 0 firing rate 
%Right now all place maps are end to start, first to last bins
maxBins = 14;
posThresh = 3;
numDays = size(TMap_gauss,3);
StudyCorrs = nan(numDays,maxBins); TestCorrs = nan(numDays,maxBins);
LeftCorrs = nan(numDays,maxBins); RightCorrs = nan(numDays,maxBins);
for tDay = 1:numDays
    %{
    cellsInclude = dayUse(:,tDay)>0;
    PFsA = cell2mat(TMap_gauss(cellsInclude,1,tDay)); PFsA(isnan(PFsA)) = 0;
    PFsB = cell2mat(TMap_gauss(cellsInclude,2,tDay)); PFsB(isnan(PFsB)) = 0;
    PFsC = cell2mat(TMap_gauss(cellsInclude,3,tDay)); PFsC(isnan(PFsC)) = 0;
    PFsD = cell2mat(TMap_gauss(cellsInclude,4,tDay)); PFsD(isnan(PFsD)) = 0;
    numCells = sum(cellsInclude);
    %}
    useCells = dayUse(:,tDay)>0;
    
    for ct = 1:4
        binsUse(ct,:) = RunOccMap{1,ct,tDay} > posThresh;
    end

    for binNum = 1:maxBins
        %Study
        if sum(binsUse(Conds.Study,binNum)) == 2
            conds = Conds.Study;
            useCells = sum(threshAndConsec(:,tDay,conds),3)>0;
            studyCells(tDay) = sum(useCells);
            PFsA = cell2mat(TMap_gauss(useCells,conds(1),tDay)); PFsA(isnan(PFsA)) = 0;
            PFsB = cell2mat(TMap_gauss(useCells,conds(2),tDay)); PFsB(isnan(PFsB)) = 0;
            StudyCorrs(tDay,binNum) = corr(PFsA(:,binNum),PFsB(:,binNum));
        end
        %Test
        if sum(binsUse(Conds.Test,binNum)) == 2
            conds = Conds.Test;
            useCells = sum(threshAndConsec(:,tDay,conds),3)>0;
            testCells(tDay) = sum(useCells);
            PFsC = cell2mat(TMap_gauss(useCells,conds(1),tDay)); PFsC(isnan(PFsC)) = 0;
            PFsD = cell2mat(TMap_gauss(useCells,conds(2),tDay)); PFsD(isnan(PFsD)) = 0;
            TestCorrs(tDay,binNum) = corr(PFsC(:,binNum),PFsD(:,binNum));
        end
        %Left
        if sum(binsUse(Conds.Left,binNum)) == 2
            conds = Conds.Left;
            useCells = sum(threshAndConsec(:,tDay,conds),3)>0;
            leftCells(tDay) = sum(useCells);
            PFsA = cell2mat(TMap_gauss(useCells,conds(1),tDay)); PFsA(isnan(PFsA)) = 0;
            PFsC = cell2mat(TMap_gauss(useCells,conds(2),tDay)); PFsC(isnan(PFsC)) = 0;
            LeftCorrs(tDay,binNum) = corr(PFsA(:,binNum),PFsC(:,binNum));
        end
        %Right
        if sum(binsUse(Conds.Right,binNum)) == 2
            conds = Conds.Right;
            useCells = sum(threshAndConsec(:,tDay,conds),3)>0;
            rightCells(tDay) = sum(useCells);
            PFsB = cell2mat(TMap_gauss(useCells,conds(1),tDay)); PFsB(isnan(PFsB)) = 0;
            PFsD = cell2mat(TMap_gauss(useCells,conds(2),tDay)); PFsD(isnan(PFsD)) = 0;
            RightCorrs(tDay,binNum) = corr(PFsB(:,binNum),PFsD(:,binNum));
        end 
    end
end

jetTrips = colormap(jet);
jetUse = round(linspace(64,1,numDays));
plotColors = jetTrips(jetUse,:);

StudyFig = figure; TestFig = figure; LeftFig = figure; RightFig = figure;
axes(StudyFig); hold(StudyFig.Children,'on'); title(StudyFig.Children,'Study Left vs Right')
axes(TestFig); hold(TestFig.Children,'on'); title(TestFig.Children,'Test Left vs Right')
axes(LeftFig); hold(LeftFig.Children,'on'); title(LeftFig.Children,'Left Study vs Test')
axes(RightFig); hold(RightFig.Children,'on'); title(RightFig.Children,'Right Study vs Test')
xlabel(StudyFig.Children,'Choice Point                      Start')
xlabel(TestFig.Children,'Choice Point                      Start')
xlabel(LeftFig.Children,'Choice Point                      Start')
xlabel(RightFig.Children,'Choice Point                      Start')
for uDay = 1:numDays
    plot(StudyFig.Children,StudyCorrs(uDay,:),'-o','Color',plotColors(uDay,:))
    plot(TestFig.Children,TestCorrs(uDay,:),'-o','Color',plotColors(uDay,:))
    plot(LeftFig.Children,LeftCorrs(uDay,:),'-o','Color',plotColors(uDay,:))
    plot(RightFig.Children,RightCorrs(uDay,:),'-o','Color',plotColors(uDay,:))
end
ylim(StudyFig.Children,[-0.95 1])
ylim(TestFig.Children,[-0.95 1])
ylim(LeftFig.Children,[-0.5 1])
ylim(RightFig.Children,[-0.5 1])


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