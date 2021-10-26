condsCheck = [1 3];
for mouseI = 1:numMice
    for sessI = 1:9
    for condI = 1:2
        trialsHere = cellTBTall{mouseI}(condsCheck(condI)).sessID==sessI;
        
        perfHere = cellTBTall{mouseI}(condsCheck(condI)).isCorrect(trialsHere);
        allowedFix = cellTBTall{mouseI}(condsCheck(condI)).allowedFix(trialsHere);
        
        performance{condI}(mouseI,sessI) = ...
            sum(perfHere & allowedFix==0) / numel(perfHere);
        
    end
    end
end

%save('E:\DoublePlus\Kerberos\day5-6behavior.mat','day5starts','day5response','day5correct','day6allowedFix','day6starts','day6response','day6correct','day6allowedFix')
load('E:\DoublePlus\Kerberos\day5-6behavior.mat')
nStarts = cellfun(@(x) strcmpi(x,'n'),day5starts);
sStarts = cellfun(@(x) strcmpi(x,'s'),day5starts);
performance{1}(1,5) = sum( day5correct(nStarts & day5allowedFix==0)) / sum(nStarts);
performance{2}(1,5) = sum( day5correct(sStarts & day5allowedFix==0)) / sum(sStarts);
nStarts = cellfun(@(x) strcmpi(x,'n'),day6starts);
sStarts = cellfun(@(x) strcmpi(x,'s'),day6starts);
performance{1}(1,6) = sum( day6correct(nStarts & day6allowedFix==0)) / sum(nStarts);
performance{2}(1,6) = sum( day6correct(sStarts & day6allowedFix==0)) / sum(sStarts);

figure;
subplot(2,1,1)
for mouseI = 1:numMice
    plot(1:9, performance{1}(mouseI,:)*100,'Color',groupColors{groupNum(mouseI)},'LineWidth',1.5);
    hold on
end
MakePlotPrettySL(gca);
ylim([20 100])
title('North Arm Starts')
xlabel('Day Number')
ylabel('Pct Correct')
subplot(2,1,2)
for mouseI = 1:numMice
    plot(1:9, performance{2}(mouseI,:)*100,'Color',groupColors{groupNum(mouseI)},'LineWidth',1.5);
    hold on
end
MakePlotPrettySL(gca);
ylim([70 100])
title('South Arm Starts')
xlabel('Day Number')
ylabel('Pct Correct')
