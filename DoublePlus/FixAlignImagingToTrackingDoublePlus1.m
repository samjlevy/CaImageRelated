function FixAlignImagingToTrackingDoublePlus1(sessionFolder,sessionType,mazeBoundaries,nBoundRegions,frameBuffer)

% This function is to re-align all the sessions previously aligned using
% Sam's old method that might be wrong and doesn't account for CinePlex vs
% nVista drift
% It's super long because we're trying to take as much of the pre-existing
% behavior-parsed data and reuse that

positionDataFile = 'posAnchored.mat';
DVTfile = ls(fullfile(sessionFolder,'*.DVT'));
xmlFile = ls(fullfile(sessionFolder,'*.xml'));
plusBehaviorFile = 'plusMazeBehavior.mat'; % made with ParsePlusMazeBehavior3(posAnchoredFile); on pre-braintime positions

% Do all our behavior adjusting
load(fullfile(sessionFolder,positionDataFile),'x_adj_cm','y_adj_cm','DVTtime');

load(fullfile(sessionFolder,plusBehaviorFile),'trialSeqs','trialBounds','trialSeqEpochs')
% Filter for doubles in the sequence < 10 frames apart
[trialSeqs, trialSeqEpochs] = DoubleSeqFilter(trialSeqs,trialSeqEpochs,10);

%armLabels = {'north','east','south','west'}; % This is the sequence used in ParsePlusMazeBehavior3
armLabelsN = 'mnesw'; % This is the indexed version of what comes out
trialSeqLabels = cellfun(@(x) armLabelsN(x),trialSeqs,'UniformOutput',false);

velThresh = 12;
[trialSeqLabels,trialSeqEpochs,x_adj_cm,y_adj_cm] = BadLapsAutoFixer(x_adj_cm,y_adj_cm,trialSeqLabels,trialSeqEpochs,mazeBoundaries.lgDataBins,velThresh);
%[sequencesFixed,seqEpochsFixed,xFixed,yFixed] = BadLapsAutoFixer(xFixed,yFixed,sequencesFixed,seqEpochsFixed,mazeBoundaries.lgDataBins,12);

%trialBounds = cell2mat(trialBounds(:));
trialBounds = cell2mat(cellfun(@(x) [min(x(:)) max(x(:))],trialSeqEpochs,'UniformOutput',false));
originalBehavior.LapStart = trialBounds(:,1);
originalBehavior.LapStop = trialBounds(:,2);
originalBehavior.ArmSequence = trialSeqLabels;
originalBehavior.SeqEpochs = trialSeqEpochs;

%{
figure; plot(x_adj_cm,y_adj_cm,'.k')
hold on
lapI = 10;
plot(x_adj_cm(trialBounds(lapI,1):trialBounds(lapI,2)),y_adj_cm(trialBounds(lapI,1):trialBounds(lapI,2)),'.r')
%}

% Trim laps down to only a few points before entering / after leaving first/last arm of the lap
[trimmedBehaviorMaybe] = AutoLapTrimmer(x_adj_cm,y_adj_cm,mazeBoundaries.lgDataBins,nBoundRegions,originalBehavior,frameBuffer);

minArmEntries = 3;
[trimmedBehavior,x_adj_cm,y_adj_cm] = LapSeqValidator(x_adj_cm,y_adj_cm,trimmedBehaviorMaybe,minArmEntries);
if strcmpi(input('Continue to bad laps adjuster? (y/n):','s'),'y')
    % do nothing
else
    keyboard
end

% Edited verion of ValidateBehaviorDPwrapper, but run it on the behavior before switch to brain time
[fixedBehavior] = FindBadLapsDoublePlus2(x_adj_cm,y_adj_cm,trimmedBehavior);
%[fixedBehavior] = FindBadLapsDoublePlus2(x_adj_cm,y_adj_cm,fixedBehavior);
if strcmpi(input('Any last adjustments?','s'),'y')
    keyboard
