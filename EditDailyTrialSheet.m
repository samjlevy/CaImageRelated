function EditDailyTrialSheet(startPattern)%,options,cellStarts,cellStops
%Assumes equal number of each type
[ff,dd] = uigetfile('*.xlsx');
refSheetLocation = fullfile(dd,ff);


cellStarts = {'D4','J4'};
cellStops = {'D33','J33'};
%{
nTrials = 0;
for csI = 1:length(cellStarts)
    trialsHere(csI) = stop - start +1;
    nTrials = nTrials + trialsHere(csI);
end
%}
trialsHere = [30; 30];

options = {'n','e','s','w'};
nTrials = 60;
%refSheetLocation = 'C:\Users\Sam\Documents\Lab\Plus Maze Within Day Trial Sheet.xlsx';

sameConsecLimit = 3;

nOptions = length(options);
nEach = ceil(nTrials/nOptions);
allChoices = repmat(1:nOptions,nEach,1);
allChoices = allChoices(:);

consecOK = 0;
while consecOK==0
    choiceList = allChoices(randperm(length(allChoices)));
    
    consecsGood = false(1,nOptions);
    for opI = 1:nOptions
        thisOp = choiceList == opI;
        ons = find(diff([0; thisOp])==1);
        offs = find(diff([thisOp; 0])==-1);
        consecLengths = (offs-ons) + 1;
        consecsGood(opI) = any((consecLengths <= sameConsecLimit)==0)==0;
    end
    
    if any(consecsGood==0)
        consecOK = 0;
    else 
        consecOK = 1;
    end
end
choiceCell = options(choiceList); choiceCell = choiceCell(:);

trialsHere = [0; trialsHere];
cellStarts = {'D3','J3'};
for csJ = 1:length(cellStarts)
    indsHere = (1:trialsHere(csJ+1))+trialsHere(csJ);
    T = table(choiceCell(indsHere),'VariableNames',{'Start    '});
    writetable(T,refSheetLocation,'Sheet',3,'Range',cellStarts{csJ});
end

%Write pattern of start trials
switch startPattern
    case {'aaa','AAA'}
        startInds = ones(nTrials,1);
    case {'aba','ABA'}
        startInds = [ones(nTrials/3,1); 2*ones(nTrials/3,1); ones(nTrials/3,1)]; 
    case {'abc','ABC'}
        startInds = [ones(nTrials/3,1); 2*ones(nTrials/3,1); 3*ones(nTrials/3,1)];
end
startOrder = options(randperm(length(options)));
startCell = startOrder(startInds)';

startStarts = {'C3','I3'};
for ssI = 1:length(startStarts)
    indsHere = (1:trialsHere(ssI+1))+trialsHere(ssI);
    T = table(startCell(indsHere),'VariableNames',{'Ends    '});
    writetable(T,refSheetLocation,'Sheet',3,'Range',startStarts{ssI});
end

end