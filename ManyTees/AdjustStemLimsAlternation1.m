%AdjustStemLimsAlternation1

load('Pos_brain.mat','xBrain','yBrain')
load('posAnchored.mat','posAnchorIdeal')
load('C:\Users\Sam\Desktop\TwoMazeAlternationData\stemLims.mat')

bTable = readtable('AlternationSheet_BrainTime.xlsx');

numEpochs = length(unique(bTable.MazeID));
for epochI = 1:numEpochs
    hh = figure; plot(posAnchorIdeal(:,1),posAnchorIdeal(:,2),'*')
    hold on
    
    lapsHere = find(bTable.MazeID==epochI);
    for lapI = 1:length(lapsHere)
        tLap = lapsHere(lapI);
        
        framesH = bTable.LapStart(tLap):bTable.ChoiceEnter(tLap);
        plot(xBrain(framesH),yBrain(framesH),'.m')
        plot(xBrain(framesH(1)),yBrain(framesH(1)),'.c')
        plot(xBrain(framesH(end)),yBrain(framesH(end)),'.c')
    end
    
    plot([-10 10],stemLims(1)*[1 1],'r')
    plot([-10 10],stemLims(2)*[1 1],'r')
    
    newStops=[];
    for lapI = 1:length(lapsHere)
        tLap = lapsHere(lapI);
        
        framesCheck = bTable.LapStart(tLap):bTable.RewardStart(tLap);
        newStops(lapI) = framesCheck(find(yBrain(framesCheck) > stemLims(2),1,'first'));
    end
    
    bTable.ChoiceEnter(lapsHere) = newStops;
end


cc = table2cell(bTable);
cc = [bTable.Properties.VariableNames; cc];

xlswrite('AlternationSheet_BrainTime_Adjusted.xlsx',cc);

