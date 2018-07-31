mainFolder = 'C:\Users\Sam\Desktop\DNMPfinalData';
mice = {'Bellatrix', 'Polaris', 'Calisto', 'Nix'};
mouseI = 4;
load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'),'allfiles')

stdMult = 3;

for ff = 1:length(allfiles)
    cd(allfiles{ff})
    %xls_file = 'Bellatrix_160831DNMPsheet_Finalized.xlsx'
    xls_file = ls('*Finalized.xlsx');
    [frames, txt] = xlsread(xls_file, 1);
    [right_forced, left_forced, right_free, left_free] = DNMPtrialDirections(frames, txt);
    [ forced_starts ] = CondExcelParseout( frames, txt, 'Start on maze (start of Forced', 0 );
    [ forced_stops ] = CondExcelParseout( frames, txt, 'Forced Choice', 0 );
    [ free_starts ] = CondExcelParseout( frames, txt, 'Lift barrier (start of free choice)', 0);
    [ free_stops ] = CondExcelParseout( frames, txt, 'Free Choice', 0 );
    sss.study_l = [forced_starts(left_forced), forced_stops(left_forced)];
    sss.study_r = [forced_starts(right_forced), forced_stops(right_forced)];
    sss.test_l = [free_starts(left_free), free_stops(left_free)];
    sss.test_r = [free_starts(right_free), free_stops(right_free)];

    useNow = sss.study_l;
    pinds = [];
    for aa = 1:size(useNow,1)
        pinds = [pinds useNow(aa,1):useNow(aa,2)];
    end

    useNow = sss.study_r;
    ponds = [];
    for aa = 1:size(useNow,1)
        ponds = [ponds useNow(aa,1):useNow(aa,2)];
    end

    load(fullfile(allfiles{ff},'Pos_align.mat'),'x_adj_cm','y_adj_cm')
    figure; 
    plot( x_adj_cm, y_adj_cm, '.k','MarkerSize',8)
    title(['File ' num2str(ff)])
    hold on
    plot( x_adj_cm(pinds), y_adj_cm(pinds), '.r','MarkerSize',8)
    plot( x_adj_cm(ponds), y_adj_cm(ponds), '.b','MarkerSize',8)

    wsize = 3;
    wstep = 0.5;
    wrange =  [5 45];
    ledges = wrange(1):wstep:wrange(2)-wsize;
    mids = ledges + wsize/2;

    xlall = x_adj_cm(pinds);
    xrall = x_adj_cm(ponds);
    ylall = y_adj_cm(pinds);
    yrall = y_adj_cm(ponds);
    for bb = 1:length(ledges)
        lLogical = (xlall >= ledges(bb)) & (xlall <= (ledges(bb)+wsize));
        xlhere = xlall(lLogical);
        ylhere = ylall(lLogical);
        rLogical = (xrall >= ledges(bb)) & (xrall <= (ledges(bb)+wsize));
        xrhere = xrall(rLogical);
        yrhere = yrall(rLogical);

        ymeans(1:2,bb) = [mean(ylhere); mean(yrhere)];
    end

    indsUse = [10:sum(mids<30)];

    ydiffsUse = abs(diff(ymeans(:,indsUse),1,1));

    ydiffsStd = std(ydiffsUse);
    ydiffsMean = mean(ydiffsUse);

    ydiffs = abs(diff(ymeans,1,1));

    ydiffs / (ydiffsMean+ydiffsStd);

    plot(mids,ymeans(1,:),'-*g','LineWidth',2)
    plot(mids,ymeans(2,:),'-*m','LineWidth',2)
    plot([mids(1) mids(end)],[5 5],'-k')
    plot([mids(1) mids(end)],[5 5]+ydiffsStd*stdMult,'-r')
    plot(mids,5+ydiffs,'-oc')
    plot(mids(ydiffs > ydiffsMean+ydiffsStd*stdMult),5+ydiffs(ydiffs > ydiffsMean+ydiffsStd*stdMult),'-or')


    lastInd(ff) = find((ydiffs > ydiffsMean+ydiffsStd*stdMult) & (mids>=30),1,'first') - 1;

end

%Mdl = fitcnb(trainX,trainingAnswers,'distributionnames','mn');
%[decodedTrial,postProbs] = predict(Mdl,testY);

%% Check xpos of current sheet stuff

mainFolder = 'C:\Users\Sam\Desktop\DNMPfinalData';
mice = {'Bellatrix', 'Polaris', 'Calisto', 'Nix'};
mouseI = 4;
load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'),'allfiles')

means = []; stds = [];
for ff = 1:length(allfiles)
    cd(allfiles{ff})
    %xls_file = 'Bellatrix_160831DNMPsheet_Finalized.xlsx'
    xls_file = ls('*Finalized.xlsx');
    [frames, txt] = xlsread(xls_file, 1);
    load(fullfile(allfiles{ff},'Pos_align.mat'),'x_adj_cm','y_adj_cm')
    [ forced_starts ] = CondExcelParseout( frames, txt, 'Start on maze (start of Forced', 0 );
    [ forced_stops ] = CondExcelParseout( frames, txt, 'ForcedChoiceEnter', 0 );
    [ free_starts ] = CondExcelParseout( frames, txt, 'Lift barrier (start of free choice)', 0);
    [ free_stops ] = CondExcelParseout( frames, txt, 'FreeChoiceEnter', 0 );
    xposs = x_adj_cm([forced_starts, forced_stops, free_starts, free_stops]);
    means(ff,:) = mean(xposs,1);
    stds(ff,:) = std(xposs,1);
