function [varargout] = VarargModHandler(varargin)
%[varagout] = VarargoutModHandler(varargin)
%Inputs are pairs of variable identities and their values, 
%similar to ...'Linewidth',2)... in the plot function
%  
% INPUTS - Must come in pairs, name as a string in quotes and value immediately after
%           Must also have input names in quotes (or string assignments?)
%
% OUTPUTS - Ordered identities of values, same order as inputs

assert(mod(length(varargin),2)==0,'Unpaired input arguments')
assert(nargin/2==nargout,'Unequal inputs and output assignments')
for a=1:length(varargin)/2
    varargin{2*a-1}=varargin{2*a};
    varargout{a}=varargin{2*a-1}; %preallocation?
end  

end