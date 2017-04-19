function [SharedRunning]=GoodOccMapShared( RunOccMapA, RunOccMapB, thresh ) 
%Thresh is minimum number of samples shared
%Shared funning is linear indices

if ~exist('thresh','var')
    thresh=1;
end

AaboveThresh = RunOccMapA > thresh;
BaboveThresh = RunOccMapB > thresh;

AthreshPixels = find(AaboveThresh);
BthreshPixels = find(BaboveThresh);

SharedRunning = AthreshPixels(ismember(AthreshPixels,BthreshPixels));

%{
%demo fig
figure;
subplot(1,3,1)
imagesc(AaboveThresh); title('RunOccMapA')
subplot(1,3,2)
imagesc(BaboveThresh); title('RunOccMapB')
subplot(1,3,3)
sharedMap=RunOccMapA; sharedMap(:)=0; sharedMap(SharedRunning)=1;
imagesc(sharedMap); title('Shared Above Thresh Pixels')
%}

end