end
trialBounds = [fixedBehavior.LapStart fixedBehavior.LapStop];
trialSeqLabels = fixedBehavior.ArmSequence;
trialSeqsOriginal = trialSeqs;
trialSeqs = [];
% Convert back to numbers
for ttI = 1:numel(fixedBehavior.ArmSequence)
    for ssI = 1:numel(fixedBehavior.ArmSequence{ttI})
        trialSeqs{ttI,1}(ssI,1) = find(armLabelsN==fixedBehavior.ArmSequence{ttI}(ssI));
    end
end
trialEpoch = ones(size(trialSeqLabels));

% Save out fixed behavior
copyfile(fullfile(sessionFolder,plusBehaviorFile),fullfile(sessionFolder,'plusMazeBehaviorOriginal.mat'))
save(fullfile(sessionFolder,plusBehaviorFile),'trialSeqs','trialEpoch','trialBounds')

try
copyfile(fullfile(sessionFolder,'PlusBehavior.xlsx'),fullfile(sessionFolder,'PlusBehaviorOriginal.xlsx'))
catch
    disp('No previously existing plusbehavior.xlsx spreadsheet')
end
behFile = fullfile(sessionFolder,'plusMazeBehavior.mat');
MakeQuickPlusSpreadsheet(sessionType,behFile,sessionFolder)

% Align imaging to tracking

% Grab real duration of xml file for imaging
[xmlDuration] = GetXmlRecordingsDurations(xmlFile);

% Grab real duration of behavior from DVT time
[aviDuration] = GetBehaviorFileDur(DVTfile);

% Align imaging to Tracking for real
load(fullfile(sessionFolder,'FinalOutput.mat'),'PSAbool')
copyfile(fullfile(sessionFolder,'Pos_brain.mat'),fullfile(sessionFolder,'Pos_brainOriginal.mat'))
AlignImagingToTrackingForcedEqual(aviDuration,DVTtime,x_adj_cm,y_adj_cm,PSAbool,fullfile(sessionFolder,'Pos_brain.mat'))

% Align plus maze behavior spreadsheet to brain time
behavTable = readtable(fullfile(sessionFolder,'PlusBehavior.xlsx'));
load(fullfile(sessionFolder,'Pos_brain.mat'),'brain_time','trackingTimeUse')
[alignedTable] = AlignTrackingFramesToBrainFrames(behavTable,trackingTimeUse,brain_time,{'LapStart','LapStop'});
try
    copyfile(fullfile(sessionFolder,'PlusBehavior_BrainTime.xlsx'),fullfile(sessionFolder,'PlusBehavior_BrainTimeOriginal.xlsx'))
catch
    disp('No previously existing plusbehavior_braintime.xlsx spreadsheet')
end
writetable(alignedTable,fullfile(sessionFolder,'PlusBehavior_BrainTime.xlsx'))

% Validate plus maze behavior against on-maze boundaries
load(fullfile(sessionFolder,'Pos_brain.mat'),'xBrain','yBrain')
eachLapsStarts = cellfun(@(x) x(1), alignedTable.ArmSequence);
eachLapsEnds = cellfun(@(x) x(end), alignedTable.ArmSequence);
uniqueStarts = unique(eachLapsStarts);
uniqueEnds = unique(eachLapsEnds);
for uu = 1:numel(uniqueStarts)
    gfg = figure('Position',[244 185 560 420]);
    plot(xBrain,yBrain,'.k')
    hold on
    ptsH = alignedTable.LapStart(eachLapsStarts==uniqueStarts(uu));
    plot(xBrain(ptsH),yBrain(ptsH),'.m')
    title(['Starts from ' uniqueStarts(uu)])
    if strcmpi(input('Looks ok?','s'),'n')
        keyboard
    end
    try; close(gfg); end
end

