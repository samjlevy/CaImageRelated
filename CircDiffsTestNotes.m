%90CCW rotation: y = x, x = -y;
%Test computation time, memory for sliding subtraction

figure; axes; xlim([-2 2]); ylim([-2 2])
[cxA,cyA] = ginput(15);
%{
 1.0092         0
    0.9908    0.9679
    0.0138    1.6793
   -1.0000    0.8397
   -1.5253    0.0117
   -1.0553   -0.9446
   -0.3917   -1.2828
   -0.0507   -0.3032
    0.7143   -1.3061
    1.3502   -0.0700
    1.0737    1.0262
    0.2074   -0.4198
   -0.7512   -0.0933
   -0.6590    0.9213
    0.1521    1.2711
%}
plot(cxA,cyA,'.r')

cyB = cxA;
cxB = -cyA;

degTA = 1:1:360;
degTB = 1:1:720;

anglesA = atan2(cyA,cxA); angelsAdeg = rad2deg(anglesA);
radiiA = hypot(cxA,cxB);
anglesB = atan2(cyB,cxB); anglesBdeg = rad2deg(anglesB);
radiiB = radiiA;

sinsA = radiiA.*sin(deg2rad(degTA)-anglesA); sinsAcell = mat2cell(sinsA,ones(15,1),360);
sinsB = radiiB.*sin(deg2rad(degTB)-anglesB); sinsBcell = mat2cell(sinsB,ones(15,1),720);

%All to all signalA-signalB at each lag
tic
sinsBhere = cell(15,1);
for lagI = 1:length(degTA)
    %sinsBcell = mat2cell(sinsB(:,[1:360]+(lagI-1)),ones(15,1),360);
    %sinsBcell = mat2cell(radiiB.*sin(deg2rad([1:360]+(lagI-1))-anglesB),ones(15,1),360);
    [sinsBhere] = deal(cellfun(@(x) x([1:360]+(lagI-1)),sinsBcell,'UniformOutput',false));
    for ptA = 1:15
        %for ptB = 1:15
        %    diff = sinsA(ptA,:) - sinsB(ptB,lagI:(lagI+360-1));
        %end
        ABdiffs{ptA}(:,lagI) = cellfun(@(x) sum((sinsAcell{ptA}-x).^2),sinsBhere,'UniformOutput',true);
    end
end
toc

%xPlot = repmat(([1:360]),1,15);
%figure; for aa = 1:15; plot(xPlot(:),ABdiffs{aa}(:),'.'); hold on; end
allDat = cell2mat(ABdiffs');
figure; plot(mean(allDat,1))
[~,idx] = min(allDat,[],2);
figure; histogram(idx,100)

tic
maybeWork = cell2mat(arrayfun(@(x) degTA+x,degTA-1,'UniformOutput',false)');
sinsBall = arrayfun(@(x,y) x.*sin(deg2rad(maybeWork)-y),radiiB,anglesB,'UniformOutput',false);
for ptA = 1:15
    ABdiffs{ptA} = cellfun(@(z) sum(((sinsAcell{ptA}-z).^2),2),sinsBall,'UniformOutput',false);
end
toc

%Maybe can deal the cellfun and cellfun bot[h at once?
[sinsBallDeal{1:15}] = deal(sinsBall);
tic
maybeWork = cell2mat(arrayfun(@(x) degTA+x,degTA-1,'UniformOutput',false)');
sinsBall = arrayfun(@(x,y) x.*sin(deg2rad(maybeWork)-y),radiiB,anglesB,'UniformOutput',false);
ABdiffs2 = cellfun(@(j) cellfun(@(z) sum(((j-z).^2),2),sinsBall,'UniformOutput',false),sinsAcell,'UniformOutput',false);
toc

