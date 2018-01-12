SplitterPlot(normRates, 

xmin = 25.5; xmax = 56; xlims = [xmin xmax];
numBins = 8;
[StudyTestProps, LeftRightProps, spikeCounts] = LookAtSplitters(trialbytrial, xlims, numBins);

cellI = 14
dayI = 4


ratesA = TMap_unsmoothed{cellI,1,dayI};
ratesB = TMap_unsmoothed{cellI,3,dayI};
limH = max([ratesA ratesB]) + 0.1;
figure; axes; xlim([-0.5 0.5])
for binI = 1:length(ratesA)
    rectangle('Position',[-ratesA(binI) binI ratesA(binI) 1],'FaceColor','c');
    rectangle('Position',[0 binI ratesB(binI) 1],'FaceColor','m');
end
xlim([-limH limH]
box on
title(['Cell# ' num2str(cellI) ', ' allfiles{dayI}(end-5:end)])
xlabel('STUDY              TEST')

%propsA = LeftRightProps{cellI,dayI}(1,:)
%propsB = LeftRightProps{cellI,dayI}(2,:)


ratesA = TMap_unsmoothed{cellI,1,dayI};
ratesB = TMap_unsmoothed{cellI,2,dayI};
limH = max([ratesA ratesB]) + 0.1;
figure; axes; xlim([-limH limH])
for binI = 1:length(ratesA)
    rectangle('Position',[-ratesA(binI) binI ratesA(binI) 1],'FaceColor','g');
    rectangle('Position',[0 binI ratesB(binI) 1],'FaceColor','r');
end
xlim([-limH limH])
box on
title(['Cell# ' num2str(cellI) ', ' allfiles{dayI}(end-5:end)])
xlabel('LEFT              RIGHT')