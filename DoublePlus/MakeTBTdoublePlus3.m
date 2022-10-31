function MakeTBTdoublePlus3(daybydayPath,excludeOutOfMazeBounds,mazeBounds,velThresh)
% This one is for the rebuilding after realigning data streams, though
% could be used more generally on modern daybyday
% Will save out combined laps (n-w,s-e), laps each, correct only, and
% thresholded by speed
% Does not work for different maze sizes

daybyday = load(daybydayPath);

mpts = strsplit(daybydayPath,'\');
mousePath = daybydayPath(1:end-numel(mpts{end})-1);

numSess = numel(daybyday.realDays);

tbtLapCorrect = []; % Whole laps n-w,s-e, correct only
tbtAllEach = []; % Laps broken to n,e,s,w  correct and incorrect
tbtAllEachCorrect = []; % same as ^^, but correct only
tbtAllEachCorrectThreshMaze = []; % same as ^^, but only points above speed thresh, and within maze boundaries

allTBTs.tbtLapCorrect = tbtLapCorrect;
allTBTs.tbtAllEach = tbtAllEach;
allTBTs.tbtAllEachCorrect = tbtAllEachCorrect;
allTBTs.tbtAllEachCorrectThreshMaze = tbtAllEachCorrectThreshMaze;

tbtNames = fieldnames(allTBTs);
nTBTs = numel(tbtNames);

correctOnly = [true, false, true, true];
speedThresh = [0, 0, 0, velThresh];
armSeqsUseTurn = {{'nmw','sme'},{'n','w','s','e'},{'n','w','s','e'},{'n','w','s','e'}};
armSeqsUsePlace = {{'nme','sme'},{'n','e','s','e'},{'n','e','s','e'},{'n','e','s','e'}};
startOrEnd = {{'both','both'},{'start','end','start','end'},{'start','end','start','end'},{'start','end','start','end'}};
restrictToMaze = [false, true, true, true];
eachArmCondOrderTurn = 'nwse';
eachArmCondOrderPlace = 'nese';



for sessN = 1:numSess
    nLapsH = size(daybyday.behavior{sessN},1);
    disp(['Working on session ' num2str(sessN) ', ' num2str(nLapsH) ' laps here'])
    for lapI = 1:nLapsH
        lapSequenceH = daybyday.behavior{sessN}.ArmSequence{lapI};

        
            for tbtI = 1:nTBTs
                % Make a blank to set up indexing
                if (sessN == 1) && (lapI == 1)
                    for condI = 1:numel(armSeqsUseTurn{tbtI})
                        allTBTs.(tbtNames{tbtI})(condI).trialsX = [];
                    end
                end

                if iscell(daybyday.sessType{sessN})
                    daybyday.sessType{sessN} = daybyday.sessType{sessN}{1};
                end

                switch daybyday.sessType{sessN}
                    case {'Turn','turn'}
                        armSeqMatch = armSeqsUseTurn{tbtI};
                    case {'Place','place'}
                        armSeqMatch = armSeqsUsePlace{tbtI};
                    otherwise
                        keyboard
                end

                if ((correctOnly(tbtI) == true) && (daybyday.behavior{sessN}.Correct(lapI) == true))  || (correctOnly(tbtI)==false)
                % Does this lap fit this cond type?
                for asI = 1:numel(armSeqMatch)
                    goodLap = false;
                    switch startOrEnd{tbtI}{asI}
                        case 'start'
                            % If this is the start of a lap, should match the start arm
                            if strcmpi(lapSequenceH(1),armSeqMatch{asI}) == true
                                goodLap = true;
                            end
                        case 'end'
                            switch daybyday.sessType{sessN}
                                case {'Turn','turn'}
                                    if strcmpi(lapSequenceH(end),armSeqMatch{asI}) == true
                                        goodLap = true;
                                    end
                                case {'Place','place'}
                                    % Need to arbitrate conds by lap start location because lap types end at east
                                    if strcmpi(lapSequenceH(end),armSeqMatch{asI}) == true
                                        switch lapSequenceH(1)
                                            case 'n'
                                                if asI==2
                                                    goodLap = true;
                                                end
                                            case 's'
                                                if asI==4
                                                    goodLap = true;
                                                end
                                        end
                                    end
                            end

                        case 'both'
                            if (strcmpi(lapSequenceH(1),armSeqMatch{asI}(1)) & strcmpi(lapSequenceH(end),armSeqMatch{asI}(end))) == true
                                goodLap = true;
                            end
                    end

                    % If this lap fits this cond type, go ahead and gather the data
                    if goodLap == true
                        thisTrial = numel(allTBTs.(tbtNames{tbtI})(asI).trialsX)+1;
                        % Get all pos on maze
                        lapFrames = daybyday.behavior{sessN}.LapStart(lapI):daybyday.behavior{sessN}.LapStop(lapI);
                        xHere = daybyday.all_x_adj_cm{sessN}(lapFrames);
                        yHere = daybyday.all_y_adj_cm{sessN}(lapFrames);

                        if any(isnan(xHere)) || any(isnan(yHere))
                            % If only the first or only the last is nan,
                            % just delete it. Otherwise...
                            if ( isnan(xHere(1)) && ~isnan(xHere(2)) ) || ( isnan(yHere(1)) && ~isnan(yHere(2)) )
                                lapFrames(1) = [];
                            end

                            if ( isnan(xHere(end)) && ~isnan(xHere(end-1)) ) || ( isnan(yHere(end)) && ~isnan(yHere(end-1)) )
                                lapFrames(end) = [];
                            end

                            xHere = daybyday.all_x_adj_cm{sessN}(lapFrames);
                            yHere = daybyday.all_y_adj_cm{sessN}(lapFrames);
                            if any(isnan(xHere)) || any(isnan(yHere))
                                disp('other nans')
                                keyboard
                            end
                        end

                        switch restrictToMaze(tbtI)
                            case true
                                
                                onMazeH = zeros(size(lapFrames));
                                binsH = zeros(numel(mazeBounds.lgDataBins.labels),1);
                                for armI = 1:numel(armSeqMatch{asI})
                                    binsH = binsH | mazeBounds.lgDataBins.labels==armSeqMatch{asI}(armI);
                                end
                                binsHinds = find(binsH);
                                for binI = 1:numel(binsHinds)
                                    [inn,onn] = inpolygon(daybyday.all_x_adj_cm{sessN}(lapFrames),daybyday.all_y_adj_cm{sessN}(lapFrames),...
                                        mazeBounds.lgDataBins.X(binsHinds(binI),:),mazeBounds.lgDataBins.Y(binsHinds(binI),:));
                                    onMazeH = onMazeH | inn | onn;
                                end
                                
                                %{
                                figure;
                                plot(daybyday.all_x_adj_cm{sessN}(lapFrames),daybyday.all_y_adj_cm{sessN}(lapFrames),'.k')
                                hold on
                                plot(mazeBounds.lgDataBins.X(binsH,:),mazeBounds.lgDataBins.Y(binsH,:),'*r')
                                plot(daybyday.all_x_adj_cm{sessN}(lapFrames(onMazeH)),daybyday.all_y_adj_cm{sessN}(lapFrames(onMazeH)),'.g')
                                %}

                            case false
                                onMazeH = true(size(lapFrames));
                        end

                        velHere = daybyday.all_velocity{sessN}(lapFrames);
                        if any(isnan(velHere))
                            if ( isnan(velHere(1)) && ~isnan(velHere(2)) )
                                velHere(1) = velHere(2);
                                
                            end

                            if ( isnan(velHere(end)) && ~isnan(velHere(end-1)) )
                                velHere(end) = velHere(end-1);
                            end

                            if any(isnan(velHere))
                                disp('other nan vel')
                                keybaord
                            end
                        end
                        goodVel = velHere >= speedThresh(tbtI);

                        lapFrames = lapFrames(goodVel & onMazeH);

                        if isempty(lapFrames)
                            disp('no lap frames?')
                            keyboard
                        end

                        xPosLap = daybyday.all_x_adj_cm{sessN}(lapFrames);
                        yPosLap = daybyday.all_y_adj_cm{sessN}(lapFrames);
                        PSAboolLap = daybyday.all_PSAbool{sessN}(:,lapFrames);
                        lapVel = daybyday.all_velocity{sessN}(:,lapFrames);
                        RawTraceLap = [];
                        DFDTtraceLap = [];
                        try
                            RawTraceLap = daybyday.all_Fluoresence.RawTrace{sessN}(:,lapFrames);
                            DFDTtraceLap = daybyday.all_Fluoresence.DFDTtrace{sessN}(:,lapFrames);
                        end
                        lapNumberH = lapI;
                        sessID = daybyday.realDays(sessN);
                        isCorrectH = daybyday.behavior{sessN}.Correct(lapI);
                        allowedFixH = daybyday.behavior{sessN}.AllowedFix(lapI);
                        startArmH = lapSequenceH(1);
                        endArmH = lapSequenceH(end);
                        ruleH = daybyday.sessType{sessN};

                        allTBTs.(tbtNames{tbtI})(asI).trialsX{thisTrial,1} = xPosLap;
                        allTBTs.(tbtNames{tbtI})(asI).trialsY{thisTrial,1} = yPosLap;
                        allTBTs.(tbtNames{tbtI})(asI).trialVelocity{thisTrial,1} = lapVel;
                        allTBTs.(tbtNames{tbtI})(asI).trialPSAbool{thisTrial,1} = PSAboolLap;
                        allTBTs.(tbtNames{tbtI})(asI).trialRawTrace{thisTrial,1} = RawTraceLap;
                        allTBTs.(tbtNames{tbtI})(asI).trialDFDTtrace{thisTrial,1} = DFDTtraceLap;
                        allTBTs.(tbtNames{tbtI})(asI).sessID(thisTrial,1) = sessID;
                        allTBTs.(tbtNames{tbtI})(asI).isCorrect(thisTrial,1) = isCorrectH;
                        allTBTs.(tbtNames{tbtI})(asI).allowedFix(thisTrial,1) = allowedFixH;
                        allTBTs.(tbtNames{tbtI})(asI).startArm{thisTrial,1} = startArmH;
                        allTBTs.(tbtNames{tbtI})(asI).endArm{thisTrial,1} = endArmH;
                        allTBTs.(tbtNames{tbtI})(asI).lapSequence{thisTrial,1} = lapSequenceH;
                        allTBTs.(tbtNames{tbtI})(asI).rule{thisTrial,1} = ruleH;
                        allTBTs.(tbtNames{tbtI})(asI).lapFrames{thisTrial,1} = lapFrames;
                        allTBTs.(tbtNames{tbtI})(asI).lapNumber(thisTrial,1) = lapNumberH;
                    end
                end



                end % correctonly  
            end
    end

end

behavior = daybyday.behavior;
realDays = daybyday.realDays;
sortedSessionInds = daybyday.sortedSessionInds;

if strcmpi(input('Save this trialbytrial?','s'),'y')
    tbtPath = fullfile(mousePath,'trialbytrial.mat');
    save(tbtPath,'realDays','behavior','sortedSessionInds')

    for ii = 1:nTBTs
        eval([tbtNames{ii} ' = allTBTs.' tbtNames{ii} ';'])
        saveStr = strcat('save("',tbtPath,'"',',"',tbtNames{ii},'",',"'-append')");
        eval(saveStr)
    end

    disp('Done saving')
end


end