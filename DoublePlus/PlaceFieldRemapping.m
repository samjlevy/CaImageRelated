function [outputs] = PlaceFieldRemapping(tmap,tmapAboveThresh,dayPairs)
% Categories: from day(x,1) to day(x,2)
%{
Is this field:
- same bins above threshold?
otherwise:
    - get fields in day(x,2) that overlap
    - how much bigger/smaller is that field
    - what is the pct overlap
    - which way is it shifted, how much
%}

numCells = size(tmap,1);
numSess = size(tmap,2);
numConds = size(tmap,3);
numDayPairs = size(dayPairs,1);
nBins = length(tmap{1,1,1});

anyActivity = cellfun(@any,tmapAboveThresh);
for condI = 1:numConds
    for dpI = 1:numDayPairs
        dayA = dayPairs(dpI,1);
        dayB = dayPairs(dpI,2);
        for cellI = 1:numCells
            if anyActivity(cellI,dayA,condI) && anyActivity(cellI,dayB,condI)
                tBinsA = tmapAboveThresh{cellI,dayA,condI};
                tBinsB = tmapAboveThresh{cellI,dayB,condI};
                tmapA = tmap{cellI,dayA,condI};
                tmapB = tmap{cellI,dayB,condI};
                %[tmap{cellI,dayA,condI} tmap{cellI,dayB,condI} tmapAboveThresh{cellI,dayA,condI} tmapAboveThresh{cellI,dayB,condI}]
                % Get linearized field starts and stops
                afOns = find(diff([0; tBinsA])==1);
                afOffs = find(diff([tBinsA; 0])==-1);
                if length(afOns)~=length(afOffs); keyboard; end
                bfOns = find(diff([0; tBinsB])==1);
                bfOffs = find(diff([tBinsB; 0])==-1);
                if length(bfOns)~=length(bfOffs); keyboard; end
                
                % Are there the same number of fields?
                nFieldsA = length(afOns);
                nFieldsB = length(bfOns);
                changeNumFields(cellI,dpI,condI) = nFieldsB - nFieldsA;
                
                % Is there the same area above threshold?
                changeTotalArea(cellI,dpI,condI) = sum(tBinsB) - sum(tBinsA);
                
                fieldIDa = double(tBinsA);
                for afI = 1:nFieldsA
                    fieldIDa(afOns(afI):afOffs(afI)) = afI;
                end
                
                fieldIDb = double(tBinsB);
                for bfI = 1:nFieldsB
                    fieldIDb(bfOns(bfI):bfOffs(bfI)) = bfI;
                end
                
                AinB = []; BinA = [];
                for fieldI = 1:nFieldsA
                    fieldA = afOns(fieldI):afOffs(fieldI);
                    fib = fieldIDb(fieldA);
                    AinB(fieldI,:) = sum(fib(:)==1:nFieldsB,1)>0;
                end
                BinA = AinB';
                
                aboveThreshOverlaps{cellI,dpI,condI} = sum(AinB,2)>0; 
                fieldShifts{cellI,dpI,condI} = sum(AinB,2)==1;
                fieldSplits{cellI,dpI,condI} = sum(AinB,2)>1;
                BgainsMany = sum(BinA,2)>1;
                BgainsAinds = repmat(BgainsMany(:)',nFieldsA,1);
                fieldMerges{cellI,dpI,condI} = sum(AinB & BgainsAinds,2)>0;
                    
                overlapsAtAll{cellI,dpI,condI} = sum(tBinsA & tBinsA)>0;
                    
                % Overlapped fields details
                comShift{cellI,dpI,condI} = zeros(nFieldsA,1);
                rateDiff{cellI,dpI,condI} = zeros(nFieldsA,1);
                sizeDiff{cellI,dpI,condI} = zeros(nFieldsA,1);
                for fieldI = 1:nFieldsA
                    fieldA = afOns(fieldI):afOffs(fieldI);
                    
                    % Pct overlapped
                    pctOl = sum(tBinsB(fieldA)) / length(fieldA);
                    pctOverlap{cellI,dpI,condI}(fieldI,1) = pctOl;
                    %binsBoth = tBinsA & tBinsB;
                    
                    fieldsBol = unique(fieldIDb(fieldA));
                    fieldsBol(fieldsBol==0) = [];
                    if any(fieldsBol)
                        aField = zeros(nBins,1);
                        aField(fieldA) = tmapA(fieldA);
                        bField = zeros(nBins,1);
                        for fbI = 1:length(fieldsBol)
                            fieldB = bfOns(fieldsBol(fbI)):bfOffs(fieldsBol(fbI));
                            bField(fieldB) = tmapB(fieldB);
                        end

                        if length(fieldsBol)==1
                            comA = FiringCOM(aField);
                            comB = FiringCOM(bField);
                            %{
                                figure; plot(aField,'b'); hold on; plot(bField,'r')
                                plot(comA*[1 1],[0 0.25],'b'); plot(comB*[1 1],[0 0.25],'r')
                            %}
                            comShift{cellI,dpI,condI}(fieldI,1) = comB - comA;
                            rateDiff{cellI,dpI,condI}(fieldI,1) = max(aField) - max(bField);
                            sizeDiff{cellI,dpI,condI}(fieldI,1) = length(fieldB) - length(fieldA);
                        elseif length(fieldsBol)>1
                            % Field has split!
                            % do nothing?
                            % disp('beep')
                            % keyboard
                        else
                            % Error
                            disp('boop')
                            keyboard

                        end
                    
                    else
                        
                    end
                    
                end   
                
                % This should agree with comShift
                %fieldShifts{cellI,dpI,condI}
                
            end
        end
    end
end

outputs = table2struct(table(aboveThreshOverlaps,fieldShifts,fieldSplits,fieldMerges,comShift,rateDiff,sizeDiff));
%{
aboveThreshOverlaps = aboveThreshOverlaps;
fieldShifts = fieldShifts;
fieldSplits = fieldSplits
fieldMerges = fieldMerges
comShift = comShift
rateDiff = rateDiff
sizeDiff = sizeDiff
%}
end