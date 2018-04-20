function [performance, miscoded, typePredict, sessPairs, condsInclude] = DecoderWrapper1(trialbytrial,traitLogical,realdays,numShuffles,activityType)
%This function is built as a wrapper for looking at decoding results by
%splitting. Pretty much the only thing that needs to be given is basic
%data and parameters, testing for significance, etc., is handled here
%Trait logical is cells X days does the cell do the thing. Should come in
%pre-filtered for dayUse
%Using same set on training on testing, but functionality is there to try something else
%activityType is what kind of reduction of PSAbool to use. Default (and
%only tested so far) is transientDur. Right now can only handle one option

%not using usesplitters anymore, maybe to select subsets of cells by number
%have to do that when putting together traitLogical

%what to decode 'leftright' or 'studytest'; maybe don't need this, just
%decode everything and do it later
%    - alternatively, could pull this out of conds include?

Conds = GetTBTconds(trialbytrial);
condsInclude = [Conds.Study; Conds.Test; Conds.Left; Conds.Right]; 
titles = {'StudyLvR', 'TestLvR', 'LeftSvT', 'RightSvT'}; 
typePredict = {'leftright', 'leftright', 'studytest', 'studytest'}; 
randomizeNow = [zeros(1, length(titles)); ones(numShuffles,length(titles))];

trainingSessions = 1:length(realdays);
testingSessions = 1:length(realdays);
sessPairs = GetAllCombs(trainingSessions, testingSessions);

%Lap Combinations (leave one out)
[trainingLaps, testingLaps] = leaveOneOutAllCombs(trialbytrial);

%Actual activity to give to 
[tbtActivity] = lapbylapActivity(trialbytrial);
lblActivity = tbtActivity.transientDur;

%Decode some stuff
numSetups = size(condsInclude,1);
performance = cell(1+numShuffles,numSetups);
miscoded = cell(1+numShuffles,numSetups);
p = ProgressBar(1+numShuffles);
for iterationI = 1:1+numShuffles %Original and any shuffles
    for setupI = 1:numSetups
        decoded = [];
        testing = [];
        actual = [];

        for sessPairI = 1:size(sessPairs,1)
            %Assign sessions
            trainSess = sessPairs(sessPairI,1);
            testSess = sessPairs(sessPairI,2);

            %Select cells
            cellsUse = traitLogical(:,trainSess);
            %cellsUse = dayUse(:,trainSess).*(thisCellSplitsST.(titles{setupI})(:,trainSess)==usesplitters(setupI));
            trainingCells = cellsUse;
            testingCells = cellsUse;

            %Decode
            [~, testing, decoded{sessPairI}, ~] = decodeAcrossConditions2(trialbytrial,...
                condsInclude(setupI,:), typePredict{setupI}, trainSess, testSess,...
                trainingCells, testingCells, trainingLaps, testingLaps, lblActivity, randomizeNow(iterationI,setupI));
            
            actual{sessPairI} = [testing(:).answers]';

        end

        %Log performance: columns are by titles, rows are each pass (1 regular, all others shuffled)
        [performance{iterationI, setupI}, miscoded{iterationI, setupI}] = decoderResults2(decoded, actual, sessPairs, realdays);
    end
    %disp(['Finished combination ' num2str(iterationI)])
    p.progress;
end
p.stop;

end