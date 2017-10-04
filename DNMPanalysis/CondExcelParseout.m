function [ framesWanted, colNum ] = CondExcelParseout( frames, txt, columnLabel, isText )
%loads one of our DNMP/ForcedUnforced excell sheets and parses out frame
%identity by looking at txt for column names; column names have to meet
%hardcoded labels
%loops through that struct to get locations of desired columns
%might also be used to spit out conditional frame parsing based on what
%kind of names we find (e.g., do we have start delay' or not?)

if nargin==3
    isText=0;
end

%Exception to handle inconsistent labelling
columnExists = any(cell2mat(cellfun(@(x) strcmpi(x,columnLabel),txt(1,:),'UniformOutput',false)));
if columnExists == 0
    switch columnLabel
        case 'ForcedChoiceEnter'
            disp('Switched label')
            columnLabel = 'Forced Stem End';
        case 'FreeChoiceEnter'
            columnLabel = 'Free Stem End';
            disp('Switched label')
        otherwise
            disp('Not going to find this column')
    end
end

colNum = [];
framesWanted = zeros(size(frames,1),1);
for colLab = 1:size(txt,2)
    if strcmpi(columnLabel,txt{1,colLab})
        if isText==1
            framesWanted = txt(2:end,colLab);
            colNum = colLab;
        else
            framesWanted = frames(:,colLab);
            colNum = colLab;
            if sum(framesWanted)==0
                framesWanted = [];
                disp(['No frames with this label:' columnLabel])
            end
        end    
    end
end

end