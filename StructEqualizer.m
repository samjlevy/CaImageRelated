function [varargout] = StructEqualizer(varargin)
%varargout = varargin;

switch nargout~=nargin
    case 1
        disp('Nope, unequal nargouts and nargins')
        return
    case 0
        
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
    %if strcmpi(fields{fieldNum},'epochs')
    [subvarargout{:}] = CellArrayEqualizer(subvarargin{:});
    
    for numOut = 1:nargin
        eval(['varargout{numOut}.' fields{fieldNum}...
            '=subvarargout{' num2str(numOut) '};'])
    end
    
    end
end

end

end