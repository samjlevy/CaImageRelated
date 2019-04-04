function [figHandOut, statsOut] = PlotMeanPVcorrsDiffDaysApart(CSpooledPVcorrsOne, CSpooledPVdaysApart, condSetColors, condSetLabels, figHand) 
%Actually does a sensitivity index

global dayLagLimit
if any(dayLagLimit)
    for csI = 1:length(CSpooledPVcorrsOne)
        badDayLags = CSpooledPVdaysApart{csI} > dayLagLimit;
        CSpooledPVcorrsOne{csI}(badDayLags) = [];
        CSpooledPVdaysApart{csI}(badDayLags) = [];
    end
end
maxDay = max(cell2mat(cellfun(@max,CSpooledPVdaysApart,'UniformOutput',false)));

%Assumes 1st is noise (vs. self)
for pvpI = 2:length(CSpooledPVcorrsOne)
    dayDiffsHere = unique([CSpooledPVdaysApart{1}; CSpooledPVdaysApart{pvpI}]);
    for ddI = 1:length(dayDiffsHere)
        daysUseSig = CSpooledPVdaysApart{pvpI}==dayDiffsHere(ddI);
        daysUseNoise = CSpooledPVdaysApart{1}==dayDiffsHere(ddI);

        [dPrime{pvpI-1}(ddI),pVal{pvpI-1}(ddI)] =...
            SensitivityIndexSL(CSpooledPVcorrsOne{pvpI}(daysUseSig),...
                               CSpooledPVcorrsOne{1}(daysUseNoise),1000);
    end
    dPrime{pvpI-1} = abs(dPrime{pvpI-1});
end

%Compare each other
comparisons = combnk(2:length(CSpooledPVcorrsOne),2);
for compI = 1:size(comparisons,1)
    dayDiffsHere = unique([CSpooledPVdaysApart{comparisons(compI,1)}; CSpooledPVdaysApart{comparisons(compI,2)}]);
    for ddI = 1:length(dayDiffsHere)
        daysUseSig = CSpooledPVdaysApart{comparisons(compI,2)}==dayDiffsHere(ddI);
        daysUseNoise = CSpooledPVdaysApart{comparisons(compI,1)}==dayDiffsHere(ddI);

        [comp.dPrime{compI}(ddI),comp.pVal{compI}(ddI)] =...
            SensitivityIndexSL(CSpooledPVcorrsOne{comparisons(compI,2)}(daysUseSig),...
                               CSpooledPVcorrsOne{comparisons(compI,1)}(daysUseNoise),1000);
    end
    comp.dPrime{compI} = abs(comp.dPrime{compI});
end

if isempty(figHand)
    figHandOut = figure('Position',[680 305 968 673]);
else
    figHandOut = figHand;
end
plot([-0.5 maxDay+0.5],[0 0],'k'); hold on

pp = [];
for pvpI = 2:length(CSpooledPVcorrsOne)
    pp(pvpI-1) = plot(unique(CSpooledPVdaysApart{pvpI}),dPrime{pvpI-1},'Color',condSetColors{pvpI},...
        'LineWidth',2,'DisplayName',condSetLabels{pvpI});
end
legend(pp,'Location','northeast')

xlim([-0.5 maxDay+0.5]);
ylabel('Sensitivity Index')
xlabel('Day Lag')

statsOut.comp.comparisons = comparisons;
statsOut.reg.dPrime = dPrime;
statsOut.reg.pVal = pVal;
statsOut.comp.dPrime = comp.dPrime;
statsOut.comp.pVal = comp.pVal;

end