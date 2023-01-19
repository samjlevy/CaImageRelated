% Silent cells recruited for Go East in two maze group?

% Across each day pair...
% Turn right 1 to Go East:
cells that are present but below activity threshold that become above activity threshold
% Go East to turn right 2:
cells that stay present but drop below activity threshold

% Could either do this overall by looking at each day pair,
% Or on each adjacent day pair and ask if this is higher for days 3-4, 6-7

dayPairsHere = [1 2; 2 3; 3 4; 4 5; 5 6; 6 7; 7 8; 8 9];
dayPairsGroups = [1,   1,   2,   1,   1,   2,   1,   1]; 

dayPairsHere = combnk(1:9,2);
dayPairsGroups = zeros(size(dayPairsHere,1),1);
firstEpoch = dayPairsHere < 4;
secondEpoch = dayPairsHere > 3 & dayPairsHere < 7;
thirdEpoch = dayPairsHere > 6;
sameEpoch = sum(firstEpoch,2)==2 | sum(secondEpoch,2)==2 | sum(thirdEpoch,2)==2;
turnVplace = (firstEpoch(:,1) & secondEpoch(:,2)) | (secondEpoch(:,1) & thirdEpoch(:,2));
turn1vTurn2 = firstEpoch(:,1) & thirdEpoch(:,2);
dayPairsGroups(turn1vTurn2 | sameEpoch) = 1; dayPairsGroups(turnVplace) = 2;
    %dayPairsGroups(turn1vTurn2) = 3;
% Same epoch
% Turn1 place
% place Turn2
% Turn1 Turn2
    dayPairsGroups(sameEpoch) = 1; dayPairsGroups(firstEpoch(:,1) & secondEpoch(:,2)) = 2;
    dayPairsGroups(secondEpoch(:,1) & thirdEpoch(:,2)) = 3; dayPairsGroups(turn1vTurn2) = 4;
    scatterLabels = {'Same/Within','Diff/Within','Same/Turn1place','Diff/Turn1place','Same/placeTurn2','Diff/placeTurn2','Same/Turn1Turn2','Diff/Turn1Turn2'};
    scatterColors = repmat([groupColors{1};groupColors{2}],numel(unique(dayPairsGroups)),1);

becomeInactive = cell(1,3); [becomeInactive{:}] = deal(nan(numMice,size(dayPairsHere,1)));
becomeActive = cell(1,3); [becomeActive{:}] = deal(nan(numMice,size(dayPairsHere,1)));

becomeInactiveHaveROIboth = cell(2,numel(unique(dayPairsGroups)));
becomeInactiveHaveROIeither = cell(2,numel(unique(dayPairsGroups)));
becomeInactiveHaveROIany = cell(2,numel(unique(dayPairsGroups)));

becomeActiveHaveROIboth = cell(2,numel(unique(dayPairsGroups)));
becomeActiveHaveROIeither = cell(2,numel(unique(dayPairsGroups)));
becomeActiveHaveROIany = cell(2,numel(unique(dayPairsGroups)));

