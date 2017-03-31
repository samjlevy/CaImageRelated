function [ framesWanted ] = ConditionalExcellParseout( frames, txt, columnLabel, isText )
%loads one of our DNMP/ForcedUnforced excell sheets and parses out frame
%identity by looking at txt for column names; column names have to meet
%hardcoded labels
%loads multiple spreadsheets into a struct(spreadsheetNum).frames, .txt,
%loops through that struct to get locations of desired columns
%might also be used to spit out conditional frame parsing based on what
%kind of names we find (e.g., do we have start delay' or not?)
if nargin==3
    isText=0;
end

framesWanted=zeros(length(columnLabel),1);
for want = 1:length(columnLabel)
    for colLab = 1:size(txt,2)
        if strcmpi(columnLabel{want},txt{1,colLab})
            if isText==1
                framesWanted=txt{2:end,colLab};
            else
                framesWanted(want) = colLab; 
                = frames(:,colLab);
            end    
        end
    end
end


%{
switch columnLabel
        case 'Start on maze (start of Forced'
        case 'Lift barrier (start of free choice)'
        case 'Leave maze'
        case 'Start in homecage'
        case 'Leave homecage'
        case 'Forced Trial Type (L/R)'
        case 'Free Trial Choice (L/R)'
        case 'Enter Delay' 
        case 'Forced Choice' 
        case 'Free Choice' 
        case 'Forced Reward'
        case 'Free Reward'
    end
%}

end