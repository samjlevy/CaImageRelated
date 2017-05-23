function [SharedRunning]=GoodOccMapMulti( thresh, varargin ) 
%Thresh is minimum number of samples shared
%Inputs to varargin are RunOccMaps
%Shared funning is linear indices
nOccMaps = length(varargin);
if nOccMaps < 2
    disp('can not do this, need more than one condition to compare')
end

if ~exist('thresh','var')
    thresh=1;
end

newVargin = cell(size(varargin));
eachGoodPix = cell(size(varargin));
for thisOcc = 1:nOccMaps
    newVargin{thisOcc} = varargin{thisOcc} > thresh;
    eachGoodPix{thisOcc} = find(newVargin{thisOcc});
end

SharedRunning = eachGoodPix{1};
for thisPix = 2:nOccMaps
    SharedRunning = SharedRunning(ismember(SharedRunning,eachGoodPix{thisPix}));
end



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