function EditDailyTrialSheet(startPattern,numTrials)%,options,cellStarts,cellStops
%Assumes equal number of each type
%C:\Users\Sam\Documents\Lab\Plus Maze Within Day Trial Sheet 90.xlsx
[ff,dd] = uigetfile('*.xlsx');
refSheetLocation = fullfile(dd,ff);

switch numTrials
    case 60
        %cellStarts = {'D4','J4'};
        cellStarts = {'D3','J3'};
        startStarts = {'C3','I3'};
        cellStops = {'D33','J33'};
        trialsHere = [30; 30];
        nTrials = 60;
    case 90
        %cellStarts = {'D4','J4','P4'};
        cellStarts = {'D3','J3','P3'};
        startStarts = {'C3','I3','O3'};
        cellStops = {'D33','J33','P44'};
        trialsHere = [30; 30; 30];
        nTrials = 90;
    otherwise
        disp('Not built out for this number of trials')
        return
end

%{
nTrials = 0;
for csI = 1:length(cellStarts)
    trialsHere(csI) = stop - start +1;
    nTrials = nTrials + trialsHere(csI);
end
%}


options = {'n','e','s','w'};

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

for csJ = 1:length(cellStarts)
    indsHere = (1:trialsHere(csJ+1))+(csJ-1)*trialsHere(end);
    T = table(choiceCell(indsHere),'VariableNames',{'Start'});
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
for ssI = 1:length(startStarts)
    indsHere = (1:trialsHere(ssI+1))+(ssI-1)*trialsHere(end);
    T = table(startCell(indsHere),'VariableNames',{'End'});
    writetable(T,refSheetLocation,'Sheet',3,'Range',startStarts{ssI});
end

end