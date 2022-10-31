function [temporalCorrsR, temporalCorrsP, cellPairsUsed] = MakeTemporalCorrs1(trialbytrial,condsHere,traitLogical)

nDays = max(trialbytrial(1).sessID);


for sessI = 1:nDays
        psaHere = [];
        florHere = [];
        for condI = 1:numel(condsHere)
            trialsH = trialbytrial(condsHere(condI)).sessID == sessI;
            if any(trialsH)
                psaHere = [psaHere, trialbytrial(condsHere(condI)).trialPSAbool{trialsH}];
                florHere = [florHere, trialbytrial(condsHere(condI)).trialDFDTtrace{trialsH}];
                %pp = [trialbytrial(condsHere(condI)).trialPSAbool{trialsH}];
                %ff = [trialbytrial(condsHere(condI)).trialDFDTtrace{trialsH}];
            end
        end
        
        cellsActive = sum(traitLogical(:,sessI,condsHere),3)>0;
        
        cellPairsHere = nchoosek(find(cellsActive),2);
        
        if any(any(psaHere))
            
            numCellPairs = size(cellPairsHere,1);
            
            rr = nan(size(cellPairsHere,1),1);
            pp = nan(size(cellPairsHere,1),1);
            for cpI = 1:size(cellPairsHere,1)
                [rr(cpI,1),pp(cpI,1)] = corr(psaHere(cellPairsHere(cpI,1),:)',psaHere(cellPairsHere(cpI,2),:)','type','Pearson');
            end
            
            cellPairsUsed{sessI} = cellPairsHere;
        
            temporalCorrsR{sessI} = rr;
            temporalCorrsP{sessI} = pp;
        
            %laggedCorrs = nan(size(cellPairsHere,1),maxLag*2+1);
            %laggedPvals = nan(size(cellPairsHere,1),maxLag*2+1);

            %{
            lagsCheck = -maxLag:1:maxLag;
            tic
            for lagI = 1:maxLag
                zeroBlock = zeros(numCells(mouseI),lagI);
                falseBlock = false(numCells(mouseI),lagI);
                demoBlock = zeros(1,lagI);

                laggedPSA = [];
                laggedFlor = [];
                laggedDemo = [];
                for condI = 1:numel(condsHere)
                    trialsH = trialbytrial(condsHere(condI)).sessID == sessI;


                    if any(trialsH)
                        trialsHinds = find(trialsH);

                        zeroCells = cell(numel(trialsHinds),1);
                        [zeroCells{:}] = deal(falseBlock);
                        psaTrialsCell = trialbytrial(condsHere(condI)).trialPSAbool(trialsH);
                        psaTrialsWithZerosCell = cell(numel(zeroCells)+numel(psaTrialsCell),1);
                        [psaTrialsWithZerosCell{1:2:2*numel(zeroCells)-1,1}] = deal(zeroCells{:});
                        [psaTrialsWithZerosCell{2:2:2*numel(psaTrialsCell),1}] = deal(psaTrialsCell{:});
                        psaTrialsWithZerosCell = psaTrialsWithZerosCell';
                        laggedPSA = [laggedPSA, cell2mat(psaTrialsWithZerosCell)];

                        zeroCells = cell(numel(trialsHinds),1);
                        [zeroCells{:}] = deal(zeroBlock);
                        florTrialsCell = trialbytrial(condsHere(condI)).trialDFDTtrace(trialsH);
                        florTrialsWithZerosCell = cell(numel(zeroCells)+numel(florTrialsCell),1);
                        [florTrialsWithZerosCell{1:2:2*numel(zeroCells),1}] = deal(zeroCells{:});
                        [florTrialsWithZerosCell{2:2:2*numel(florTrialsCell),1}] = deal(florTrialsCell{:});
                        florTrialsWithZerosCell = florTrialsWithZerosCell';
                        laggedFlor = [laggedFlor, cell2mat(florTrialsWithZerosCell)];

                        zeroCells = cell(numel(trialsHinds),1);
                        [zeroCells{:}] = deal(demoBlock);
                        trialLengths = cellfun(@(x) size(x,2),trialbytrial(condsHere(condI)).trialPSAbool(trialsH),'UniformOutput',false);
                        demoTrials = cellfun(@(x) ones(1,x),trialLengths,'UniformOutput',false);
                        demoTrialsCell = cell(numel(zeroCells)+numel(psaTrialsCell),1);
                        [demoTrialsCell{1:2:2*numel(zeroCells)-1,1}] = deal(zeroCells{:});
                        [demoTrialsCell{2:2:2*numel(psaTrialsCell),1}] = deal(demoTrials{:});
                        demoTrialsCell = demoTrialsCell';
                        laggedDemo = [laggedDemo, cell2mat(demoTrialsCell)];
                    end
                end

                laggedPSA = [laggedPSA, falseBlock]; %laggedPSA = logical(laggedPSA);
                laggedFlor = [laggedFlor, zeroBlock];
                laggedDemo = [laggedDemo, demoBlock];

                % Need to run this twice, once to trim the lag off of end
                % cpI,1/beginning of cpI,2, and alternate
                demoA = laggedDemo(1:end-lagI);
                demoB = laggedDemo(lagI+1:end);
                for cpI = 1:size(cellPairsHere,1)
                    datA = laggedPSA(cellPairsHere(cpI,1),:)';
                    datB = laggedPSA(cellPairsHere(cpI,2),:)';

                    datA(1:end-lagI);
                    datB(lagI+1:end);
                    lagColPos = maxLag+1+lagI;
                    lagColNeg = maxLag+1-lagI;
                    [laggedCorrs(cpI,lagColPos),laggedPvals(cpI,lagColPos)] = corr( datA(lagI+1:end), datB(1:end-lagI),'type','Pearson');
                    [laggedCorrs(cpI,lagColNeg),laggedPvals(cpI,lagColNeg)] = corr( datA(1:end-lagI), datB(lagI+1:end),'type','Pearson');
                end
 
            end
                
            %}
        end
        
        %{
        laggedCorrs(:,maxLag+1) = rr;
            laggedPval(:,maxLag+1) = pp;
            save('mouse1sess1crossCorrs.mat','laggedCorrs','laggedPvals','lagsCheck','cellPairsHere')
            
        %}
    
        %crossCorrs{mouseI}{sessI} = laggedCorrs;
        
        %crossCorrPvals{mouseI}{sessI} = laggedPvals;
        
        
        disp(['Done sess ' num2str(sessI)])
end

end