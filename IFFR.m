
[MD, ref] = MakeMouseSessionList('Sam')

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
PFisFiring=cell(sized);
PFrateAverage=zeros(sized);
PFrateAverageNO=zeros(sized);
PFrateMax=zeros(sized);
PFrates2=cell(sized);
PFyes=cell(size(PFepochs));
PFhits=zeros(sized);

%%
[r,c]=size(PFepochs);
FTonset=cell(r,1);
parfor v=1:r
    FTonset{v}=find(diff(FT(v,:))==1)+1;
end

%%
for d=1:length(blockTypes);
thisBlockInds=blockInd{d};   
for a=1:length(PFinds)
[k,l]=ind2sub(size(PFepochs),PFinds(a));
%plot(t,x_adj_cm)
    for b=1:PFnumepochs(PFinds(a))
        thisEpoch=PFepochs{PFinds(a)}(b,:);
        %This conditional to separate by block is still hardcoded
        if any(thisEpoch(1) >= thisBlockInds(1,1)) && thisEpoch(2) <= thisBlockInds(1,2)...
                || thisEpoch(1) >= thisBlockInds(2,1) && thisEpoch(2) <= thisBlockInds(2,2)
            %Sets array entry as spikes per duration in field
            [i,j]=ind2sub(size(PFepochs),PFinds(a));
           %PFrates{k,l,d}(b)=sum(FT(i,thisEpoch(1):thisEpoch(2)))/((thisEpoch(2)-thisEpoch(1)+1)/tempScale);
            %plot(t(thisEpoch(1)),x_adj_cm(thisEpoch(1)),'.r')
            %plot(t(thisEpoch(2)),x_adj_cm(thisEpoch(2)),'.r')
            PFyes{k,l,d}(b)= any(FTonset{v} >= thisEpoch(1) & FTonset{v} <= thisEpoch(2));
        end
    end
    PFhits(k,l,d)=sum(PFyes{k,l,d});
    PFblockpasses(k,l,d)=length(PFyes{k,l,d});
    PFiffr(k,l,d)=PFhits(k,l,d)/PFblockpasses(k,l,d);
    %PFpass(k,l,d)=length(find(PFrates2{k,l,d}))/length(PFrates2{k,l,d});
    %PFrateAverageNO(k,l,d)=mean(PFrates{k,l,d}(PFrates{k,l,d}~=0));
    %PFrateAverage(k,l,d)=mean(PFrates{k,l,d});
    %PFrateMax(k,l,d)=max(PFrates{k,l,d});
end        
end


%%
PostProcess: cut instances with off-maze spiking, etc.
