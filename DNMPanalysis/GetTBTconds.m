function [Conds] = GetTBTconds(trialbytrial)
%Really only needs trialbytrial.name, but let's keep it simple

names = {trialbytrial(:).name};

numUnderscores = sum( cell2mat(cellfun(@(x) any(strfind(x,'_')),names,'UniformOutput',false)) );
switch numUnderscores
    case 4
        Conds.Left = find(cell2mat(cellfun(@(x) any(strfind(x,'_l')),names,'UniformOutput',false)));
        Conds.Right = find(cell2mat(cellfun(@(x) any(strfind(x,'_r')),names,'UniformOutput',false)));
        Conds.Study = find(cell2mat(cellfun(@(x) any(strfind(x,'study')),names,'UniformOutput',false)));
        Conds.Test = find(cell2mat(cellfun(@(x) any(strfind(x,'test')),names,'UniformOutput',false)));
        
    case 0
        Conds.Left = find(cell2mat(cellfun(@(x) any(strfind(x,'Left')),names,'UniformOutput',false)));
        Conds.Right = find(cell2mat(cellfun(@(x) any(strfind(x,'Right')),names,'UniformOutput',false)));
        Conds.Study = find(cell2mat(cellfun(@(x) any(strfind(x,'Study')),names,'UniformOutput',false)));
        Conds.Test = find(cell2mat(cellfun(@(x) any(strfind(x,'Test')),names,'UniformOutput',false)));
    otherwise
        %disp('could not pull out conds, proceeding anyway')
        Conds = [];
end
end