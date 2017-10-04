
%(base_path)

%cd(base_path)
load('trialbytrial.mat')
%{
for aa = [1 3 4]
MinX(aa) = mean(cell2mat(cellfun(@min,trialbytrial(aa).trialsX,'UniformOutput',false)));
minStd(aa) = std(cellfun(@min,trialbytrial(aa).trialsX));
MaxX(aa) = mean(cellfun(@max,trialbytrial(aa).trialsX));
maxStd(aa) = std(cellfun(@max,trialbytrial(aa).trialsX));
end
MinX - minStd
MaxX + maxStd
%}
xmin = 25.5;
xmax = 56;
numBins = 10;
cmperbin = (xmax-xmin)/numBins;
xlims = [xmin xmax];

numShuffles = 100;
%xlims = [25 60]
%cmperbin = 2.5
minspeed = 0;
zeronans = 1;

%Make original
%[~, RunOccMap, ~, ~, ~, TMap_gauss] =...
%    PFsLinTrialbyTrial(trialbytrial,xlims, cmperbin, minspeed, 0, []);   
[~, RunOccMap, ~, ~, ~, TMap_gauss] =...
PFsLinTrialbyTrialCONDpool(trialbytrial,xlims, cmperbin, minspeed, 0, []);

[TMap_zscore{1}] = ZScoreLinPFs(TMGforShuff{shuffI}, zeronans);   

%PV corrs for original

%Get some shuffled distributions
for shuffI = 1:numShuffles
    shuffledTBT = ShuffleTrialsAcrossDays(trialbytrial);
    
    %[~, ROMforShuff{shuffI}, ~, ~, ~, TMGforShuff{shuffI}] =...
    %PFsLinTrialbyTrial(trialbytrial,xlims, cmperbin, minspeed, 0, []);
    [~, ROMforShuff{shuffI}, ~, ~, ~, TMGforShuff{shuffI}] =...
    PFsLinTrialbyTrialCONDpool(trialbytrial,xlims, cmperbin, minspeed, 0, []);
    [TMap_zscore{1}] = ZScoreLinPFs(TMGforShuff{shuffI}, zeronans);
end

%PV corrs for shuffle

%Statistical comparison