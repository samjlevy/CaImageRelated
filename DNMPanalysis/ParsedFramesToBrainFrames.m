function ParsedFramesToBrainFrames( xls_file,fps_brainimage)
%Takes an excell file as input and returns (in same format) all found frame
%numbers in brain (FT) time.
%Question for validation: in alignment bit (lines 32/33), should that
%-FToffset... be there? Make sure to comment why or why not if removing it
if isempty(fps_brainimage)
    fps_brainimage = 20;
end

if ~exist('xls_file','var')
    try
        xls_file = ls('*.xlsx');
        if size(xls_file,1)>1
            openFiles = cell2mat(cellfun(@(x) any(x),strfind(string(xls_file),'~$'),'UniformOutput',false));
            xls_file = string(xls_file);
            xls_file(openFiles) = [];
            xlsFile
        end
        [frames, txt] = xlsread(xls_file, 1);
    catch
        disp('auto finding xls file did not work; rerun with file name as input')
        return
    end
else
    [frames, txt] = xlsread(xls_file, 1);
end
        
brainFrameRate = 1/fps_brainimage;

load FToffsetSam.mat %Comes with FToffset LastUsable whichEndsFirst FTlength brainTime time


if any(frames>length(time))
   disp(['Problem: found ' sum(sum(frames>length(time))) ' frame numbers too long']) 
end

%Here we actually start dealing with things
newFrames = frames; 
for column = (2):size(frames,2)
    if any(~isnan(frames(:,column))) && ~strcmpi(txt{1,column},'MazeID')
       for row = 1:size(frames,1)
           newFrames(row, column) = findclosest(time(frames(row, column)), brainTime)...
               - (FToffset - (imaging_start_frame-1));
           %Probably this -FT offset accounts for frame numbers being
           %unaligned even after time is aligned
       end
    end
end
if newFrames(1,2)<0
    newFrames(1,2) = imaging_start_frame;
end

newAll=txt;
for column = 1:size(newFrames,2)
    if any(~isnan(frames(:,column))) || strcmpi(txt{1,column},'MazeID')
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