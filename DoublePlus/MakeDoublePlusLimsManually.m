MakeDoublePlusLimsManually

srcFolder = {'G:\DoublePlus\Titan180604';'G:\DoublePlus\Kerberos180424';'G:\DoublePlus\Marble11_180721'};

for ii = 1:length(srcFolder)
    
cd(srcFolder{ii})

PositionChecker;

avi_filepath = ls('*.avi');
if size(avi_filepath,1)~=1
    [avi_filepath,~] = uigetfile('*.avi','Choose appropriate video:');
end
disp(['Using ' avi_filepath ])
obj = VideoReader(avi_filepath);
aviSR = obj.FrameRate;
%nFrames = round(obj.Duration*aviSR);  
frameSize = [obj.Height obj.Width];

thingsToFind = {'startSouth','startNorth','endEast','endWest'};
numFrames = 5;

exFrames = cell(length(thingsToFind),1);
for findI = 1:length(thingsToFind)
    for frameI = 1:numFrames
        exFrames{findI}(frameI,1) = str2double(input(['Enter frame # that is an example of : '...
            thingsToFind{findI} ' >>'],'s'));
    end
end

save boundsFrames.mat exFrames thingsToFind numFrames

end

lapEdgesManX = []; lapEdgesManY = [];
for jj = 1:length(srcFolder)
   
    cd(srcFolder{jj})
    load boundsFrames.mat
    load PosLED_temp.mat xAVI yAVI onMaze
    onMaze = logical(onMaze);
    load PosScaled.mat v0anchor
    
    %{
    hh = figure;
    plot(xAVI(onMaze),yAVI(onMaze),'k.','MarkerSize',3)
    hold on 
    for kk = 1:length(exFrames)
        plot(xAVI(exFrames{kk}),yAVI(exFrames{kk}),'.r','MarkerSize',6)
        
        meanEdgeX(kk) = mean(xAVI(exFrames{kk}));
        meanEdgeY(kk) = mean(yAVI(exFrames{kk}));
        
        plot([meanEdgeX(kk)+[20 -20]],[meanEdgeY(kk) meanEdgeY(kk)],'g')
        plot([meanEdgeX(kk) meanEdgeX(kk)],[meanEdgeY(kk)+[20 -20]],'g')
    end
    plot(v0anchor([1 2 4 3 1],1), v0anchor([1 2 4 3 1],2),'g')
    %}
    
    [anchorX,anchorY,bounds] = MakeDoublePlusPosAnchor([]);
    realAnchor = [anchorX' anchorY'];
    allPtsTform = fitgeotrans(v0anchor,realAnchor,'affine');
        
    [lapEdgeX,lapEdgeY] = transformPointsForward(allPtsTform,meanEdgeX,meanEdgeY);

    %save lapEdgesManual.mat lapEdgeX lapEdgeY
    
    lapEdgesManX(jj,:) = lapEdgeX;
    lapEdgesManY(jj,:) = lapEdgeY;
end


northToMid = abs(anchorY(4) - lapEdgesManY(:,2));
southToMid = abs(anchorY(1) - lapEdgesManY(:,1));
eastToMid = abs(anchorX(3) - lapEdgesManX(:,3));
westToMid = abs(anchorX(1) - lapEdgesManX(:,4));

hh = figure;
for ff = 1:length(srcFolder)
    cd(srcFolder{ff})
    load PosScaled.mat xAlign yAlign onMaze v0anchor
    
    xScaled{ff} = xAlign;
    yScaled{ff} = yAlign;
    posUse{ff} = logical(onMaze);
    
    plot(xScaled{ff}(posUse{ff}),yScaled{ff}(posUse{ff}),'.','MarkerSize',3)
    plot([lapEdgesManX(ff,4) lapEdgesManX(ff,4)],[-20 20],'r','LineWidth',1.5)
    plot([lapEdgesManX(ff,3) lapEdgesManX(ff,3)],[-20 20],'r','LineWidth',1.5)
    plot([-20 20],[lapEdgesManY(ff,1) lapEdgesManY(ff,1)],'r','LineWidth',1.5)
    plot([-20 20],[lapEdgesManY(ff,2) lapEdgesManY(ff,2)],'r','LineWidth',1.5)
    hold on
    
end
plot(anchorX([1 2 4 3 1],1), anchorY([1 2 4 3 1],2),'g','LineWidth',2) 
    
northLims = [anchorY(4) 190 ];
southLims = [anchorY(1) -190];
eastLims = [anchorX(3) 215];
westLims = [anchorX(1) -215];



    