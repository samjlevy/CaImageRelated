function [varargin] = GenerateFigsAndHandles(numFigs, indivORsubplot)
%If you want separate figures, set indivORsubplot to 'indiv'
%If you want the figures in a subplot, set it to 'subplot'
%varargin is the names for handles; should be 1 for subplot, or equal in
%length to numfigs for individual plots

%Needs testing
for NF = 1:numFigs
    switch indivORsubplot
        case 'indiv'
            varargin{NF} = figure;
            axes(varargin{NF});
            
        case 'subplot'
            if NF==1
                varargin{1} = figure;
            
                numCols = ceil(sqrt(numFigs));
                numRows = floor(sqrt(numFigs));

                if numCols + numRows < numFigs
                    if ((numCols+1) * numRows) > ((numRows+1) * numCols)
                        numCols = numCols + 1;
                    else 
                        numRows = numRows + 1;
                    end
                end
            end
            varargin{1}(NF).pl = subplot(numRows,numCols,NF);
            varargin{1}(NF).ax = axes(varargin{1}(NF).pl;
            
    end
end
                