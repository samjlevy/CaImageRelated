function trialbytrial = GetTBTvelocity(trialbytrial,brainFPS)

numConds = length(trialbytrial);
timePerFrame = 1/brainFPS;

for condI = 1:numConds
    numTrials = length(trialbytrial(condI).trialsX);
    
    for trialI = 1:numTrials
        xPts = trialbytrial(condI).trialsX{trialI};
        yPts = trialbytrial(condI).trialsY{trialI};
        xDists = diff(xPts);
        yDists = diff(yPts);
        hypots = hypot(xDists,yDists);
        vel = hypots/timePerFrame;
        vel = [vel(1), vel(:)']; % Just copy vel from frame 2 for frame 1
        trialbytrial(condI).trialVel{trialI,1} = vel;
    end
end

end
    
