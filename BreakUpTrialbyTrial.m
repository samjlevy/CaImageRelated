function [buTBT] = BreakUpTrialbyTrial(trialbytrial,condBreak,binsBreak,howBreak)

% condbreak and binsBreak have to be equal length
% cond tells which cond in original trialbytrial to gather from
% binsBreak is a struct, has the bins to use

% how break: set mode for gathering pts
%       allInBound - all points in the region
%       firstlast - from first point inside to last point before leave

for condI = 1:length(condBreak)
    for trialI = 1:length(trialbytrial(condBreak(condI)).trialsX)
        px = trialbytrial(condBreak(condI)).trialsX{trialI};
        py = trialbytrial(condBreak(condI)).trialsY{trialI};
        
        [in,on] = inpolygon(px,py,binsBreak{condI}.X,binsBreak{condI}.Y);
        allIn = in | on;
        switch howBreak
            case 'allInBound'
                ptsH = allIn;
            case 'firstlast'

                mazeEpochs = diff([0 allIn(:)' 0]);
                posStarts = find(mazeEpochs==1);
                posStops = find(mazeEpochs==-1)-1;
                ptsH = [];
                if any(posStarts) && any(posStops)
                    testStop = posStops(end);
                    testStart = posStarts(end);

                    allIn = false(size(px));
                    allIn(testStart:testStop) = true;
                    ptsH = allIn;
                    
                    % Get dimensions of the boundary, ask if COM of points
                    % is within the middle half of the boundary
                    maxx = max(binsBreak{condI}.X(:)); minx = min(binsBreak{condI}.X(:)); lenx = maxx - minx; midx = mean([maxx minx]);
                    maxy = max(binsBreak{condI}.Y(:)); miny = min(binsBreak{condI}.Y(:)); leny = maxy - miny; midy = mean([maxy miny]);
                    comx = mean(px(ptsH)); comy = mean(py(ptsH));
                    if lenx > leny
                        xb = lenx/4;
                        yb = leny;
                    elseif leny > lenx
                        xb = lenx;
                        yb = leny/4;
                    end
                    withinMidX = (comx < (midx+xb)) && (comx > (midx-xb));
                    withinMidY = (comy < (midy+yb)) && (comy > (midy-yb));
                    withinMid = withinMidX && withinMidY;
                    
                    lengthCheck = (testStop - testStart) < 10 && (testStop - testStart) > 0;
                    tCheck = testStop == testStart;
                    pCheck = sum(in|on) > 1;
                    if lengthCheck || (tCheck && pCheck) || ~withinMid
                        bg = figure; plot(px,py,'.k')
                        hold on
                        plot(binsBreak{condI}.X,binsBreak{condI}.Y)
                        plot(px(ptsH),py(ptsH),'.r')
                        title(['sess ' num2str(trialbytrial(condBreak(condI)).sessID(trialI)) ', trial ' num2str(trialI) ', '...
                            num2str(testStop-testStart+1) ' pts, ok?'])
                        if strcmpi(input('Is this ok? (y/n) >> ','s'),'n');
                            eLengths = posStops(:)-posStarts(:)+1;
                            [~,indd] = max(eLengths);
                            testStart = posStarts(indd);
                            testStop = posStops(indd);
                            figure(bg); hold off
                            plot(px,py,'.k')
                            hold on
                            plot(binsBreak{condI}.X,binsBreak{condI}.Y) 
                            allIn = false(size(px));
                            allIn(testStart:testStop) = true;
                            ptsH = allIn;
                            plot(px(ptsH),py(ptsH),'.r')
                            title('How about now?')
                            if strcmpi(input('Is this ok? (y/n) >> ','s'),'n');
                                disp(num2str([posStarts(:) posStops(:)]))
                                testStart = str2double(input('Enter a new start frame number:','s'));
                                testStop = str2double(input('Enter a new stop frame number:','s'));
                                allIn = false(size(px));
                                allIn(testStart:testStop) = true;
                                ptsH = allIn;
                                plot(px(ptsH),py(ptsH),'.g')
                                figure(bg);
                                title(['sess ' num2str(trialbytrial(condBreak(condI)).sessID(trialI)) ', trial ' num2str(trialI) ', '...
                                num2str(testStop-testStart+1) ' pts, ok?'])
                                if strcmpi(input('Is this ok? (y/n) >> ','s'),'n');
                                keyboard
                                end
                            end
                        end
                        try; close(bg); end
                    end
                
                end
        end

        %{
        
        %}

        buTBT(condI).trialsX{trialI,1} = px(ptsH);
        buTBT(condI).trialsY{trialI,1} = py(ptsH);
        buTBT(condI).trialPSAbool{trialI,1} = trialbytrial(condBreak(condI)).trialPSAbool{trialI}(:,ptsH);
        buTBT(condI).trialDFDTtrace{trialI,1} = trialbytrial(condBreak(condI)).trialDFDTtrace{trialI}(:,ptsH);
        buTBT(condI).trialRawTrace{trialI,1} = trialbytrial(condBreak(condI)).trialRawTrace{trialI}(:,ptsH);        
        
    end

    buTBT(condI).sessID = trialbytrial(condBreak(condI)).sessID;
    buTBT(condI).sessNumber = trialbytrial(condBreak(condI)).sessNumber;
    buTBT(condI).lapNumber = trialbytrial(condBreak(condI)).lapNumber;
    buTBT(condI).isCorrect = trialbytrial(condBreak(condI)).isCorrect;
    buTBT(condI).allowedFix = trialbytrial(condBreak(condI)).allowedFix;
    buTBT(condI).startArm = trialbytrial(condBreak(condI)).startArm;
    buTBT(condI).endArm = trialbytrial(condBreak(condI)).endArm;
    buTBT(condI).lapSequence = trialbytrial(condBreak(condI)).lapSequence;
    buTBT(condI).rule = trialbytrial(condBreak(condI)).rule;
end

end
