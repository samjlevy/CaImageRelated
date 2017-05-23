function ParsedFramesToBrainFramesOld (xls_file, pos_file, FToffset)
%It's called old, but it works with most recent working 
if ~exist('FToffset','var')
    FToffset = 0;
end

load(pos_file,'AVItime_interp')
[frames, txt] = xlsread(xls_file, 1);
use = zeros(1, size(frames,2));
for aa = 2:size(txt,2)
    if strcmpi(txt{aa,2},'Forced Trial Type (L/R)')
        use(aa) = 0;
    elseif strcmpi(txt{aa,2},'Free Trial Choice (L/R)')    
        use(aa) = 0;
    else
        use(aa) = 1;
    end
end

newFrames = frames;
useInd = find(use);
for bb=useInd
    newFrames(:,bb) = AVI_to_brain_frame(frames(:,bb), AVItime_interp) + FToffset;
end    

newAll=txt;
for column = 1:size(newFrames,2)
    if ~isnan(frames(:,column))
       for row = 1:size(frames,1)
           newAll{row+1,column} = newFrames(row,column);
       end
    end
end

saveName = [xls_file(1:end-5) '_BrainTime.xlsx'];
if ~exist(saveName,'file')
    xlswrite( saveName, newAll);
else
    disp('Brain time file already exists; not writing')
end

end