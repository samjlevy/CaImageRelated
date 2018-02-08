inName = '20170914WWY1R_1.mov';
outName = [inName(1:end-4) 'tiff-1.tiff'];
obj = VideoReader(inName);
maxSize = 1073741824*4;
fmarker = 1;

expectedFrames = ceil(obj.Duration / obj.FrameRate);
updateHere = expectedFrames/100:expectedFrames/100:expectedFrames;
%p = ProgressBar(1);

ticker = 0;
while(obj.CurrentTime<obj.Duration)
    framer = readFrame(obj);
    framered = rgb2gray(framer);
    
    %Tiff has a size limit; check before proceeding
    %if ticker > 0
    %outfile = dir(outName);
    %if outfile.bytes >= maxSize - 4280
    %    fmarker = fmarker + 1;
    %    outName = [outName(1:end-5) '-' num2str(fmarker) '.tiff'];
    %end
    %end
    try
        imwrite(framered, outName, 'WriteMode', 'append',  'Compression','none');
    catch ME
        if any(strfind(ME.message,'Maximum TIFF file size exceeded'))
            fmarker = fmarker + 1;
            outName = [outName(1:end-5) num2str(fmarker) '.tiff'];
            imwrite(framered, outName, 'WriteMode', 'append',  'Compression','none');
        else
            keyboard
        end
    end
    
    %ticker = ticker + 1;
    %if sum(updateHere==ticker)==1
        %p.progress;
    %end
    
end
%p.stop;

t = Tiff('myfile.tif','w');

tagstruct.ImageLength = obj.Width;
tagstruct.ImageWidth = obj.Height;

t.write(imgdata);

t.close();

