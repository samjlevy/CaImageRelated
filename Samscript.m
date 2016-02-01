%%
tempScale=20;%frames per second
load Pos_align.mat x_adj_cm y_adj_cm
%load ProcOut.mat FT
load PlaceMaps.mat FT t pval
load PFstats.mat PFepochs PFnumepochs
%%
blockTypes={'continuous'; 'delay'};
for f=1:length(blockTypes)
numBlocks(f)=input(['How many ' blockTypes{f} ' blocks?']);  
h=figure;
subplot(2,1,1)
plot(1:length(t),x_adj_cm)
xlim([-5000,length(t)+5000])
ylabel('X position')
title(['Select block start-stop for all ' blockTypes{f} ' blocks'])
subplot(2,1,2)
plot(1:length(t),y_adj_cm)
xlim([-5000,length(t)+5000])
ylabel('Y position')
disp(['Select block start-stop for all ' blockTypes{f} ' blocks'])
[times,ys] = ginput(numBlocks(f)*2);
times(times<0)=0;
close(h)
blockInd{f}=[times([1:2:length(times)-1]) times([2:2:length(times)])];
end
%%
sized=[size(PFepochs),length(blockTypes)];
check=PFnumepochs;
check(check~=0)=1;
PFinds=find(check);
PFrates=cell(sized);
PFrateAverage=zeros(sized);
PFrateAverageNO=zeros(sized);
PFrateMax=zeros(sized);
%%
%Break PFepochs by block? Check correct w/plot
for d=1:length(blockTypes);
thisBlockInds=blockInd{d};   
for a=1:length(PFinds)
[k,l]=ind2sub(size(PFepochs),PFinds(a));
%plot(t,x_adj_cm)
    for b=1:PFnumepochs(PFinds(a))
        thisEpoch=PFepochs{PFinds(a)}(b,:);
        %This conditional to break by block is still hardcoded, needs to be
        %generalized
        if any(thisEpoch(1) >= thisBlockInds(1,1)) && thisEpoch(2) <= thisBlockInds(1,2)...
                || thisEpoch(1) >= thisBlockInds(2,1) && thisEpoch(2) <= thisBlockInds(2,2)
            %Sets array entry as spikes per duration in field
            [i,j]=ind2sub(size(PFepochs),PFinds(a));
            PFrates{k,l,d}(b)=sum(FT(i,thisEpoch(1):thisEpoch(2)))/((thisEpoch(2)-thisEpoch(1)+1)/tempScale);
            %plot(t(thisEpoch(1)),x_adj_cm(thisEpoch(1)),'.r')
            %plot(t(thisEpoch(2)),x_adj_cm(thisEpoch(2)),'.r')
        end
    end
    PFpass(k,l,d)=sum(any(PFrates{k,l,d}))/PFnumepochs(k,l);
    PFrateAverageNO(k,l,d)=mean(PFrates{k,l,d}(PFrates{k,l,d}~=0));
    PFrateAverage(k,l,d)=mean(PFrates{k,l,d});
    PFrateMax(k,l,d)=max(PFrates{k,l,d});
end        
end


%%
PostProcess: cut instances with off-maze spiking, etc.
