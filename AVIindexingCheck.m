obj=VideoReader('OneThruTen.AVI');
%obj.CurrentTime: 0

v=readFrame(obj);
imagesc(v)
    %Frame shown: 1
    %obj.CurrentTime: 0.0333
v=readFrame(obj);
imagesc(v)
    %Frame shown: 2
    %obj.CurrentTime: 0.0667
v=readFrame(obj);
imagesc(v)
    %Frame shown: 3
    %obj.CurrentTime: 0.1000

frameTarget=8;
obj.CurrentTime=frameTarget/obj.FrameRate;   
    %obj.CurrentTime: 0.2667
v=readFrame(obj);
imagesc(v)
    %Frame shown: 9
    %obj.CurrentTime: 0.3000   

obj.CurrentTime=(frameTarget-1)/obj.FrameRate;   
    %obj.CurrentTime: 0.2333
v=readFrame(obj);
imagesc(v)
    %Frame shown: 8
    %obj.CurrentTime: 0.2667   
frameTarget=3;

obj.CurrentTime=(frameTarget-1)/obj.FrameRate;   
    %obj.CurrentTime: 0.0667
v=readFrame(obj);
imagesc(v)
    %Frame shown: 3
    %obj.CurrentTime: 0.3000   
v=readFrame(obj);
imagesc(v)
    %Frame shown: 4
    %obj.CurrentTime: 0.1333   

frameTarget=10;
obj.CurrentTime=frameTarget/obj.FrameRate;   
    %obj.CurrentTime: 0.3333
v=readFrame(obj);
% Error: No more frames available

frameTarget=10;
obj.CurrentTime=(frameTarget-1)/obj.FrameRate;   
    %obj.CurrentTime: 0.30000
v=readFrame(obj);
imagesc(v)
    %Frame shown: 10
    %obj.CurrentTime: 0.3333   

frameTarget=1;
obj.CurrentTime=frameTarget/obj.FrameRate;   
    %obj.CurrentTime: 0.0333
v=readFrame(obj);
    %Frame shown: 2
    %obj.CurrentTime: 0.0667

frameTarget=1;
obj.CurrentTime=(frameTarget-1)/obj.FrameRate;   
    %obj.CurrentTime: 0.0000
v=readFrame(obj);
imagesc(v)
    %Frame shown: 1
    %obj.CurrentTime: 0.0333   

frameTarget=0;
obj.CurrentTime=frameTarget/obj.FrameRate; 
    %obj.CurrentTime: 0.0000
v=readFrame(obj);
imagesc(v)
    %Frame shown: 1
    %obj.CurrentTime: 0.0333  
    
frameTarget=0;    
obj.CurrentTime=(frameTarget-1)/obj.FrameRate;   
% Error: Expected CurrentTime to be nonnegative.