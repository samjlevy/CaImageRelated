function [performance, miscoded, typePredict, sessPairs, condsInclude, cellsUsed] =...
    DecoderWrapper2(trialbytrial,traitLogical,realdays,numShuffles,activityType,pooledUnpooled,cellNumLimit,cnlExceedShuffs)
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

%CellNumLimit tells max number of cells to use in decoding. If the number
%of available cells (pass traitLogical) exceeds that, cnlExceedShuffs
%determines how many shuffles to do of those cells available

Conds = GetTBTconds(trialbytrial);
switch pooledUnpooled
    case 'unpooled'
        condsInclude = [Conds.Study; Conds.Test; Conds.Left; Conds.Right];
        titles = {'StudyLvR', 'TestLvR', 'LeftSvT', 'RightSvT'}; 
        typePredict = {'leftright', 'leftright', 'studytest', 'studytest'}; 
    case 'pooled'
        condsInclude = [1 2 3 4; 1 2 3 4];
        %condsInclude = [Conds.Left Conds.Right; Conds.Study Conds.Test];
        titles = {'Left vs. Right'; 'Study vs. Test'};
        typePredict = {'leftright', 'studyTest'};
end

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
    parfor setupI = 1:numSetups
        decoded = [];
        testing = [];
        actual = [];

        cellsUsedSessPair = [];
        for sessPairI = 1:size(sessPairs,1)
            %Assign sessions
            trainSess = sessPairs(sessPairI,1);
            testSess = sessPairs(sessPairI,2);

            %Select cells
            cellsUse = traitLogical(:,trainSess);
            trainingCells = cellsUse;
            testingCells = cellsUse;

            %Decode
            [~, testing, decoded{sessPairI}, ~] = decodeAcrossConditions2(trialbytrial,...
                condsInclude(setupI,:), typePredict{setupI}, trainSess, testSess,...
                trainingCells, testingCells, trainingLaps, testingLaps, lblActivity, randomizeNow(iterationI,setupI));
            
            actual{sessPairI} = [testing(:).answers]';
            cellsUsedSessPair{sessPairI} = find(cellsUse);

        end

        %Log performance: columns are by titles, rows are each pass (1 regular, all others shuffled)
        [perf, misc] = decoderResults2(decoded, actual, sessPairs, realdays);
        
        performance{iterationI, setupI} = perf;
        miscoded{iterationI, setupI} = misc;
        
        cellsUsed{iterationI,setupI} = cellsUsedSessPair;
    end
    %disp(['Finished combination ' num2str(iterationI)])
    p.progress;
end
p.stop;

end