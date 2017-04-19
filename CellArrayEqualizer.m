function [varargout] = CellArrayEqualizer (varargin)
%Takes cell arrays, addes empty entries until they're all the same size.
%Assumes that {1,1} is the appropriate alignment point
if nargout ~= nargin
    disp('Sorry, need as many argouts as ins')
else
lengths = []; widths = [];
for cellArr = 1:length(varargin)
    lengths = [lengths  size(varargin{cellArr},1)];
    widths = [widths size(varargin{cellArr},2)];
end
maxLength = max(lengths);
maxWidth = max(widths);

switch class(varargin{1})
    case 'cell'

for cellArrIn = 1:length(varargin)
    %first fix length
    if maxLength~=size(varargin{cellArrIn},1)
    holder{cellArrIn} = [varargin{cellArrIn};...
        cell((maxLength-size(varargin{cellArrIn},1)), size(varargin{cellArrIn},2)) ];
    else
        holder{cellArrIn} = varargin{cellArrIn};   
    end
    %then fix width
    if maxWidth~=size(holder{cellArrIn},2)
    varargout{cellArrIn} = [holder{cellArrIn}...
        cell(size(holder{cellArrIn},1), (maxWidth-size(holder{cellArrIn},2))) ];
    else
         varargout{cellArrIn} = holder{cellArrIn};
    end
end

    case 'double'
        if any(any(isnan(varargin{1})))
            dubORnan = 'nan';
        else
            dubORnan = 'dub';
        end
        
        for cellDoubIn = 1:length(varargin)
            if maxLength~=size(varargin{cellDoubIn},1)
                insertSize(1) = maxLength - size(varargin{cellDoubIn},1);
                insertSize(2) = size(varargin{cellDoubIn},2);
                switch dubORnan
                    case 'nan'
                        insert = nan(insertSize(1), insertSize(2));
                    case 'dub'
                        insert = zeros(insertSize(1), insertSize(2));
                end
                holder = [varargin{cellDoubIn}; insert ];
            else
                holder = varargin{cellDoubIn};
            end    
            
            if maxWidth~=size(holder,2)
                chunkSize(1) = size(holder,1);
                chunkSize(2) = maxWidth - size(holder,2);
                switch dubORnan
                    case 'nan'
                        chunk = nan(chunkSize(1), chunkSize(2));
                    case 'dub'
                        chunk = zeros(chunkSize(1), chunkSize(2));
                end
                varargout{ cellDoubIn} = [holder chunk];
            else
                varargout{ cellDoubIn} = holder;
            end 
        end
end

end
