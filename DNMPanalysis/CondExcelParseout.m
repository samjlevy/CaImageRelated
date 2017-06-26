function [ framesWanted ] = CondExcelParseout( frames, txt, columnLabel, isText )
%loads one of our DNMP/ForcedUnforced excell sheets and parses out frame
%identity by looking at txt for column names; column names have to meet
%hardcoded labels
%loops through that struct to get locations of desired columns
%might also be used to spit out conditional frame parsing based on what
%kind of names we find (e.g., do we have start delay' or not?)

if nargin==3
    isText=0;
end

framesWanted = zeros(size(frames,1),1);
for colLab = 1:size(txt,2)
    if strcmpi(columnLabel,txt{1,colLab})
        if isText==1
            framesWanted = txt(2:end,colLab);
        else
            framesWanted = frames(:,colLab); 
            if sum(framesWanted)==0
                framesWanted = [];
                disp(['No frames with this label:' columnLabel])
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