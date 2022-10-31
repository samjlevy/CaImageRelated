function imagingDriftEvaluation1
%% These for all files
mainFolder = 'D:\DoublePlus';
mice = {'Kerberos','Marble07','Marble11','Pandora','Styx','Titan'};
numMice = numel(mice);

brainDurs = NaN(9,numMice);
aviDurs = NaN(9,numMice);
aviDursNooffset = NaN(9,numMice);
for mouseI = 1:numMice
    load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'),'allfiles')
    fileAllFiles{mouseI} = allfiles;
    
    for fileI = 1:9
        folderPts = strsplit(allfiles{fileI},'\');
        fH = folderPts{end};
        try
            cd(fullfile(mainFolder,mice{mouseI},fH))
            
            disp(['Mouse ' num2str(mouseI) ', sess ' num2str(fileI)])
            [brainDurs(fileI,mouseI),aviDurs(fileI,mouseI),aviDursNooffset(fileI,mouseI),brainFrameRate(fileI,mouseI)] = GetRecordingsDurations;

        catch
            disp('Missing folder?')
            %keyboard
        end

    end
    
end

timeDiffs = brainDurs - aviDurs;
figure; 
subplot(1,2,1)
plot(brainDurs(abs(timeDiffs)<10),-timeDiffs(abs(timeDiffs)<10),'*')
ylabel('CinePlex Duration - nVista Duration (s)')
xlabel('CinePlex Duration (s)')
subplot(1,2,2)
plot(brainDurs(abs(timeDiffs)<10),-timeDiffs(abs(timeDiffs)<10),'*')
ylabel('CinePlex Duration - nVista Duration (s)')
xlabel('nVista Duration (s)')

haveGoodTiming = abs(timeDiffs)<10;
for mouseI = 1:numMice
    if any(haveGoodTiming(:,mouseI))
        load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'),'trialbytrialThresh')
tic
        [rhoSlope{mouseI},pSpearman{mouseI},comSlop{mouseI},pSlope{mouseI},nTrialsActive{mouseI}] = GetTBTcom(trialbytrialThresh);
        toc
    end  
end

nTrialThresh = 9;
meanSlopes = NaN(9,6);
stdSlopes = NaN(9,6);
for mouseI = 1:numMice
    if any(haveGoodTiming(:,mouseI))
        for dayI = 1:9
            if haveGoodTiming(dayI,mouseI)
                slopesHall = squeeze(comSlop{mouseI}(:,dayI,:));
                nTrialsH = squeeze(nTrialsActive{mouseI}(:,dayI,:));
                meanSlopes(dayI,mouseI) = mean(slopesHall(nTrialsH >= nTrialThresh));
                stdSlopes(dayI,mouseI) = std(slopesHall(nTrialsH >= nTrialThresh));
            end
        end
        
    end
end

figure;
plot(-timeDiffs(haveGoodTiming),meanSlopes(haveGoodTiming),'*')

armLabels = {'n','w','s','e'}
end
%%
function [brainTimeDur,aviTimeDur,aviTimeDurNooffset,frameRate,nFrames,nFramesDropped] = GetRecordingsDurations

% Get nVista reported recording duration
xml_file = ls('*.xml');
avi_file = ls('*.DVT');

if isempty(xml_file)
    disp('Missing xml file')
end
if isempty(avi_file)
    disp('Missing avi file')
end

brainTimeDur = [];
aviTimeDur = [];
aviTimeDurNooffset = [];

if ~(isempty(xml_file) || isempty(avi_file))

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

brainTimeDur = endTimeSeconds - startTimeSeconds;

% Get CinePlex reported duration
posData = importdata(avi_file);
cpTime = posData(:,2);
aviTimeDur = cpTime(end) - cpTime(1);
aviTimeDurNooffset = cpTime(end);

end

end