sessI = 1;
lapsH = find(trialbytrial(1).sessID==sessI)
florHereA = [trialbytrial(1).trialRawTrace{lapsH}];
lapsH = find(trialbytrial(2).sessID==sessI)
florHereB = [trialbytrial(2).trialRawTrace{lapsH}];
af = [florHereA, florHereB];
mins = min(af,[],2);
afNorm = af-mins;
maxes = max(afNorm,[],2);
afNorm = afNorm ./ maxes;

condI = 1;
lapsH = find(trialbytrial(condI).sessID==sessI);
for lapJ = 1:length(lapsH); 
    lapI = lapsH(lapJ); 
    normT{condI}{lapI,1} = trialbytrial(condI).trialRawTrace{lapI}-mins; 
    normT{condI}{lapI,1} = normT{condI}{lapI,1}./maxes; 
end
condI = 2;
lapsH = find(trialbytrial(condI).sessID==sessI);
for lapJ = 1:length(lapsH); 
    lapI = lapsH(lapJ); 
    normT{condI}{lapI,1} = trialbytrial(condI).trialRawTrace{lapI}-mins; 
    normT{condI}{lapI,1} = normT{condI}{lapI,1}./maxes; 
end
florHereA = [normT{1}{:}];
florHereB = [normT{2}{:}];
florHere = [florHereA, florHereB];

cellsHere = sortedSessionInds(:,1)>0;
florHere = florHere(cellsHere,:);

aInds = 1:size(florHereA,2);

D = L2_distance(florHere, florHere, 1);
options.dims = 1:10;
[Y, R, E] = Isomap(D, 'k', 7, options);
figure; plot(Y.coords{2}(1,:), Y.coords{2}(2,:),'.r')
figure; plot3(Y.coords{3}(1,:), Y.coords{3}(2,:),Y.coords{3}(3,:),'.r')

condI = 1;
lapsH = find(trialbytrial(condI).sessID==sessI);
tLengthsA = cellfun(@length,[trialbytrial(condI).trialsX(lapsH)]);
aa = cumsum(tLengthsA);
lapStartsA = [0;aa(1:end-1)]+1;
lapStopsA = lapStartsA+tLengthsA-1;

condI = 2;
lapsH = find(trialbytrial(condI).sessID==sessI);
tLengthsB = cellfun(@length,[trialbytrial(condI).trialsX(lapsH)]);
bb = cumsum(tLengthsB);
lapStartsB = [0;bb(1:end-1)]+1;
lapStopsB = lapStartsB+tLengthsB-1;