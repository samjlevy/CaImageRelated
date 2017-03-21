function ParsedFramesToBrainFrames ( xls_file)
%Takes an excell file as input and returns (in same format) all found frame
%numbers in brain (FT) time.

fps_brainimage = 20; brainFrameRate = 1/fps_brainimage;

load FToffsetSam.mat %Comes with FToffset LastUsable whichEndsFirst FTlength brainTime time

[frames, txt] = xlsread(xls_file, 1);
if any(frames>length(time))
   disp(['Problem: found ' sum(sum(frames>length(time))) ' frame numbers too long']) 
end

%Here we actually start dealing with things
newFrames = frames; 
for column = (1+strcmpi(txt{1,1},'Trial #')):size(txt,2)
    if ~isnan(frames(:,column))
       for row = 1:size(frames,1)
           newFrames(row, column) = findclosest(time(frames(row, column)), brainTime);
       end
    end
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