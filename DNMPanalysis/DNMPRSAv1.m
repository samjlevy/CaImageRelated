function [ trialTypeCorrs, thisCorrs ] = DNMPRSAv1( corrMat ) 
%Trial-by-trial correlations

rowColPairs = [ 1 1; 1 2; 1 3; 1 4; 
                     2 2; 2 3; 2 4; 
                          3 3; 3 4;
                               4 4];
                      
for pair = 1:size(rowColPairs,1)          
    thisCorrs{pair,1} = [];
    for row = trialBounds(rowColPairs(pair,1),1):trialBounds(rowColPairs(pair,1),2)
        for column = trialBounds(rowColPairs(pair,2),1):trialBounds(rowColPairs(pair,2),2)
            thisCorrs{pair,1} = [thisCorrs{pair,1}; corrMat(row, column)];
        end
    end 
    trialTypeCorrs{pair,1} = mean(thisCorrs{pair,1});
end    

end