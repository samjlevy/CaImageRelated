function [sequencesFixed,seqEpochsFixed,xFixed,yFixed] = BadLapsAutoFixer(xHere,yHere,sequences,seqEpochs,mazeBoundaries,velThresh)

nLaps = numel(sequences);
nBoundRegions = 4;

% Get the 'rough' outer bounds for each arm
regions = unique([sequences{:}]);
for rr = 1:numel(regions)
    %{
    bbHere = mazeBoundaries.labels == regions(rr);
    xPts = mazeBoundaries.X(bbHere,:); yPts = mazeBoundaries.Y(bbHere,:);
    xPts = xPts(:); yPts = yPts(:);
    ptDistances = hypot(abs(xPts - mean(xPts)),abs(yPts - mean(yPts)));
    [srtedDists,srtOrder] = sort(ptDistances,1,'descend');

    xPsorted = xPts(srtOrder); yPsorted = yPts(srtOrder);

    % Grab top 4 as boundary)
    %if regions(rr)~='m'
        armBoundX{rr} = xPsorted(1:4);
        armBoundY{rr} = yPsorted(1:4);
    %end
    %}
    bbHere = mazeBoundaries.labels == regions(rr);
    xPts = mazeBoundaries.X(bbHere,:); yPts = mazeBoundaries.Y(bbHere,:);
    xPts = xPts(:); yPts = yPts(:);
    k = convhull(xPts,yPts);
    
    armBoundX{rr} = xPts(k(1:end-1));
    armBoundY{rr} = yPts(k(1:end-1));

end

