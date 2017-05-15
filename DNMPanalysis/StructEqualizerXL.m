function [inStruct] = StructEqualizerXL(inStruct)
%For now this takes a mega struct and runs struct equalizer on the
%sub-structs; would be nice to generalize it

%{
switch nargout~=nargin
    case 1
        disp('Nope, unequal nargouts and nargins')
        return
    case 0
        
if length(varargin)==1
    fields = fieldnames(varargin);
elseif length(varargin)~=1
    fields = fieldnames(varargin{1});
end
%}

fields = fieldnames(inStruct);
listStr = [];
for fieldNum = 1:length(fields)
    %{
    for fieldNum = 1:length(fields)
    fieldClass=[];
    eval(['fieldClass = class(varargin{1}.' fields{fieldNum} ');'])
    if strcmp(fieldClass,'struct')
        for 
    if strcmp(fieldClass,'cell') || strcmp(fieldClass,'double')
    %}
    listStr = [listStr, 'inStruct.' fields{fieldNum} '.stats, '];
    %could probably build this out with varargins, a check on whether
    %varargin{x} have sub-structs or not, then list each struct and
    %sub-struct
end
listStr = listStr(1:end-2);

%eval gross
eval([ '[' listStr '] = StructEqualizer(' listStr ');'])

end