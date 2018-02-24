%Spatial information and z-scored firing rates
SpatialInformationSL(RunOccMap,TCounts)
 %meanRate = mean(allRates(:));
        %informationContent = sum(allOccMap.*(allRates(:)/meanRate).*log2(allRates(:)/meanRate))
       
        %Spatial information (Will's version)
        allOccMap = [RunOccMap{:,tSess}]';
        P_x = allOccMap/sum(allOccMap); %P_xi: probability mouse is in pixel xi
         allCounts = [TCounts{cellI,:,tSess}]';
        P_k1 = sum(allCounts)/sum(allOccMap); %Probability of spiking
        P_k0 = 1 - P_k1;                      %Probability of not spiking
        
        P_1x = allRates(:);                   %Probability of spike given location
        P_0x = 1 - P_1x;                      %Probability of ~spike given location
        
        I_k1 = P_1x.*log(P_1x./P_k1);         %positional information for k=1
        I_k0 = P_0x.*log(P_0x./P_k0);         %positional information for k=0
        
        Ipos = I_k1 + I_k0;                   % True positional information
        Ipos = nansum([I_k1 I_k0],2)
        
        MI = nansum(P_x.*Ipos); %Needs to be compared to distribution of MI for pos/spike shuffled
        
        %Sparsity: sum(Pi*Ri^2)/R^2 R is mean firing rate (Markus 1994)
            %should be 0.1 cell fires on 10% on maze surface
        sparsity = 1 / nansum( (P_x.*(P_1x.^2)) / (mean(P_1x)^2) );
        
        %Selectivity: ratio of max signal to noise: firing rate of cell in
        %bin with max average rate / mean firing rate across maze
        