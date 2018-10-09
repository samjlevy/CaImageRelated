function PosScaledToPosAlign

  
load('PosScaled.mat','xAlign','yAlign','DVTtime','onMaze')
xAVI = xAlign; yAVI = yAlign;
onMaze = logical(onMaze);
xAVI(onMaze==0) = NaN; yAVI(onMaze==0) = NaN;
save('Pos.mat','xAVI','yAVI','DVTtime','onMaze')
        
JustFToffset;

AlignImagingToTracking2_SL; %- Pos.brain, only wants Pos.mat
    %has indices for frames to use from PSAbool and DVT
    %NaNs out times where onMaze == 0
    
load Pos_brain.mat xBrain yBrain brain_time PSAboolAdjusted PSAboolUseIndices TrackingUse

x_adj_cm = xBrain*2.54/10; %mult by 10 for pix per inch earlier
y_adj_cm = yBrain*2.54/10;
PSAbool = PSAboolAdjusted;

load('FinalOutput.mat', 'NeuronTraces')
RawTrace = NeuronTraces.RawTrace(:,PSAboolUseIndices);

save Pos_align.mat x_adj_cm y_adj_cm brain_time PSAbool RawTrace PSAboolUseIndices TrackingUse

disp('done, saved')

end