for mouseI = 1:numMice
    for dpI = 1:size(dayPairsHere,1)
        dayPairH = dayPairsHere(dpI,:);
        if sum(sum(cellSSI{mouseI}(:,dayPairH),1)>0)==2
            cellsPresentDayA = cellSSI{mouseI}(:,dayPairH(1));
            cellsActiveDayA = trialReliAll{mouseI}(:,dayPairH(1));

            cellsPresentDayB = cellSSI{mouseI}(:,dayPairH(2));
            cellsActiveDayB = trialReliAll{mouseI}(:,dayPairH(2));

            % To deal with cells that drop out of imaging SNR
            cellsPresentEitherDays = cellsPresentDayA | cellsPresentDayB;
            cellsPresentBothDays = cellsPresentDayA & cellsPresentDayB;
            cellsPresentAnyDay = true(numCells(mouseI),1);

            cellsBecomeInactive = cellsActiveDayA & ~cellsActiveDayB;
            cellsBecomeActive = ~cellsActiveDayA & cellsActiveDayB;

            % Keep Track for each mouse
            becomeInactive{1}(mouseI,dpI) = sum(cellsBecomeInactive & cellsPresentBothDays) / sum(cellsPresentBothDays);
            becomeInactive{2}(mouseI,dpI) = sum(cellsBecomeInactive & cellsPresentEitherDays) / sum(cellsPresentEitherDays);
            becomeInactive{3}(mouseI,dpI) = sum(cellsBecomeInactive & cellsPresentAnyDay) / sum(cellsPresentAnyDay);

            becomeActive{1}(mouseI,dpI) = sum(cellsBecomeActive & cellsPresentBothDays) / sum(cellsPresentBothDays);
            becomeActive{2}(mouseI,dpI) = sum(cellsBecomeActive & cellsPresentEitherDays) / sum(cellsPresentEitherDays);
            becomeActive{3}(mouseI,dpI) = sum(cellsBecomeActive & cellsPresentAnyDay) / sum(cellsPresentAnyDay);

            % Aggregate by group, days within/across
            becomeInactiveHaveROIboth{groupNum(mouseI),dayPairsGroups(dpI)}(end+1) = becomeInactive{1}(mouseI,dpI);
            becomeInactiveHaveROIeither{groupNum(mouseI),dayPairsGroups(dpI)}(end+1) = becomeInactive{2}(mouseI,dpI);
            becomeInactiveHaveROIany{groupNum(mouseI),dayPairsGroups(dpI)}(end+1) = becomeInactive{3}(mouseI,dpI);

            becomeActiveHaveROIboth{groupNum(mouseI),dayPairsGroups(dpI)}(end+1) = becomeActive{1}(mouseI,dpI);
            becomeActiveHaveROIeither{groupNum(mouseI),dayPairsGroups(dpI)}(end+1) = becomeActive{2}(mouseI,dpI);
            becomeActiveHaveROIany{groupNum(mouseI),dayPairsGroups(dpI)}(end+1) = becomeActive{3}(mouseI,dpI);
        end
    end
end
%{
cellfun(@(x) any(isnan(x)),becomeInactiveHaveROIboth)
cellfun(@(x) any(isnan(x)),becomeInactiveHaveROIeither)
cellfun(@(x) any(isnan(x)),becomeInactiveHaveROIany)

cellfun(@(x) any(isnan(x)),becomeActiveHaveROIboth)
cellfun(@(x) any(isnan(x)),becomeActiveHaveROIeither)
cellfun(@(x) any(isnan(x)),becomeActiveHaveROIany)
%}

scatterBoxWrapper2([],{'Same/Within','Diff/Within','Same/Across','Diff/Across'},[groupColors{1};groupColors{2};groupColors{1};groupColors{2}],becomeActiveHaveROIboth)
title(['Pct cells that become active between sessions, have ROI both sessions'])
[ppa] = ranksum(becomeActiveHaveROIboth{1,1},becomeActiveHaveROIboth{2,1}); % within, OneEnv v TwoEnv
[ppb] = ranksum(becomeActiveHaveROIboth{1,2},becomeActiveHaveROIboth{2,2}); % across, OneEnv v TwoEnv
[ppc] = ranksum(becomeActiveHaveROIboth{1,1},becomeActiveHaveROIboth{1,2}); % OneEnv, within vs. across
[ppd] = ranksum(becomeActiveHaveROIboth{2,1},becomeActiveHaveROIboth{2,2}); % TwoEnv, within vs. across
magText = {'becomeActiveHaveROIboth:';...
           ['Within: OneMaze v. TwoMaze p = ' num2str(ppa)];...
           ['Across: OneMaze v. TwoMaze p = ' num2str(ppb)];...
           ['OneMaze: Within v. Across p = ' num2str(ppc)];...
           ['TwoMaze: Within v. Across p = ' num2str(ppd)]};
msgbox(magText)

