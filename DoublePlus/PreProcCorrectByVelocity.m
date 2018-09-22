function [xAVI,yAVI, definitelyGood] = PreProcCorrectByVelocity(xAVI,yAVI,onMaze,definitelyGood,...
    velThresh,v0,obj,manCorrFig,posAndVelFig)
aviSR = obj.FrameRate;


posAndVelFig = PreProcUpdatePosAndVel(xAVI,yAVI,onMaze,definitelyGood, velThresh,posAndVelFig);

velChoice = questdlg('How to pick high velocity frames?','Pick High Vel',...
                        'Whole Session','Select Window','First 100','Whole Session');
windowSearch = false(size(xAVI,1),size(xAVI,2));
framesManVeled = 0;
switch velChoice
    case 'Whole Session'
        windowSearch(:) = true;
        limitToHundredClicks = 0;
    case 'Select Window'
        [posAndVelFig] = PreProcUpdatePosAndVel(xAVI,yAVI,onMaze,definitelyGood,velThresh,posAndVelFig); 
        figure(posAndVelFig);
        [windowLims,~] = ginput(2);
        windowLims = round(windowLims);
        winStart = max([min(windowLims) 1]);
        winStop = min([max(windowLims) length(xAVI)]);
        
        windowSearch(winStart:winStop) = true;
        
        limitToHundredClicks = 0;
        
        disp(['Now editing from ' num2str(winStart) ' to ' num2str(winStop)])
    case 'First 100'
        windowSearch(:) = true;
        limitToHundredClicks = 1;
end

doneVel = 0;
%Ask about range to look for bad points
manChoice = questdlg('Redo definitely good frames?','Redo DefGood',...
                    'Yes','No','Cancel','Yes');
switch manChoice; case 'Yes'; skipDefGood = 0; case 'No'; skipDefGood = 1; case 'Cancel'; doneVel = 1; end



while doneVel == 0
    veloc = PreProcGetVelocity(xAVI,yAVI,windowSearch,onMaze);
    
    badVel = veloc > velThresh;
    if skipDefGood==1
        skdg = definitelyGood(1:end-1) & definitelyGood(2:end);
        badVel(skdg) = 0;
    end
            
    triedVel = zeros(length(xAVI),1);
    
    if sum(badVel)==0
        doneVel = 1;
        disp('Found no more high velocity points')
    elseif sum(badVel) > 0
        disp(['Found ' num2str(sum(badVel)) ' points above velocity threshold'])
        %Try to find a frame to correct
        
        %defGoodWork = definitelyGood==0;
        anyBadVel = 1;
        while anyBadVel == 1
            skipCorr = 0;
            
            frameTry = find(badVel,1,'first');
            
            %Check how much we've tried to do this, figure out frames to try
            if triedVel(frameTry)==1
                disp(['tried ' num2str(frameTry) ' once'])
                if triedVel(frameTry+1) < 1
                    frameTry = frameTry + 1;
                else
                    disp(['tried one after ' num2str(frameTry) ' once'])
                    if triedVel(frameTry-1) < 1
                    frameTry = frameTry - 1;
                    else
                        disp(['tried one before ' num2str(frameTry) ' once'])
                        if triedVel(frameTry+1) >= 1 && triedVel(frameTry-1) >= 1
                            frameTry = (frameTry-1):(frameTry+1); 
                        end
                    end
                end
            elseif triedVel(frameTry)==2    
                disp('tried twice, trying prev/next')
                triedVel(frameTry) = triedVel(frameTry)+1;
                frameTry = [frameTry-1 frameTry frameTry+1];
            elseif triedVel(frameTry)>2
                disp(['tried this frame ' num2str(triedVel(frameTry)) ' times'])
                tooManyCorrs = questdlg(['Tried this frame ' num2str(triedVel(frameTry)) ' times, what now?'],...
                    'what now?','Try again','+/- nFrames','StopV','Try again');
                switch tooManyCorrs
                    case 'Try again'
                        %Do nothing
                    case '+/- nFrames'
                        framesCheck = str2double(input('How many frames forward and back?','s'));
                        frameTry = (frameTry-framesCheck):(frameTry+framesCheck);
                    case 'StopV'
                        skipCorr = 1;
                        anyBadVel = 0;
                end
            end

            if skipCorr == 0
                ftI = 1;
                while ftI < length(frameTry)+1
                    corrFrame = frameTry(ftI);

                    [obj,manCorrFig,xAVI,yAVI,definitelyGood,buttonClicked,zfI] = PreProcCorrectFrameManual(...
                        corrFrame,obj,manCorrFig,xAVI,yAVI,definitelyGood,velThresh,[]);         
                    
                    skipRest = 0;
                    if zfI == -5
                        anyBadVel = 0;
                        skipCorr = 1;
                        skipRest = 1;
                        doneVel=1;
                    end

                    triedVel(corrFrame) = triedVel(corrFrame)+1;
                    
                    if skipRest == 0
                        if buttonClicked==1 || buttonClicked==3
                            framesManVeled = framesManVeled + 1;
                        end

                        %Re-check velocity
                        %veloc = hypot(diff(xAVI.*onMazeWork.*windowSearch,1),diff(yAVI.*onMazeWork.*windowSearch,1));
                        veloc = PreProcGetVelocity(xAVI,yAVI,windowSearch,onMaze);
                        badVel = veloc > velThresh;
                        if skipDefGood==1
                            skdg = definitelyGood(1:end-1) & definitelyGood(2:end);
                            badVel(skdg) = 0;
                        end
                        if sum(badVel) == 0
                            anyBadVel = 0;
                            doneVel = 1;
                        elseif sum(badVel) > 0
                            anyBadVel = 1;
                        end

                        if limitToHundredClicks==1
                            if framesManVeled>=100
                                anyBadVel = 0;
                                badVel = 0;
                                doneVel = 1;
                            end
                        end
                    end 
                    ftI = ftI + 1;
                end
            elseif skipCorr == 1
                anyBadVel = 0;
                badVel = 0;
                doneVel = 1;
            end
        end
    end        
end
        
end