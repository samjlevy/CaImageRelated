function GetPlusRewardLocations(posAnchoredFile,rewardLocFile)

if ~isempty(rewardLocFile)
    load(rewardLocFile,'rewardX','rewardY','rewardXadj','rewardYadj','rewardLocs')
else
    
load(posAnchoredFile,'v0','posAnchorIdeal','anchors','xAVI','yAVI','epochs')

if ~iscell(v0)
    v0 = {v0};
end

rewardLocs = {'North','East','South','West'};

method = questdlg('Do this ginput or frame numbers?','How rewards','Ginput','FrameNums','FrameNums');
if strcmpi(method,'FrameNums')
    PositionChecker;
end

%Get the reward locations
for vI = 1:size(epochs,1)
    disp(['Doing epoch ' num2str(vI) ', frames ' num2str(epochs(vI,1)) ' thru ' num2str(epochs(vI,2))])
    
    switch method
        case 'Ginput'
    aa = figure; 
    imagesc(v0{vI})
    for rlI = 1:4
        title(['Please click reward location for: ' rewardLocs{rlI}])
        [rewardX{vI}(rlI,1),rewardY{vI}(rlI,1)] = ginput(1);
        hold on
        plot(rewardX{vI}(rlI,1),rewardY{vI}(rlI,1),'+g')
    end
    close(aa)
        
        case 'FrameNums'
            for rlI = 1:4
                frameIn = str2double(input(['Enter frame number when mouse is at reward location ' rewardLocs{rlI} '>> '],'s'));
                if frameIn == 0
                    aa = figure; 
                    imagesc(v0{vI})
                    title(['Please click reward location for: ' rewardLocs{rlI}])
                    [rewardX{vI}(rlI,1),rewardY{vI}(rlI,1)] = ginput(1);
                    hold on
                    plot(rewardX{vI}(rlI,1),rewardY{vI}(rlI,1),'+g')
                    close(aa)
                else
                    rewardX{vI}(rlI,1) = xAVI(frameIn);
                    rewardY{vI}(rlI,1) = yAVI(frameIn);
                end
            end
    end
    
    tform = fitgeotrans([anchors{vI}],posAnchorIdeal,'affine');
    [rewardXadj{vI}, rewardYadj{vI}] = transformPointsForward(tform,rewardX{vI},rewardY{vI});
end

end

save(posAnchoredFile,'rewardX','rewardY','rewardXadj','rewardYadj','rewardLocs','-append')
disp(['Done getting reward locations, saved to: ' posAnchoredFile])

end