scatterBoxWrapper2([],{'Same/Within','Diff/Within','Same/Across','Diff/Across'},[groupColors{1};groupColors{2};groupColors{1};groupColors{2}],becomeActiveHaveROIeither)
%scatterBoxWrapper2([],scatterLabels,scatterColors,becomeActiveHaveROIeither)
title(['Pct cells that become active between sessions, have ROI either session'])
[ppa] = ranksum(becomeActiveHaveROIeither{1,1},becomeActiveHaveROIeither{2,1}); % within, OneEnv v TwoEnv
[ppb] = ranksum(becomeActiveHaveROIeither{1,2},becomeActiveHaveROIeither{2,2}); % across, OneEnv v TwoEnv
[ppc] = ranksum(becomeActiveHaveROIeither{1,1},becomeActiveHaveROIeither{1,2}); % OneEnv, within vs. across
[ppd] = ranksum(becomeActiveHaveROIeither{2,1},becomeActiveHaveROIeither{2,2}); % TwoEnv, within vs. across
magText = {'becomeActiveHaveROIeither:';...
           ['Within: OneMaze v. TwoMaze p = ' num2str(ppa)];...
           ['Across: OneMaze v. TwoMaze p = ' num2str(ppb)];...
           ['OneMaze: Within v. Across p = ' num2str(ppc)];...
           ['TwoMaze: Within v. Across p = ' num2str(ppd)]};
msgbox(magText)

%scatterBoxWrapper2([],{'Same/Within','Diff/Within','Same/Across','Diff/Across'},[groupColors{1};groupColors{2};groupColors{1};groupColors{2}],becomeActiveHaveROIany)
%title(['Pct cells that become active between sessions, have ROI any session'])

scatterBoxWrapper2([],{'Same/Within','Diff/Within','Same/Across','Diff/Across'},[groupColors{1};groupColors{2};groupColors{1};groupColors{2}],becomeInactiveHaveROIboth)
%scatterBoxWrapper2([],{'Same/Within','Diff/Within','Same/Across','Diff/Across','Same/Turn1Turn2','Diff/Turn1Turn2'},[groupColors{1};groupColors{2};groupColors{1};groupColors{2};groupColors{1};groupColors{2}],becomeInactiveHaveROIboth)
title(['Pct cells that become INactive between sessions, have ROI both sessions'])
[ppa] = ranksum(becomeInactiveHaveROIboth{1,1},becomeInactiveHaveROIboth{2,1}); % within, OneEnv v TwoEnv
[ppb] = ranksum(becomeInactiveHaveROIboth{1,2},becomeInactiveHaveROIboth{2,2}); % across, OneEnv v TwoEnv
[ppc] = ranksum(becomeInactiveHaveROIboth{1,1},becomeInactiveHaveROIboth{1,2}); % OneEnv, within vs. across
[ppd] = ranksum(becomeInactiveHaveROIboth{2,1},becomeInactiveHaveROIboth{2,2}); % TwoEnv, within vs. across
magText = {'becomeInactiveHaveROIboth:';...
           ['Within: OneMaze v. TwoMaze p = ' num2str(ppa)];...
           ['Across: OneMaze v. TwoMaze p = ' num2str(ppb)];...
           ['OneMaze: Within v. Across p = ' num2str(ppc)];...
           ['TwoMaze: Within v. Across p = ' num2str(ppd)]};
msgbox(magText)

scatterBoxWrapper2([],{'Same/Within','Diff/Within','Same/Across','Diff/Across'},[groupColors{1};groupColors{2};groupColors{1};groupColors{2}],becomeInactiveHaveROIeither)
title(['Pct cells that become INactive between sessions, have ROI either session'])
[ppa] = ranksum(becomeInactiveHaveROIeither{1,1},becomeInactiveHaveROIeither{2,1}); % within, OneEnv v TwoEnv
[ppb] = ranksum(becomeInactiveHaveROIeither{1,2},becomeInactiveHaveROIeither{2,2}); % across, OneEnv v TwoEnv
[ppc] = ranksum(becomeInactiveHaveROIeither{1,1},becomeInactiveHaveROIeither{1,2}); % OneEnv, within vs. across
[ppd] = ranksum(becomeInactiveHaveROIeither{2,1},becomeInactiveHaveROIeither{2,2}); % TwoEnv, within vs. across
magText = {'becomeInactiveHaveROIeither:';...
           ['Within: OneMaze v. TwoMaze p = ' num2str(ppa)];...
           ['Across: OneMaze v. TwoMaze p = ' num2str(ppb)];...
           ['OneMaze: Within v. Across p = ' num2str(ppc)];...
           ['TwoMaze: Within v. Across p = ' num2str(ppd)]};
