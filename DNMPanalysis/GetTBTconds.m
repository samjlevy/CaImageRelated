function [Conds] = GetTBTconds(trialbytrial)
%Really only needs trialbytrial.name, but let's keep it simple

names = {trialbytrial(:).name};

Conds.Study = find(cell2mat(cellfun(@(x) any(strfind(x,'study')),names,'UniformOutput',false)));
Conds.Test = find(cell2mat(cellfun(@(x) any(strfind(x,'test')),names,'UniformOutput',false)));
Conds.Left = find(cell2mat(cellfun(@(x) any(strfind(x,'_l')),names,'UniformOutput',false)));
Conds.Right = find(cell2mat(cellfun(@(x) any(strfind(x,'_r')),names,'UniformOutput',false)));

end