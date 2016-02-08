function [results]=IFFRprocess(compareThresh)
%Takes outputs from IFFR_Sam and returns basic comparative information on
%them
%
load PFiffr.mat
load PFstats.mat PFnumepochs

numcells=length(find(PFnumepochs));
transientThresh=5;
if ~exist('compareThresh','var')
    compareThresh=0.5;
end
tots=sum(PFhits,3);
yes=tots>4;
sum(sum(yes))

[r,c,l]=size(PFhits);

KeepMat = PFhits >= transientThresh;
KeepMat=zeros(r,c); 

for a=1:r
    for b=1:c
        Pass(a,b)=abs(PFiffr(a,b,1)-PFiffr(a,b,2))/max(PFiffr(a,b,:));
    end
end

%Pass=abs(KeepMat.*PFiffr(:,:,1)-KeepMat.*PFiffr(:,:,2))>compareThresh*KeepMat.*PFiffr(:,:,1);
%Prop=sum(sum(Pass))/sum(sum(KeepMat));

oneone=Pass==1;
noneInOther=sum(sum(oneone))/numcells

tic
thresholds=[0.1:0.01:0.9];
for g=1:length(thresholds)
    Past=Pass;
    Past(Past==1)=0;
    Passed=Past>thresholds(g);
    PctPass(g)=sum(sum(Passed))/numcells;
end
toc
figure;
histogram(Pass(Pass>0 & Pass<1),20)
xlabel('Max absolute rate difference')
ylabel('Number of rate remappers')
title('Number of remappers by rate')
figure;
plot(thresholds,PctPass,'.')
xlabel('Max rate difference threshold')
ylabel('Percent cells that "remap" ')
ylabel('Percent cells that "rate remap" ')
title('Rate remapping by threshold')
end