msgbox(magText)

%scatterBoxWrapper2([],{'Same/Within','Diff/Within','Same/Across','Diff/Across'},[groupColors{1};groupColors{2};groupColors{1};groupColors{2}],becomeInactiveHaveROIany)
%title(['Pct cells that become INactive between sessions, have ROI any session'])

% All 4 comparisons
scatterBoxWrapper2([],scatterLabels,scatterColors,becomeActiveHaveROIboth); title('becomeActiveHaveROIboth'); ylabel('prop. become active')
magText = {'becomeActiveHaveROIboth:';...
           ['Within: OneMaze v. TwoMaze p = ' num2str(ranksum(becomeActiveHaveROIboth{1,1},becomeActiveHaveROIboth{2,1}))];...
           ['Turn1Place: OneMaze v. TwoMaze p = ' num2str(ranksum(becomeActiveHaveROIboth{1,2},becomeActiveHaveROIboth{2,2}))];...
           ['PlaceTurn2: OneMaze v. TwoMaze p = ' num2str(ranksum(becomeActiveHaveROIboth{1,3},becomeActiveHaveROIboth{2,3}))];...
           ['Turn1Turn2: OneMaze v. TwoMaze p = ' num2str(ranksum(becomeActiveHaveROIboth{1,4},becomeActiveHaveROIboth{2,4}))];...
           ['OneMaze: Within v Turn1place p = ' num2str(ranksum(becomeActiveHaveROIboth{1,1},becomeActiveHaveROIboth{1,2}))];...
           ['OneMaze: Within v PlaceTurn2 p = ' num2str(ranksum(becomeActiveHaveROIboth{1,1},becomeActiveHaveROIboth{1,3}))];...
           ['TwoMaze: Within v Turn1place p = ' num2str(ranksum(becomeActiveHaveROIboth{1,1},becomeActiveHaveROIboth{2,2}))];...
           ['TwoMaze: Within v PlaceTurn2 p = ' num2str(ranksum(becomeActiveHaveROIboth{1,1},becomeActiveHaveROIboth{2,3}))]};
msgbox(magText)

scatterBoxWrapper2([],scatterLabels,scatterColors,becomeInactiveHaveROIboth); title('becomeInactiveHaveROIboth'); ylabel('prop. become inactive')
magText = {'becomeInactiveHaveROIboth:';...
           ['Within: OneMaze v. TwoMaze p = ' num2str(ranksum(becomeInactiveHaveROIboth{1,1},becomeInactiveHaveROIboth{2,1}))];...
           ['Turn1Place: OneMaze v. TwoMaze p = ' num2str(ranksum(becomeInactiveHaveROIboth{1,2},becomeInactiveHaveROIboth{2,2}))];...
           ['PlaceTurn2: OneMaze v. TwoMaze p = ' num2str(ranksum(becomeInactiveHaveROIboth{1,3},becomeInactiveHaveROIboth{2,3}))];...
           ['Turn1Turn2: OneMaze v. TwoMaze p = ' num2str(ranksum(becomeInactiveHaveROIboth{1,4},becomeInactiveHaveROIboth{2,4}))];...
           ['OneMaze: Within v Turn1place p = ' num2str(ranksum(becomeInactiveHaveROIboth{1,1},becomeInactiveHaveROIboth{1,2}))];...
           ['OneMaze: Within v PlaceTurn2 p = ' num2str(ranksum(becomeInactiveHaveROIboth{1,1},becomeInactiveHaveROIboth{1,3}))];...
           ['TwoMaze: Within v Turn1place p = ' num2str(ranksum(becomeInactiveHaveROIboth{1,1},becomeInactiveHaveROIboth{2,2}))];...
           ['TwoMaze: Within v PlaceTurn2 p = ' num2str(ranksum(becomeInactiveHaveROIboth{1,1},becomeInactiveHaveROIboth{2,3}))]};
