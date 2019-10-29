function [PSAbool] = DeconvolutionRough1(C,stdThresh,durThresh)
%C is the output matrix from Caiman
%Super basic deconvolution.Calls a transient the rising phase of any spike
%in calcium activity that gets more than some threshold of std devs above
%baseline level of activity

if isempty(stdThresh)
    stdThresh = 2.5;
    disp(['using default stdThresh ' num2str(stdThresh)])
end
if isempty(durThresh)
    durThresh = 3;
    disp(['using default durThresh ' num2str(durThresh)])
end
framesDownSkip = 1;

numFrames = size(C,2);
numCells = size(C,1);

frameI = 1:numFrames;
PSAbool = false(numCells,numFrames);
for cellI = 1:numCells

    actH = C(cellI,:);
    %figure; plot(actH); hold on
    fluorDiff = diff(actH);
    isRising = fluorDiff>=0;
    isRising = [0 isRising];
    isRising = logical(isRising);
    
    %plotRise = actH; plotRise(isRising==0)=0;
    %plot(plotRise,'r')
    
    largeA = actH > mean(actH)+std(actH)*stdThresh;
    laOnsets = find(diff([0 largeA])==1);
    laOffsets = find(diff([largeA 0])==-1)+1;
 
    onsets = find(diff([0 isRising])==1);
    offsets = find(diff([isRising 0])==-1);
    
    %Refinement for small dips
    %{
    offs = [offsets(1:end-1)];
    ons = [onsets(2:end)];
    
    diffsHere = ons-offs;
    killDiffs = diffsHere==(framesDownSkip+1);
    offs(killDiffs) = [];
    ons(killDiffs) = [];
    
    onsets = [onsets1 ons];
    offsets = [offs offsets(end)]; 
    %}
    
    onOff = [onsets', offsets'];
    onDurs = diff(onOff,1,2)+1;
    onOffThresh = onOff(onDurs>=durThresh,:);

    PSAbTemp = false(1,numFrames);
    for durI = 1:size(onOffThresh,1)
        thisEpoch = onOffThresh(durI,1):onOffThresh(durI,2);
        hasTrans = any(largeA(thisEpoch));
        if hasTrans
            PSAbTemp(thisEpoch) = true;
        end
    end
    PSAbool(cellI,:) = PSAbTemp;
    
    %plotPSA = actH; plotPSA(PSAbTemp==0)=0;
    %plot(plotPSA,'g')
end

end
%{


onOffLogical = false(1,numFrames);
onOffLogical(onOffThresh(:,1):onOffThresh(:,2)-1) = true;

%Get epochs where on off durations include large a
risingAndLarge = onOffLogical & ;

rlAct = actH.*PSAbTemp;
figure; plot(actH)
hold on
rlAct = actH.*PSAbTemp;
plot(rlAct,'r')
plot([1 numFrames],[1 1]*mean(actH)+std(actH)*tThresh)

dt = 5;
for ti = dt:numFrames
    indHere = ti-(dt-1):ti-1;
    df = mean(fluorDiff(indHere));
    dfdt(ti) = df/dt;
end
%}
%{
%doesn't really work, was going to use this for validation, but loads way
too slowly
tifHere = 'cropped_recording_m19oneTiff.tif';
tiff_info = imfinfo(tifHere); % return tiff structure, one element per image
tiff_stack = imread(tifHere, 1) ; % read in first image
for ii = 2 : size(tiff_info, 1)
    temp_tiff = imread(tifHere, ii);
    tiff_stack = cat(3 , tiff_stack, temp_tiff);
end
%}