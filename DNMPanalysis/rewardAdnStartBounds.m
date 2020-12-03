for mouseI = 1:numMice
    load(fullfile(mainFolder,mice{mouseI},'adjustedRewardLocations.mat'),...
        'startXadj','startYadj','rewardXadj','rewardYadj')
    
    % Aggregate start locations
    smallStart.turn.north(mouseI,1:2) = [startXadj{1}(1) startYadj{1}(1)];
    smallStart.turn.south(mouseI,1:2) = [startXadj{1}(2) startYadj{1}(2)];
    
    smallStart.place.north(mouseI,1:2) = [startXadj{2}(1) startYadj{2}(1)];
    smallStart.place.south(mouseI,1:2) = [startXadj{2}(2) startYadj{2}(2)];
    
    largeStart.turn.north(mouseI,1:2) = [startXadj{3}(1) startYadj{3}(1)];
    largeStart.turn.south(mouseI,1:2) = [startXadj{3}(2) startYadj{3}(2)];
    
    switch length(startXadj)
        case 4
            largeStart.place.north(mouseI,1:2) = [startXadj{4}(1) startYadj{4}(1)];
            largeStart.place.south(mouseI,1:2) = [startXadj{4}(2) startYadj{4}(2)];
        case 3
            largeStart.place.north(mouseI,1:2) = [NaN NaN];
            largeStart.place.south(mouseI,1:2) = [NaN NaN];
    end
    
    % Aggregate end locations
    smallReward.turn.east(mouseI,1:2) = [rewardXadj{1}(1) rewardYadj{1}(1)];
    smallReward.turn.west(mouseI,1:2) = [rewardXadj{1}(2) rewardYadj{1}(2)];
    
    smallReward.place.east(mouseI,1:2) = [rewardXadj{2}(1) rewardYadj{2}(1)];
    smallReward.place.west(mouseI,1:2) = [rewardXadj{2}(2) rewardYadj{2}(2)];
    
    largeReward.turn.east(mouseI,1:2) = [rewardXadj{3}(1) rewardYadj{3}(1)];
    largeReward.turn.west(mouseI,1:2) = [rewardXadj{3}(2) rewardYadj{3}(2)];
    
    switch length(startXadj)
        case 4
            largeReward.place.east(mouseI,1:2) = [rewardXadj{4}(1) rewardYadj{4}(1)];
            largeReward.place.west(mouseI,1:2) = [rewardXadj{4}(2) rewardYadj{4}(2)];
        case 3
            largeReward.place.east(mouseI,1:2) = [NaN NaN];
            largeReward.place.west(mouseI,1:2) = [NaN NaN];
    end
end

smallStart.turn.mean.north = nanmean(smallStart.turn.north,1);
smallStart.turn.mean.south = nanmean(smallStart.turn.south,1);

smallStart.place.mean.north = nanmean(smallStart.place.north,1);
smallStart.place.mean.south = nanmean(smallStart.place.south,1);

largeStart.turn.mean.north = nanmean(largeStart.turn.north,1);
largeStart.turn.mean.south = nanmean(largeStart.turn.south,1);

largeStart.place.mean.north = nanmean(largeStart.place.north,1);
largeStart.place.mean.south = nanmean(largeStart.place.south,1);

smallReward.turn.mean.east = nanmean(smallReward.turn.east,1);
smallReward.turn.mean.west = nanmean(smallReward.turn.west,1);

smallReward.place.mean.east = nanmean(smallReward.place.east,1);
smallReward.place.mean.west = nanmean(smallReward.place.west,1);

largeReward.turn.mean.east = nanmean(largeReward.turn.east,1);
largeReward.turn.mean.west = nanmean(largeReward.turn.west,1);

largeReward.place.mean.east = nanmean(largeReward.place.east,1);
largeReward.place.mean.west = nanmean(largeReward.place.west,1);