for lapI = 1:nLaps

    if strcmpi(sequences{lapI}(1),'m')
        sequences{lapI}(1) = [];
        seqEpochs{lapI}(1,:) = [];
    end

    seqH = sequences{lapI};
    
    for ss = 1:numel(seqH)
        seqCheck = true;
        indHere = seqEpochs{lapI}(ss,1):seqEpochs{lapI}(ss,2);

        xH = xHere(indHere);
        yH = yHere(indHere);

        % Any pts in the box
        armIndH = find(regions == seqH(ss));
        [inR,onR] = inpolygon(xH,yH,armBoundX{armIndH},armBoundY{armIndH}); inR = inR | onR;
        xHr = xH(inR); yHr = yH(inR);

        %{
        if seqH(ss)=='e'
        figure('Position',[244 185 560 420]); plot(xHere,yHere,'.k')
        hold on
        plot(armBoundX{armIndH},armBoundY{armIndH},'*g')
        plot(xH,yH,'.m')
        plot(xH(inR),yH(inR),'.c')
        title(num2str(lapI))

        % plot(xHere(indHere(end)+1),yHere(indHere(end)+1),'.r')
        end
        %}
        if ~any(inR)
            if seqH(ss)~='m'
                disp('No points this arm region')
                qeq = figure('Position',[244 185 560 420]); 
                plot(xHere,yHere,'.k');
                hold on
                plot(armBoundX{armIndH},armBoundY{armIndH},'*g')
                plot(xH,yH,'.m')
                title(['Lap ' num2str(lapI)])
                if strcmpi(input(['Claim these points are in ' upper(seqH(ss)) ...
                        ', but found no points. Y to keep, other for keyboard:'],'s'),'y')
                    if strcmpi(input('Skip sequence checks this chunk (y/n)?','s'),'y')
                        seqCheck = false;
                    end
                else 
                    keyboard
                end
            end
        end
        try 
            close(qeq);
        end

        % Break the maze arm up into regions, check we have pts in all of them
        if seqCheck == true
        if seqH(ss)~='m'
            armH = seqH(ss);
            boundsX = [min(armBoundX{armIndH}),max(armBoundX{armIndH})];
            boundsY = [min(armBoundY{armIndH}),max(armBoundY{armIndH})];

            havePts = CheckForPtsInRegion(xHr,yHr,boundsX,boundsY,armH,nBoundRegions);

            indB = [min(indHere) max(indHere)];
            checkBadSeq = true;
            if sum(havePts) < nBoundRegions
                % First check if the first points before and after are
                % within other seqEpochs for this lap
                if (ss~=1) && (ss~=numel(seqH))
                    firstPtBefore = indHere(1)-1;
                    firstPtAfter = indHere(end)+1;
                    if (firstPtBefore == seqEpochs{lapI}(ss-1,2)) && (firstPtAfter == seqEpochs{lapI}(ss+1,1))
                        % First pt follows previous sequence           Last pt precedes next sequence
                        checkBadSeq = false;
                    end

                end
            end

            if checkBadSeq == true
            if sum(havePts) < nBoundRegions
                disp(['Something is up with this sequence, lap ' num2str(lapI) ', step ' num2str(ss)])

                indB = [min(indHere) max(indHere)];
                indHere = indB(1):indB(2);

                keepAdding = true;
                while keepAdding==true
                    %wholeLapFig = figure('Position',[359 92 560 420]);
                    wholeLapFig = figure('Position',[77 161 560 420]);
                    lapPts = seqEpochs{lapI}(1):seqEpochs{lapI}(end);
                    plot(xHere,yHere,'.k')
                    hold on
                    plot(armBoundX{armIndH},armBoundY{armIndH},'*g')
                    plot(xHere(lapPts),yHere(lapPts),'.m')
                    ssPts = seqEpochs{lapI}(ss,1):seqEpochs{lapI}(ss,2);
                    plot(xHere(indHere),yHere(indHere),'.c')

                    %afa = figure('Position',[1089 119 560 420]); 
                    afa = figure('Position',[635 161 560 420]);
                    plot(xHere,yHere,'.k')
                    hold on
                    plot(armBoundX{armIndH},armBoundY{armIndH},'*g')
                    plot(xH,yH,'.m')
                    plot(xH(inR),yH(inR),'.c')
                    plot(xH(1),yH(1),'.y')
                    plot(xH(end),yH(end),'.g')
                    title(num2str(lapI))
                    afa.Children.Title.String = [afa.Children.Title.String ' ' num2str(sum(havePts)) ' / ' num2str(nBoundRegions)];

                    howAd = input('How to adjust: add points to end (e), add points to start (s), other (o), done (d): ','s');
                    
                    switch howAd
                        case 'e'
                            indB(2) = indB(2)+1;
                        case 's'
                            indB(1) = indB(1)-1;
                        case 'o'
                            keyboard
                        case 'd'
                            keepAdding = 'false';
                        case 'a'
                            addToEnd = str2double(input('Add how many to end:','s'));
                            indB(2) = indB(2)+addToEnd;
                    end
                
                    try
                        close(afa);
                    end
                    try
                        close(wholeLapFig);
                    end
                    indHere = indB(1):indB(2);
    
                    xH = xHere(indHere);
                    yH = yHere(indHere);

                    
                    [inR,onR] = inpolygon(xH,yH,armBoundX{armIndH},armBoundY{armIndH}); inR = inR | onR;
                    xHr = xH(inR); yHr = yH(inR);
    
                    havePts = CheckForPtsInRegion(xHr,yHr,boundsX,boundsY,armH,nBoundRegions);

                    %{
                    if sum(havePts) < nBoundRegions
                        keepAdding = true;
                    else
                        keepAdding = false;
                    end
                    %}
                    
                end

                seqEpochs{lapI}(ss,1) = indB(1);
                seqEpochs{lapI}(ss,2) = indB(2);
            end
            end

        end
        end

        % Check velocity
        tooFast = hypot(abs(diff(xH)),abs(diff(yH))) > velThresh;
        [onsets,offsets] =  GetBinaryWindows(tooFast);
        durs = offsets - onsets;
        
        oneDurs = find(durs==1);
        for ddI = 1:numel(durs)
            indHH = onsets(ddI):offsets(ddI)+1;
            xHH = xH(indHH); yHH = yH(indHH);
            if durs(ddI)==1
                % Try just interpolating this one point
                xHH(2) = mean(xHH([1 3])); yHH(2) = mean(yHH([1 3]));
                tooF = hypot(abs(diff(xHH)),abs(diff(yHH))) > velThresh;
                if sum(tooF)==0
                    badInd = indHere(onsets(ddI)+1);
                    xHere(badInd) = xHH(2);
                    yHere(badInd) = yHH(2);
                    
                    xH = xHere(indHere);
                    yH = yHere(indHere);
                else
                    disp('Linearly interpolating this one point did not work')
                    keyboard
                end
            else
                disp(['xPts: ' num2str(xHH)])
                disp(['yPts: ' num2str(yHH)])
                nPtsFix = str2double(input('How many pts fix:','s'));
                indsInterp = [];
                for ii = 1:nPtsFix
                    indsInterp(ii) = str2double(input(['Pt number ' num2str(ii) ':'],'s'));
                end
                %indsInterp = [4 5];
                logInterp = false(size(xHH)); logInterp(indsInterp) = true;
                indsLog = 1:numel(logInterp);
                xHfixed = interp1(indsLog(~logInterp),xHH(~logInterp),indsLog(logInterp));
                yHfixed = interp1(indsLog(~logInterp),yHH(~logInterp),indsLog(logInterp));

                xHH(logInterp) = xHfixed;
                yHH(logInterp) = yHfixed;

                disp(['xPts fixed: ' num2str(xHH)])
                disp(['yPts fixed: ' num2str(yHH)])
                if strcmpi(input('Do these look good (y/n):','s'),'y')
                    badInds = indHere(onsets(ddI):offsets(ddI)+1);
                    xHere(badInds) = xHH;
                    yHere(badInds) = yHH;
                else
                    keyboard
                    %{
                    figure;
                    plot(xHere,yHere,'.k')
                    hold on
                    plot(xH,yH,'.m')
                    plot(xHH,yHH,'r')
                    plot(xHH,yHH,'.c')
                    %}
                end
            end
        end
%{
        if any(durs > 1)
            disp('High velocity durations greater than 1')
            keyboard
        end
%}
    end
end

xFixed = xHere;
yFixed = yHere;
sequencesFixed = sequences;
seqEpochsFixed = seqEpochs;

end

function havePts = CheckForPtsInRegion(xHr,yHr,boundsX,boundsY,armH,nBoundRegions)
havePts = false(nBoundRegions,1);
switch armH
    case {'s','n'}
        yCheck = linspace(min(boundsY),max(boundsY),nBoundRegions+1);
        havePts = false(nBoundRegions,1);
        for yy = 1:nBoundRegions
            havePts(yy) = any( (yHr >= yCheck(yy)) & (yHr <= yCheck(yy+1)) );
        end
    case {'e','w'}
        xCheck = linspace(min(boundsX),max(boundsX),nBoundRegions+1);

        for xx = 1:nBoundRegions
            havePts(xx) = any( (xHr >= xCheck(xx)) & (xHr <= xCheck(xx+1)) );
        end
end

end