msgbox(magText)

scatterBoxWrapper2([],scatterLabels,scatterColors,becomeActiveHaveROIeither); title('becomeActiveHaveROIeither')
magText = {'becomeActiveHaveROIeither:';...
           ['Within: OneMaze v. TwoMaze p = ' num2str(ranksum(becomeActiveHaveROIeither{1,1},becomeActiveHaveROIeither{2,1}))];...
           ['Turn1Place: OneMaze v. TwoMaze p = ' num2str(ranksum(becomeActiveHaveROIeither{1,2},becomeActiveHaveROIeither{2,2}))];...
           ['PlaceTurn2: OneMaze v. TwoMaze p = ' num2str(ranksum(becomeActiveHaveROIeither{1,3},becomeActiveHaveROIeither{2,3}))];...
           ['Turn1Turn2: OneMaze v. TwoMaze p = ' num2str(ranksum(becomeActiveHaveROIeither{1,4},becomeActiveHaveROIeither{2,4}))];...
           ['OneMaze: Within v Turn1place p = ' num2str(ranksum(becomeActiveHaveROIeither{1,1},becomeActiveHaveROIeither{1,2}))];...
           ['OneMaze: Within v PlaceTurn2 p = ' num2str(ranksum(becomeActiveHaveROIeither{1,1},becomeActiveHaveROIeither{1,3}))];...
           ['TwoMaze: Within v Turn1place p = ' num2str(ranksum(becomeActiveHaveROIeither{1,1},becomeActiveHaveROIeither{2,2}))];...
           ['TwoMaze: Within v PlaceTurn2 p = ' num2str(ranksum(becomeActiveHaveROIeither{1,1},becomeActiveHaveROIeither{2,3}))]};
msgbox(magText)

scatterBoxWrapper2([],scatterLabels,scatterColors,becomeInactiveHaveROIeither); title('becomeInactiveHaveROIeither')
magText = {'becomeInactiveHaveROIeither:';...
           ['Within: OneMaze v. TwoMaze p = ' num2str(ranksum(becomeInactiveHaveROIeither{1,1},becomeInactiveHaveROIeither{2,1}))];...
           ['Turn1Place: OneMaze v. TwoMaze p = ' num2str(ranksum(becomeInactiveHaveROIeither{1,2},becomeInactiveHaveROIeither{2,2}))];...
           ['PlaceTurn2: OneMaze v. TwoMaze p = ' num2str(ranksum(becomeInactiveHaveROIeither{1,3},becomeInactiveHaveROIeither{2,3}))];...
           ['Turn1Turn2: OneMaze v. TwoMaze p = ' num2str(ranksum(becomeInactiveHaveROIeither{1,4},becomeInactiveHaveROIeither{2,4}))];...
           ['OneMaze: Within v Turn1place p = ' num2str(ranksum(becomeInactiveHaveROIeither{1,1},becomeInactiveHaveROIeither{1,2}))];...
           ['OneMaze: Within v PlaceTurn2 p = ' num2str(ranksum(becomeInactiveHaveROIeither{1,1},becomeInactiveHaveROIeither{1,3}))];...
           ['TwoMaze: Within v Turn1place p = ' num2str(ranksum(becomeInactiveHaveROIeither{1,1},becomeInactiveHaveROIeither{2,2}))];...
           ['TwoMaze: Within v PlaceTurn2 p = ' num2str(ranksum(becomeInactiveHaveROIeither{1,1},becomeInactiveHaveROIeither{2,3}))]};
msgbox(magText)