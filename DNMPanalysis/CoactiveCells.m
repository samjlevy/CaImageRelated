function [CaCs] = CoactiveCells(trialbytrial)
%Find coactive cell assemblies, described as likelihood of being active at 
%the same time, with two methods:
%   - strict: has to be in the same frame
%   - chill: has to be active in the same lap
%
%Future version might ask if there are cells that are active in some condition
%but are never active together (suppression)
%Would be useful to get some kind of baseline likelihood of being coactive
%at all, or coactive given how often active at all

sessions = unique(trialbytrial(1).sessID);
numSess = length(sessions);
numCells = length(trialbytrial(1).trialPSAbool{1,1});
numConds = length(trialbytrial);

%Row is cell of interest, column is partner num, how many times active
%together
%chillCoactive = zeros(numCells, numCells);
%chillLapsActive = zeros(numCells, 1);
%strictCoactive = zeros(numCells, numCells);
%strictFramesActive = zeros(numCells, 1);

for dayI = 1:numSess
    for condI = 1:numConds
        chillCoactive{dayI,condI} = zeros(numCells, numCells);
        chillLapsActive{dayI,condI} = zeros(numCells, 1);
        strictCoactive{dayI,condI} = zeros(numCells, numCells);
        strictFramesActive{dayI,condI} = zeros(numCells, 1);

        lapsUse = find(logical(trialbytrial(condI).sessID == sessions(dayI)));
        for lapI = 1:length(lapsUse)
            tLap = lapsUse(lapI);
            tPB = trialbytrial(condI).trialPSAbool{tLap};
             
            %Chill
            lapCoactive = find(sum(tPB,2));
            for lcI = 1:length(lapCoactive)
                notthis = lapCoactive(lapCoactive~=lapCoactive(lcI));
                chillCoactive{dayI,condI}(lapCoactive(lcI),notthis) = ...
                   chillCoactive{dayI,condI}(lapCoactive(lcI),notthis) + 1;
                chillLapsActive{dayI,condI}(lapCoactive(lcI)) =...
                    chillLapsActive{dayI,condI}(lapCoactive(lcI))+1;
            end

             
            %Strict
            for frameI = 1:size(tPB,2)
                frameCoactive = find(tPB(:,frameI));
                for fcI = 1:length(frameCoactive)
                    notthis = frameCoactive(frameCoactive~=frameCoactive(fcI));
                    strictCoactive{dayI,condI}(frameCoactive(fcI),notthis) = ...
                       strictCoactive{dayI,condI}(frameCoactive(fcI),notthis) + 1;
                    strictFramesActive{dayI,condI}(frameCoactive(fcI)) = ...
                        strictFramesActive{dayI,condI}(frameCoactive(fcI))+1;
                end   
            end
            
             
        end
        
        CaCs.chillRate{dayI,condI} = zeros(numCells, numCells);
        CaCs.strictRate{dayI,condI} = zeros(numCells, numCells);
        for cellI = 1:numCells
            CaCs.chillRate{dayI,condI}(cellI,:) =...
                chillCoactive{dayI,condI}(cellI,:)/chillLapsActive{dayI,condI}(cellI);
            CaCs.strictRate{dayI,condI}(cellI,:) =...
                strictCoactive{dayI,condI}(cellI,:)/strictFramesActive{dayI,condI}(cellI);
        end
    end 
    dayI
end

CaCs.chillCoactive = chillCoactive; 
CaCs.chillLapsActive = chillLapsActive; 
CaCs.strictCoactive = strictCoactive;
CaCs.strictFramesActive = strictFramesActive; 
%{
for dayI = 1:numSess
    for condI = 1:numConds
        for cellI = 1:numCells
        CaCs.chillRate{dayI,condI}(cellI,:) =...
            CaCs.chillCoactive{dayI,condI}(cellI,:)/CaCs.chillLapsActive{dayI,condI}(cellI);
        CaCs.strictRate{dayI,condI}(cellI,:) =...
            CaCs.strictCoactive{dayI,condI}(cellI,:)/CaCs.strictFramesActive{dayI,condI}(cellI);
        end
    end
end
%}

%U = triu(CaCs2.chillRate{5,4});
%L = tril(CaCs2.chillRate{5,4});
%Uprime = U';
%figure; histogram(Uprime(L>0.25 & Uprime>0.25),[0.05:0.05:1.05])
%sum(Uprime(L>0.25 & Uprime>0.25)>0)
%How to get from pairs to groups?
end