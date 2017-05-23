FrameBoundsValidator(pos_file, frame_bounds)

load(pos_file, 'x_adj_cm', 'y_adj_cm')

numEpochs = size(frame_bounds,1);
for thisEpoch = 1:numEpochs
    figure; 
    plot(x_adj_cm, y_adj_cm,'.k')
    hold on
    thisInc = frame_bounds(thisEpoch,1):frame_bounds(thisEpoch,2);
    plot(x_adj_cm(thisInc), y_adj_cm(thisInc),'.r')
    plot(x_adj_cm(frame_bounds(thisEpoch,1)),y_adj_cm(frame_bounds(thisEpoch,1)),'.y')
    plot(x_adj_cm(frame_bounds(thisEpoch,2)),y_adj_cm(frame_bounds(thisEpoch,2)),'.y')
    title(['Include for lap ' num2str(thisEpoch)])
end

badLap = 11;
timeStamp = frame_bounds(badLap,1);
hold on
plot(x_adj_cm(timeStamp),y_adj_cm(timeStamp),'*m')
i=0;
i=i+1;
hold on
plot(x_adj_cm(timeStamp+i),y_adj_cm(timeStamp+i),'*m')

