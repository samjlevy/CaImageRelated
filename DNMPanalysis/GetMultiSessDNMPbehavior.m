function [bounds, pooled, correct] = GetMultiSessDNMPbehavior(allfiles, numframes)

pooled = cell(length(allfiles),1);
for file = 1:length(allfiles)
    bta = dir(fullfile(allfiles{file},'*BrainTime_Adjusted.xlsx'));
    if length(bta)==1
        bta = bta.name;
    elseif length(bta) > 1
        isRight = cell2mat(cellfun(@(x) any(strfind(x,'~$')),{bta.name},'UniformOutput',false));
        if sum(isRight)==1
            bta = bta(isRight).name;
        end
    else 
        disp('could not find brainTime_adjusted file')
        return
    end
    [bounds{file},~,~, pooled{file}, correct{file}] =...
    GetBlockDNMPbehavior( fullfile(allfiles{file},bta), 'stem_only', numframes(file));

    %allInc{1,file} = pooled{file}.include.forced & pooled{file}.include.left; %studyLeft
    %allInc{2,file} = pooled{file}.include.forced & pooled{file}.include.right; %studyRight
    %allInc{3,file} = pooled{file}.include.free & pooled{file}.include.left;%testLeft
    %allInc{4,file} = pooled{file}.include.free & pooled{file}.include.right; %testRight    
end

end