
    splittersLR{mouseI} = (LRthisCellSplits{mouseI} + dayUse{mouseI}) ==2;
    splittersST{mouseI} = (STthisCellSplits{mouseI} + dayUse{mouseI}) ==2;
     %{
    splittersLR{mouseI} = LRthisCellSplits{mouseI};% + dayUse{mouseI}) ==2;
    splittersST{mouseI} = STthisCellSplits{mouseI};% + dayUse{mouseI}) ==2;
   
    splittersLR{mouseI} = (LRthisCellSplits{mouseI} + sum(trialReli{mouseI},3)>0) ==2;
    splittersST{mouseI} = (STthisCellSplits{mouseI} + sum(trialReli{mouseI},3)>0) ==2;
     %}
    splittersANY{mouseI} = (splittersLR{mouseI} + splittersST{mouseI}) > 0;
    [splittersLRonly{mouseI}, splittersSTonly{mouseI}, splittersBOTH{mouseI},...
        splittersOne{mouseI}, splittersNone{mouseI}] = ...
        GetSplittingTypes(splittersLR{mouseI}, splittersST{mouseI}, dayUse{mouseI});
    %splittersOne{mouseI} = splittersOne{mouseI}.*dayUse{mouseI};
    nonLRsplitters{mouseI} = ((LRthisCellSplits{mouseI} == 0) + dayUse{mouseI}) ==2;
    nonSTsplitters{mouseI} = ((STthisCellSplits{mouseI} == 0) + dayUse{mouseI}) ==2;
    
    %Sanity check: Should work out that LRonly + STonly + Both + none = total active
        %And LR only + STonly = one
    cellsActiveToday{mouseI} = sum(dayUse{mouseI},1);
    splitterProps{mouseI} = [sum(splittersNone{mouseI},1)./cellsActiveToday{mouseI};... %None
                             sum(splittersLRonly{mouseI},1)./cellsActiveToday{mouseI};... %LR only
                             sum(splittersSTonly{mouseI},1)./cellsActiveToday{mouseI};... %ST only
                             sum(splittersBOTH{mouseI},1)./cellsActiveToday{mouseI}]; %Both only
                         
    splittersEXany{mouseI} = (splittersLRonly{mouseI} + splittersSTonly{mouseI}) > 0;
%end

purp = [0.4902    0.1804    0.5608]; % uisetcolor
orng = [0.8510    0.3294    0.1020];
colorAssc = {'r'            'b'        'm'         'c'              purp     orng    'g'      'k'  };
colorAssc = { [1 0 0]     [0 0 1]    [1 0 1]       [0 1 1]         purp     orng        [0 1 0]       [0 0 0]};
traitLabels = {'splitLR' 'splitST'  'splitLRonly' 'splitSTonly' 'splitBOTH' 'splitONE' 'splitEITHER' 'dontSplit'};

for mouseI = 1:numMice
    traitGroups{1}{mouseI} = {splittersLR{mouseI};... 
                           splittersST{mouseI};... 
                           splittersLRonly{mouseI};... 
                           splittersSTonly{mouseI}; ...
                           splittersBOTH{mouseI}; ...
                           splittersOne{mouseI};... 
                           splittersANY{mouseI}; ...
                           splittersNone{mouseI}};
                   
    traitGroupsREV{1}{mouseI} = cellfun(@fliplr,traitGroups{1}{mouseI},'UniformOutput',false);
    
end
numTraitGroups = length(traitGroups{1}{1});

dayUseREV = cellfun(@fliplr,dayUse,'UniformOutput',false);

sessionsIndREV = cellfun(@(x) fliplr(1:length(x)),cellRealDays,'UniformOutput',false);

disp('done splitter logicals')

pairsCompare = {'splitLR' 'splitST';...
                'splitLRonly' 'splitSTonly';...
                'splitBOTH' 'splitONE';...
                'splitEITHER' 'dontSplit'};
pairsCompareInd = cell2mat(cellfun(@(x) find(strcmpi(traitLabels,x)),pairsCompare,'UniformOutput',false));
numPairsCompare = size(pairsCompare,1);

%% ARM Splitter cells: stats and logical breakdown
%Get logical splitting type
for mouseI = 1:numMice
    ARMsplittersLR{mouseI} = (LRthisCellSplitsARM{mouseI} + dayUseArm{mouseI}) ==2;
    ARMsplittersST{mouseI} = (STthisCellSplitsARM{mouseI} + dayUseArm{mouseI}) ==2;
    ARMsplittersANY{mouseI} = (ARMsplittersLR{mouseI} + ARMsplittersST{mouseI}) > 0;
    [ARMsplittersLRonly{mouseI}, ARMsplittersSTonly{mouseI}, ARMsplittersBOTH{mouseI},...
        ARMsplittersOne{mouseI}, ARMsplittersNone{mouseI}] = ...
        GetSplittingTypes(ARMsplittersLR{mouseI}, ARMsplittersST{mouseI}, dayUseArm{mouseI});
    %ARMsplittersOne{mouseI} = ARMsplittersOne{mouseI}.*dayUse{mouseI};
    ARMnonLRsplitters{mouseI} = ((LRthisCellSplitsARM{mouseI} == 0) + dayUseArm{mouseI}) ==2;
    ARMnonSTsplitters{mouseI} = ((STthisCellSplitsARM{mouseI} == 0) + dayUseArm{mouseI}) ==2;
    
    %Sanity check: Should work out that LRonly + STonly + Both + none = total active
        %And LR only + STonly = one
    cellsActiveTodayArm{mouseI} = sum(dayUseArm{mouseI},1);
    ARMsplitterProps{mouseI} = [sum(ARMsplittersNone{mouseI},1)./cellsActiveTodayArm{mouseI};... %None
                             sum(ARMsplittersLRonly{mouseI},1)./cellsActiveTodayArm{mouseI};... %LR only
                             sum(ARMsplittersSTonly{mouseI},1)./cellsActiveTodayArm{mouseI};... %ST only
                             sum(ARMsplittersBOTH{mouseI},1)./cellsActiveTodayArm{mouseI}]; %Both only
                         
    ARMsplittersEXany{mouseI} = (ARMsplittersLRonly{mouseI} + ARMsplittersSTonly{mouseI}) > 0;
end

ARMcolorAssc = { [1 0 0]     [0 0 1]    [1 0 1]       [0 1 1]         purp     orng        [0 1 0]       [0 0 0]};
ARMtraitLabels = {'ARMsplitLR' 'ARMsplitST'  'ARMsplitLRonly' 'ARMsplitSTonly' 'ARMsplitBOTH' 'ARMsplitONE' 'ARMsplitEITHER' 'ARMdontSplit'};

for mouseI = 1:numMice
    traitGroups{2}{mouseI} = {ARMsplittersLR{mouseI}; ARMsplittersST{mouseI};... 
                           ARMsplittersLRonly{mouseI}; ARMsplittersSTonly{mouseI}; ...
                           ARMsplittersBOTH{mouseI}; ...
                           ARMsplittersOne{mouseI};... 
                           ARMsplittersANY{mouseI}; ...
                           ARMsplittersNone{mouseI}};
                   
    traitGroupsREV{2}{mouseI} = cellfun(@fliplr,traitGroups{2}{mouseI},'UniformOutput',false);
    
end

disp('done ARM splitter logicals')

%%