for ff = 1:length(filesuse)

xls_file = 'Bellatrix_160831DNMPsheet_Finalized.xlsx'

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

figure; 
plot( x_adj_cm, y_adj_cm, '.k','MarkerSize',8)
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
plot([mids(1) mids(end)],[5 5]+ydiffsStd,'-r')
plot(mids,5+ydiffs,'-o')

lastInd(ff) = find(ydiffs > ydiffsMean+ydiffsStd*2,1,'first') - 1;

end

%Mdl = fitcnb(trainX,trainingAnswers,'distributionnames','mn');
%[decodedTrial,postProbs] = predict(Mdl,testY);

