
thisDir = cd;
tdpts = strsplit(thisDir,'\');
upALevel = fullfile(tdpts{1:end-1});

load('mattest.mat')
stdThresh = 2.5; %Num std above mean to get calcium transients at
durThresh = 3; %Minimum number of frames to call it a transient
[PSAbool] = DeconvolutionRough1(C,stdThresh,durThresh);
[cellROIs] = CaimanToMatCellROIs1(A,imSize);
save('FinalOutput.mat','PSAbool','cellROIs','imSize')

load('Pos_brain.mat','PSAboolUseIndices')

PSAboolAdjusted = PSAbool(:,PSAboolUseIndices);

save('Pos_brain.mat','PSAboolAdjusted','-append')

cd(upALevel)

load('daybyday.mat','daybyday')
daybyday.PSAbool{1} = PSAboolAdjusted;
save('daybyday.mat','daybyday','-append')

[~, ~, ~, ~]= MakeTBTalternation(cd,false,true);
