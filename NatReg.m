kerberosBase = 'Kerberos_180420';

kerberosFolder = 'F:\DoublePlus\Kerberos';
cd(kerberosFolder)

off = ls;
off([1 2],:) = [];
otherFolders = cell(size(off,1),1);
for ii = 1:size(off,1)
    otherFolders{ii,1} = off(ii,:);
    bbi(ii) = strcmpi(kerberosBase,otherFolders{ii,1});
end

baseInd = find(bbi);
dateCon = @(sixDate)  [sixDate(3:4) '_' sixDate(5:6) '_20' sixDate(1:2)];

numSess = size(otherFolders,1);
for ii = 1:numSess
Dates{ii,1} = dateCon(otherFolders{ii}(end-5:end));
end
Animals = cell(numSess,1);
[Animals{:}] = deal('Kerberos');
Sessions = ones(numSess,1);
Envs = cell(numSess,1);
[Envs{:}] = deal('PlusMazes');
for ii = 1:numSess
    Locations{ii,1} = fullfile(kerberosFolder,otherFolders{ii});
end

%mdTable = table(Animals,Dates,Envs,Locations,'VarNames',{'Animal','Date','Env','Location'});
for ii = 1:numSess
    MD(ii).Animal = Animals{ii};
    MD(ii).Date = Dates{ii};
    MD(ii).Session = Sessions(ii);
    MD(ii).Env = Envs{ii};
    MD(ii).Location = Locations{ii};
end

save(fullfile(kerberosFolder,'KerberosMD.mat'),'MD')

tic
[ batch_session_map ] = neuron_reg_batch(MD(baseInd), MD([1:(baseInd-1) (baseInd+1):end]), 'use_neuron_masks',1);
toc