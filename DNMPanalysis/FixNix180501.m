%This script is to fix the FinalOutput of Nix180501 because that file was
%run through tenaspis without the middle chunk of frames due to a high
%number of dropped and tiled frames
framesUsed{1} = 1:20001;
framesUsed{2} = 38642:nFrames;

load('FinalOutputOriginal.mat');

mosaicObjectConcatenation = load('Obj_1 - Concatenation Frame Indices.mat');
catFrames = cell2mat(mosaicObjectConcatenation.Object.Data);

findLabel = {'<attr name="frames">';...
            '<attr name="dropped_count">';...
            '<attr name="dropped">'};
xml_file = 'recording_20180501_184314.xml';
fileID = fopen(xml_file);
xmlText = textscan(fileID,'%s','Delimiter', '\n','CollectOutput', true);
for xmlLine = 1:length(xmlText{1,1})
    if length(xmlText{1,1}{xmlLine,1}) >= length(findLabel{1})
        if strcmp(findLabel{1},xmlText{1,1}{xmlLine,1}(1:length(findLabel{1})))
            strEnd = strfind(xmlText{1,1}{xmlLine,1}, '</attr>');
            nFrames = str2double(xmlText{1,1}{xmlLine,1}((length(findLabel{1})+1):(strEnd-1)));
        end
    end
    if length(xmlText{1,1}{xmlLine,1}) >= length(findLabel{2})
        if strcmp(findLabel{2},xmlText{1,1}{xmlLine,1}(1:length(findLabel{2})))
            strEnd = strfind(xmlText{1,1}{xmlLine,1}, '</attr>');
            nDropped = str2double(xmlText{1,1}{xmlLine,1}((length(findLabel{2})+1):(strEnd-1)));
            if isempty(nDropped)
                nDropped = 0;
            end
        end
    end
    if length(xmlText{1,1}{xmlLine,1}) >= length(findLabel{3})
        if strcmp(findLabel{3},xmlText{1,1}{xmlLine,1}(1:length(findLabel{3})))
            %keyboard
            strEnd = strfind(xmlText{1,1}{xmlLine,1}, '</attr>');
            droppedFrames = xmlText{1,1}{xmlLine,1}((length(findLabel{3})+2):(strEnd-2));
            droppedFrames = cell2mat(cellfun(@str2double,strsplit(droppedFrames,', ')','UniformOutput',false));
        end
    end
end

realNumberFrames = nFrames + nDropped;

%This is from my notes on what I did
framesUsed{1} = 1:20001; 
framesUsed{2} = 38462:nFrames; %originally 38642

%Sanity check
nFramesUsed = length(framesUsed{1}) + length(framesUsed{2});
FramesMissing = framesUsed{1}(end)+1:framesUsed{2}(1)-1;
nFramesSkipped = length(FramesMissing);

disp([num2str(nFramesUsed) ' + ' num2str(nFramesSkipped) ' ?= ' num2str(nFrames)])
switch nFramesUsed + nFramesSkipped == nFrames
    case 1
        disp(['Winner winner, math is adding up'])
    case 0
        disp('Uh oh')
end
        
%Now actually fix the shit
%Going to hard code the solution instead of generalizing
nCells = size(PSAbool,1);

%Fix dropped frames
%framesToFix = sum(framesUsed{2} == droppedFrames,1);
%sum(droppedFrames > framesUsed{2}(1)-1) == sum(framesToFix)
%framesToFixAdj = framesUsed{2}(logical(framesToFix)) - (framesUsed{2}(1)-1);
framesToFix = droppedFrames(droppedFrames >= framesUsed{2}(1));
framesToFixAdj = framesToFix - (framesUsed{2}(1)-1) + framesUsed{1}(end);
for ffI = 1:length(framesToFixAdj)
    %PSAbool = [PSAbool(:,1:framesToFixAdj(ffI)-1) PSAbool(:,framesToFixAdj(ffI)-1) PSAbool(:,framesToFixAdj(ffI):end)];
    NeuronTraces.RawTrace = [NeuronTraces.RawTrace(:,1:framesToFixAdj(ffI)-1)...
        NeuronTraces.RawTrace(:,framesToFixAdj(ffI)-1) NeuronTraces.RawTrace(:,framesToFixAdj(ffI):end)];
end

%Insert a big blank chunk
missedDropped = droppedFrames(droppedFrames >= framesUsed{1}(end) & droppedFrames <= framesUsed{2}(1));
PSAbool = [PSAbool(:,framesUsed{1}), zeros(nCells,nFramesSkipped),...
    zeros(nCells,length(missedDropped)), PSAbool(:,framesUsed{1}(end)+1:end)];
NeuronTraces.RawTrace = [NeuronTraces.RawTrace(:,framesUsed{1}), zeros(nCells,nFramesSkipped),...
    zeros(nCells,length(missedDropped)), NeuronTraces.RawTrace(:,framesUsed{1}(end)+1:end)];

if size(PSAbool,2) == realNumberFrames
    disp('Congrats you did it')
else
    disp('dang something went wrong')
end

save FinalOutput.mat BinSim NeuronActivity NeuronAvg NeuronFrameList NeuronImage...
    NeuronObjList NeuronROIidx NeuronTraces NumNeurons PSAbool Trans2ROI

BEstart = framesUsed{1}(end)+1;
BEgoesFor = nFramesSkipped + length(missedDropped);
BehaviorExclude = BEstart:BEstart+BEgoesFor-1;

save BehaviorFramesExclude.mat BehaviorExclude

