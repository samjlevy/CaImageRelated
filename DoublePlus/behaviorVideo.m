fileN{1} = 'D:\DoublePlus\Titan\Titan_180528\Ttn052818001.AVI';

framesN{1} = [2576, 2999; 10102, 10422];


fileN{2} = 'D:\DoublePlus\Titan\Titan_180602\Ttn060218001.AVI';

framesN{2} = [5245, 5775; 8964, 9221];

v = VideoWriter('plusBehaviorLO.avi');
v.Quality = 50;
open(v);

for ii = 1:2
    video = VideoReader(fileN{ii});
    currentTime = 0;
    currentFrame = readFrame(video);
    currentTime = currentTime+video.FrameRate^-1;
    frameNum = 1;

    for jj = 1:2
        for ff = framesN{ii}(jj,1):framesN{ii}(jj,2)
            frameNum = ff-1;
            video.CurrentTime = frameNum/video.FrameRate;
            currentFrame = readFrame(video);
            writeVideo(v,currentFrame);
        end
        
        for ff = 1:30
            currentFrame = 0.4*ones(size(currentFrame));
            writeVideo(v,currentFrame);
        end
    end
end

close(v);    
