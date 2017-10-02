function [daysActive, maxConsecActive] = CellRegStats(fullReg_path)

load(fullfile(fullReg_path,'fullReg.mat'))

numCells = size(fullReg.sessionInds,1);
numDays = size(fullReg.sessionInds,2);

daysActive = sum(fullReg.sessionInds>0,2);

figure; histogram(daysActive,0.5:1:(numDays+0.5))
xlim([0.5 (numDays+0.5)])
title(['Total days a cell is found, ' num2str(numCells) ' cells'])
xlabel('Total days found')
ylabel('Number of cells')

allfiles = [fullReg.BaseSession; fullReg.RegSessions(:)];
filepts = cellfun(@(x) strsplit(x,'_'),allfiles,'UniformOutput',false);
dates = cell2mat(cellfun(@(x) str2double(x{2}(1:6)),filepts,'UniformOutput',false));
[~,howsort] = sort(dates);
%check = {allfiles(howsort)};
sortedSessionInds = fullReg.sessionInds(:,howsort);

for thCell = 1:numCells
    thisReg = sortedSessionInds(thCell,:);
    isActive = [0 thisReg>0 0];
    onoff = diff(isActive);
    starts = find(onoff==1);
    stops = find(onoff==-1);
    consecActive = stops' - starts';
    maxConsecActive(thCell) = max(consecActive);
end

figure; histogram(maxConsecActive,0.5:1:(numDays+0.5))
xlim([0.5 (numDays+0.5)])
title(['Max consecutive days a cell is found, ' num2str(numCells) ' cells'])
xlabel('Max consecutive days')
ylabel('Number of cells')

end