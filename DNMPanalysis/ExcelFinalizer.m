function ExcelFinalizer(inputPath)
%   ExcelFinalizer(cd)
%This function arranges the excel spreadsheet for ease of management in
%later functions. Also deletes some bad indices. Will find highest-numbered
%braintime_adjusted file and use that.

if ~exist('inputPath','var')
    inputPath = cd;
end

load('Pos_align.mat','x_adj_cm')
dirls_file = dir(fullfile(inputPath,'*.xlsx'));
bitt = 'BrainTime_AllAdjusted';

startAt = cellfun(@(x) strfind(x,bitt),{dirls_file(:).name},'UniformOutput',false);%

foundFile = ~cellfun(@isempty,startAt);
if sum(foundFile)==0
    disp('Did not find the AllAdjusted file, running')
    DNMPexcelCombiner(inputPath)
    %return
else

rankF = zeros(length(dirls_file),1);
for df = 1:length(dirls_file)
    if any(startAt{df})
        fn = dirls_file(df).name(1:end-5);
        if length(fn) >= (startAt{df} + length(bitt)+1)
            rankF(df) = str2double(fn(startAt{df}+length(bitt)+1));
        elseif length(fn) == (startAt{df} + length(bitt)-1)
            rankF(df) = 1;
        end
    end
end

[~,i] = max(rankF);
xls_use = dirls_file(i).name;
[frames, txt] = xlsread(fullfile(inputPath,xls_use), 1);

okTypes = {'Start on maze (start of Forced'; 'Lift barrier (start of free choice)';...
               'Leave maze'; 'Enter Delay'; 'Forced Choice'; 'Free Choice';...
               'Forced Reward'; 'Free Reward'; 'ForcedChoiceEnter';'FreeChoiceEnter';...
               'Forced Stem End'; 'Free Stem End'; 'Choice Enter'};
           
headings = {txt{1,:}};
useCols = find(cellfun(@(x) any(strcmpi(x,okTypes)),headings));
checkFrames = frames(:,useCols); %#ok<FNDSB>
%[C,ia,ic] = unique(checkFrames,'rows');
for ur = 1:size(checkFrames,1)
    [~,ia,~] = unique(checkFrames(ur,:));
    MessedUp(ur,1) = length(ia) < size(checkFrames,2);
end
if any(MessedUp); disp(['deleting some laps, overlap frames, file ' xls_use]); end

tooLong = any(frames >= length(x_adj_cm),2);
if any(tooLong); disp(['deleting some laps, frames longer than positions, file ' xls_use]); end
badLaps = MessedUp | tooLong;

newFrames = frames;
newFrames(badLaps, :) = [];

newTxt = txt;
newTxt(logical([0; badLaps]), :) = [];

[newAll] = CombineForExcel(newFrames, newTxt);

saveName = [xls_use(1:startAt{i}-1) 'Finalized.xlsx'];
xlswrite(fullfile(inputPath,saveName), newAll);
disp('saved corrected sheet')
end

end


           