for uu = 1:numel(uniqueEnds)
    gfg = figure('Position',[244 185 560 420]);
    plot(xBrain,yBrain,'.k')
    hold on
    ptsH = alignedTable.LapStop(eachLapsEnds==uniqueEnds(uu));
    plot(xBrain(ptsH),yBrain(ptsH),'.m')
    title(['Ends at ' uniqueEnds(uu)])
    if strcmpi(input('Looks ok?','s'),'n')
        keyboard
    end
    try; close(gfg); end
end

copyfile(fullfile(sessionFolder,'PlusBehavior_BrainTime_Finalized.xlsx'),fullfile(sessionFolder,'PlusBehavior_BrainTime_FinalizedOriginal.xlsx'))
copyfile(fullfile(sessionFolder,'PlusBehavior_BrainTime.xlsx'),fullfile(sessionFolder,'PlusBehavior_BrainTime_Finalized.xlsx'))

disp('Done, woo!')

end

function [xmlDuration] = GetXmlRecordingsDurations(xml_file)

fileID = fopen(xml_file);
xmlText = textscan(fileID,'%s','Delimiter', '\n','CollectOutput', true);

fpsStr = xmlText{1}{find(cellfun(@any,(cellfun(@(x) strfind(x,'fps'),xmlText{1},'UniformOutput',false))))};
frameRate = str2double(fpsStr(strfind(fpsStr,'fps')+5:strfind(fpsStr,'</attr')-1));
framesStr = xmlText{1}{find(cellfun(@any,(cellfun(@(x) strfind(x,'frames'),xmlText{1},'UniformOutput',false))))};
nFrames = str2double(framesStr(strfind(framesStr,'frames')+8:strfind(framesStr,'</attr')-1));
droppedStr = xmlText{1}{find(cellfun(@any,(cellfun(@(x) strfind(x,'dropped_count'),xmlText{1},'UniformOutput',false))))};
nFramesDropped = str2double(droppedStr(strfind(droppedStr,'dropped_count')+15:strfind(droppedStr,'</attr')-1));

recordStartDat = cellfun(@(x) strfind(x,'record_start'),xmlText{1},'UniformOutput',false);
recordStartCell = find(cellfun(@any,recordStartDat));
recordStartInd = strfind(xmlText{1}{recordStartCell},'2018');
recordStartString = xmlText{1}{recordStartCell}(recordStartInd+5:end-10);
recordStartNums = cellfun(@str2double,(strsplit(recordStartString,':')));
ispmStart = strcmpi(xmlText{1}{recordStartCell}(end-8:end-7),'PM');

recordEndDat = cellfun(@(x) strfind(x,'record_end'),xmlText{1},'UniformOutput',false);
recordEndCell = find(cellfun(@any,recordEndDat));
recordEndInd = strfind(xmlText{1}{recordEndCell},'2018');
recordEndString = xmlText{1}{recordEndCell}(recordEndInd+5:end-10);
recordEndNums = cellfun(@str2double,(strsplit(recordEndString,':')));
ispmEnd = strcmpi(xmlText{1}{recordEndCell}(end-8:end-7),'PM');

if ispmStart ~= ispmEnd
    % Adjust for one in AM one in PM
    if ~ispmStart && ispmEnd && (recordEndNums(1) < 12)
        recordEndNums(1) = recordEndNums(1) + 12;
    end
end

if ispmStart && ispmEnd
    if recordStartNums(1) == 12
        if recordEndNums(1) < 12
            recordEndNums(1) = recordEndNums(1) + 12;
        end
    end
end
    
startTimeSeconds = secondsFromTime(recordStartNums(1),recordStartNums(2),recordStartNums(3));
endTimeSeconds = secondsFromTime(recordEndNums(1),recordEndNums(2),recordEndNums(3));

xmlDuration = endTimeSeconds - startTimeSeconds;

end

function [aviDuration] = GetBehaviorFileDur(DVTfile)


% Get CinePlex reported duration
posData = importdata(DVTfile);
cpTime = posData(:,2);
aviDuration = cpTime(end) - cpTime(1);
aviTimeDurNooffset = cpTime(end);

end