function DNMPexcelCombiner(input_path)
%This function looks for all the unique adjusted_ files, finds the highest
%number for each, and puts together the appropriate ones. Uses original
%BrainTime sheet to idenify columns that have been adjusted, 

%Find the sheets we need
original_path = ls('*BrainTime.xlsx');
adjustedSheets = dir('*BrainTime_Adjusted_*.xlsx');
adjustedSheets = {adjustedSheets(:).name};

%Identify the highest ranked of each 'adjusted' type
adjType = cellfun(@(x) x(length(original_path)+6:end-5),adjustedSheets,'UniformOutput',false);%
typeNum = cellfun(@(x) strsplit(x,'-'),adjType,'UniformOutput',false);

ranks = ones(length(typeNum),1);
for tt = 1:length(adjType)
    editedPart{tt} = typeNum{tt}{1};
    if length(typeNum{tt}) == 2
        ranks(tt) = str2double(typeNum{tt}{2});
    end
end

types = unique(editedPart);

maxEachAdjust = cell(length(types),1);
for typesI = 1:length(types)
    isThisType = find(cellfun(@(x) strcmpi(x,types{typesI}),editedPart)); 
    [~,mind] = max(ranks(isThisType));
    
    maxEachAdjust{typesI} = adjustedSheets{isThisType(mind)};
end

%Make a combined sheet using the columns from the adjusted that don't match
%the original
[Oframes, Otxt] = xlsread(original_path, 1);
newFrames = Oframes;

colEdited = zeros(length(maxEachAdjust),size(Oframes,2));
for mm = 1:length(maxEachAdjust)
    [Aframes, Atxt] = xlsread(maxEachAdjust{mm}, 1);
    for col = 2:size(Oframes,2)
    if strcmp(Otxt(1,col),Atxt(1,col))
    if sum(isnan(Oframes(:,col)))==0   
        %Are the timestamps in this column diff between original and loaded?
        if sum(diff([Oframes(:,col) Aframes(:,col)],1,2)) > 0
            newFrames(:,col) = Aframes(:,col);
            colEdited(mm,col) = 1;
        end
    end
    else
        disp('Error: wrong columns alignment for:')
        maxEachAdjust(mm) 
    end
    end
end

%Check if edited a column twice, see if it's a problem
%Doesn't work for more than 2 spreadsheets
changedTwice = find(sum(colEdited,1) > 1);
if any(changedTwice)
for cc = 1:length(changedTwice)
    badCol = changedTwice(cc);
    overlapped = find(colEdited(:,badCol));
    if length(overlapped) <= 2
        [Aframes, Atxt] = xlsread(maxEachAdjust{overlapped(1)}, 1);
        [Bframes, ~] = xlsread(maxEachAdjust{overlapped(2)}, 1);
        if sum(diff([Aframes(:,badCol) Bframes(:,badCol)],1,2)) == 0
            %it's fine, do nothing
        else
            disp('Different results after for both adjusted sheets in column:')
            Atxt(1,badCol)
        end
    end
end
end


[newAll] = CombineForExcel(newFrames, Otxt);
saveName = [original_path(1:end-5) '_AllAdjusted.xlsx'];
xlswrite(saveName, newAll);
disp('saved combined sheet')
end    