end


%% Adjust with new lims

mainFolder = 'C:\Users\Sam\Desktop\DNMPfinalData';
mice = {'Bellatrix', 'Polaris', 'Calisto'};
mouseI = 1;
load(fullfile(mainFolder,mice{mouseI},'trialbytrial.mat'),'allfiles')

xlims = [8 38];

for ff = 1:length(allfiles)
    cd(allfiles{ff})
    xls_file = ls('*Finalized.xlsx');
    brainTime = ls('*BrainTime.xlsx');
    [frames, txt] = xlsread(xls_file, 1);
    [framesB, txtB] = xlsread(brainTime, 1);
    lapsMissing = find(sum(frames(:,1) == framesB(:,1)',1)==0); %Finalized deletes bad laps
    framesB(lapsMissing,:) = [];
    txtB(lapsMissing,:) = [];
    fixedFrames = frames;
    if exist(fullfile(cd,'PosOld'),'dir')~=7; mkdir('PosOld'); end
    movefile(xls_file,fullfile(cd,'PosOld'))
    load(fullfile(allfiles{ff},'Pos_align.mat'),'x_adj_cm','y_adj_cm')
    
    %Fix ends: Check between start and choice made
    framesFix = {'ForcedChoiceEnter','FreeChoiceEnter'};
    framesStarts = {'Start on maze (start of Forced','Lift barrier (start of free choice)'};
    framesEnds = {'Forced Choice','Free Choice'};
    
    for ss = 1:2
        starts = CondExcelParseout( frames, txt, framesStarts{ss}, 0 );
        farStops = CondExcelParseout( frames, txt, framesEnds{ss}, 0 );
        fixThese = CondExcelParseout( frames, txt, framesFix{ss}, 0 );        
  
        %{
        figure; plot(x_adj_cm,y_adj_cm,'.k')
        hold on
        plot(x_adj_cm(starts),y_adj_cm(starts),'.b')
        plot(x_adj_cm(farStops),y_adj_cm(farStops),'.g')
        plot(x_adj_cm(fixThese),y_adj_cm(fixThese),'.y')
        plot([xlims(1) xlims(1)],[-20 20])
        plot([xlims(2) xlims(2)],[-20 20])
        %}
        
        colFixed = fixThese;
        nFixed = 0;
        for lapI = 1:length(fixThese)
            if x_adj_cm(fixThese(lapI)) < xlims(2)
                indsNow = starts(lapI):farStops(lapI);
                goodInd = find(x_adj_cm(indsNow) > xlims(2),1,'first');
                colFixed(lapI) = indsNow(goodInd);
                nFixed = nFixed + 1;
                %plot(x_adj_cm(indsNow(goodInd)),y_adj_cm(indsNow(goodInd)),'om')
            end
        end
        %plot(x_adj_cm(colFixed),y_adj_cm(colFixed),'.r')
        [~,replaceCol] = CondExcelParseout( frames, txt, framesFix{ss}, 0 );
        fixedFrames(:,replaceCol) = colFixed;
        disp(['In ' allfiles{ff} ', adjusted ' num2str(nFixed) ' timestamps in ' framesFix{ss}])
    end
    
    %Fix starts: check between original starts and choiceenter
    framesFix = {'Start on maze (start of Forced','Lift barrier (start of free choice)'};
    framesStarts = {'Start on maze (start of Forced','Lift barrier (start of free choice)'};
    framesEnds = {'ForcedChoiceEnter','FreeChoiceEnter'};
    
    for ss = 1:2
        starts = CondExcelParseout( framesB, txtB, framesStarts{ss}, 0 );
        farStops = CondExcelParseout( frames, txt, framesEnds{ss}, 0 );
        fixThese = CondExcelParseout( frames, txt, framesFix{ss}, 0 );
  
        colFixed = fixThese;
        nFixed = 0;
        for lapI = 1:length(fixThese)
            if x_adj_cm(fixThese(lapI)) > xlims(1)
                indsNow = starts(lapI):farStops(lapI);
                %plot(x_adj_cm(indsNow),y_adj_cm(indsNow),'.m')
                goodInd = find(x_adj_cm(indsNow) < xlims(1),1,'last');
                if any(goodInd)
                    colFixed(lapI) = indsNow(goodInd);
                    nFixed = nFixed + 1;
                end
                %plot(x_adj_cm(indsNow(goodInd)),y_adj_cm(indsNow(goodInd)),'om')
            end
        end
        
        [~,replaceCol] = CondExcelParseout( frames, txt, framesFix{ss}, 0 );
        fixedFrames(:,replaceCol) = colFixed;
        disp(['In ' allfiles{ff} ', adjusted ' num2str(nFixed) ' timestamps in ' framesFix{ss}])
    end
    
    [newAll] = CombineForExcel(fixedFrames, txt);
    
    xlswrite( xls_file, newAll);
end
    
%replaceCol = find(cell2mat(cellfun(@(x) strcmpi(x,framesFix{ss}),{txt{1,:}},'UniformOutput',false)));