function [varargout] = StructEqualizer(varargin)
%varargout = varargin;

fields = fieldnames(varargin{1});

for fieldNum = 1:length(fields)
    fieldClass=[];
    eval(['fieldClass = class(varargin{1}.' fields{fieldNum} ');'])
    if strcmp(fieldClass,'cell') || strcmp(fieldClass,'double')
    
    subvarargin=[];
    subvarargout=[];
    
    for numIn = 1:length(varargin)
        eval(['subvarargin{' num2str(numIn) '}'...
            '=varargin{numIn}.' fields{fieldNum} ';'])
    end
    subvarargout = subvarargin;
    
    [subvarargout{:}] = CellArrayEqualizer(subvarargin{:});
    
    for numOut = 1:nargin
        eval(['varargout{numOut}.' fields{fieldNum}...
            '=subvarargout{' num2str(numOut) '};'])
    end
    
    end
end

end