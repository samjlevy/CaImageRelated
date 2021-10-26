% reinstatement examples

mouseI = 2;cellsTry = ; % get these from rCells as options
22
90
106
119
140
321
418
dpI = 10;

mouseI = 5
dpI = 24


dpI = 23
105
253

mouseI = 6
dpI = 24
cellI = 128

dpI = 2
15
127
321
502

dpI = 5
cellI = 298 % good but something weird in the plotting; it's because we get the dot plot pts separately for each cond
445

load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'),'trialbytrialAll')

%run lines 667 - 681   watch out for the if
%run lines 716 - 722

% reinstatement
ff = rhoDiffsAll > 0 & sum(trialReliAll{mouseI}(sum(cellsUseHere,2)>0,daysH)>0.1,2)==3;
% not
ff = rhoDiffsAll < 0 & sum(trialReliAll{mouseI}(sum(cellsUseHere,2)>0,daysH)>0.05,2)==3;
gg = [rhoDiffsAll < 0, sum(trialReliAll{mouseI}(sum(cellsUseHere,2)>0,daysH)>0.05,2)==3];
cc = find(sum(cellsUseHere,2)>0);
rCells = cc(ff)

rhosHH = singleCellAllCorrsRhoAB{mouseI}{1}{dpI} > 0 & singleCellAllCorrsRhoCD{mouseI}{1}{dpI} < 0;
rCells = find(rhosHH & sum(trialReliAll{mouseI}(:,daysH)>0.05,2)==3);
cellI = 

for ii = 1:3
    dayI = daysH(ii);
    PlotDotplotDoublePlus2(trialbytrialAll,cellI,[1 2],dayI,'dynamic',[],5)%
    title(['Mouse ' num2str(mouseI) ' cell ' num2str(cellI) ' day ' num2str(dayI)])
    xlim([-70 70])
    ylim([-70 70])
    box off
    axis off
end
singleCellAllCorrsRhoAB{mouseI}{1}{dpI}(cellI)
singleCellAllCorrsRhoCD{mouseI}{1}{dpI}(cellI)
disp(['Corrs here: Turn1 vs Turn 2: rho= '  ' p= '


