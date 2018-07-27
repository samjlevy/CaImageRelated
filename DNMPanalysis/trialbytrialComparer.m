function trialbytrialComparer
disp('Note: this does NOT check every thing, just a few examples')

[file1, folder1] = uigetfile(cd,'Choose trialbytrial # 1')
[file2, folder2] = uigetfile(folder1,'Choose trialbytrial # 2')

tbtA = load(fullfile(folder1,file1));
tbtB = load(fullfile(folder2,file2));

%First check out sorted sessionInds
if size(tbtA.sortedSessionInds,1) ~= size(tbtB.sortedSessionInds,1)
    disp('Wrong number days in sortedSessionInds')
end

if size(tbtA.sortedSessionInds,2) ~= size(tbtB.sortedSessionInds,2)
    disp('Wrong number cells in sortedSessionInds')
end
 
%Then check out realdays
if mean(tbtA.realdays == tbtB.realdays)~=1
    disp('realdays is not the same')
end

%Check fields
ssa = fieldnames(tbtA.trialbytrial);
ssb = fieldnames(tbtB.trialbytrial);

%Are all of a in b?
AinB = ismember(ssb,ssa);
if mean(AinB)~=1
    disp('These fields not found in B: ')
    ssb(AinB==0)
end

BinA = ismember(ssa,ssb);
if mean(BinA)~=1
    disp('These fields not found in A: ')
    ssa(BinA==0)
end

allFields = [ssb;ssa];
isabsent = [AinB; BinA] == 0;
allFields(find(isabsent)) = [];
fieldsCheck = unique(allFields);    

fieldsCheck(strcmpi(fieldsCheck,'name')) = [];

%Look at size of fields in trial by trial
for condI = 1:length(tbtA.trialbytrial)
    for fieldI = 1:length(fieldsCheck)
        lengthsA(condI,fieldI) = length(tbtA.trialbytrial(condI).(fieldsCheck{fieldI}));
        lengthsB(condI,fieldI) = length(tbtB.trialbytrial(condI).(fieldsCheck{fieldI}));
    end    
end

for condJ = 1:length(tbtA.trialbytrial)
    if mean(lengthsA(condJ,:)./mean(lengthsA(condJ,:))) ~= 1
        disp('trialbytrial A is not internally consistent')
    end
    
    if mean(lengthsB(condJ,:)./mean(lengthsB(condJ,:))) ~= 1
        disp('trialbytrial B is not internally consistent')
    end
   
    if mean(mean(lengthsA == lengthsB)) ~= 1 
        disp('trialbytrial B and A are not the same length in their fields')
    end
end

for condK = 1:length(tbtA.trialbytrial)
    for fieldK = 1:length(fieldsCheck)
        if iscell(tbtA.trialbytrial(condK).(fieldsCheck{fieldK}))
            [nRowsA,nColsA] = cellfun(@size,tbtA.trialbytrial(condK).(fieldsCheck{fieldK}),'UniformOutput',false);
            [nRowsB,nColsB] = cellfun(@size,tbtB.trialbytrial(condK).(fieldsCheck{fieldK}),'UniformOutput',false);
            
            nRowsA = cell2mat(nRowsA); nRowsB = cell2mat(nRowsB);
            nColsA = cell2mat(nColsA); nColsB = cell2mat(nColsB);
            
            if mean(nRowsA == nRowsB) ~= 1
                disp(['for field ' fieldsCheck{fieldK} ', some row length in A and B not equal'])
                disp(['Entry ' num2str(find(nRowsA ~= nRowsB))])
            end
            
            if mean(nColsA == nColsB) ~= 1
                disp(['for field ' fieldsCheck{fieldK} ', some col length in A and B not equal'])
                disp(['Entry ' num2str(find(nColsA ~= nColsB))])
            end
        end
        
        if isnumeric(tbtA.trialbytrial(condK).(fieldsCheck{fieldK}))
            if mean(tbtA.trialbytrial(condK).(fieldsCheck{fieldK}) == tbtB.trialbytrial(condK).(fieldsCheck{fieldK})) ~= 1
                disp(['some data in field ' fieldsCheck{fieldK} ' is not equal'])
            end
        end
    end
end

%Check a few data in PSAbool
%numTrialsCheck = 3;
for condL = 1:length(tbtA.trialbytrial)
    %trialsCheck = randi(length(tbtA.trialbytrial(condL).trialPSAbool),numTrialsCheck,1)
    for trialL = 1:length(tbtA.trialbytrial(condL).trialPSAbool)
        if mean(sum(tbtA.trialbytrial(condL).trialPSAbool{trialL},2) == ...
                sum(tbtB.trialbytrial(condL).trialPSAbool{trialL},2) ) ~= 1
            disp(['PSA bool not the same cond ' num2str(condL) ', trial ' num2str(trialL)])
        end
    end
end

disp('Done comparing TBT A and B')

end


    

    