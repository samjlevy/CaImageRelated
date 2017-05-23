[FMap_unsmoothed, FMap_gauss]=PFflourescenceMap(PFpixels,PFepochs,isrunning,xBin,yBin,LPtrace,RunOccMap)

fluorMax = max(LPtrace) - min(LPTrace);
floorThresh = median(LPTrace);
LPtraceNew = LPtrace;
LPtraceNew(LPtrace<0)=0;

%Get linearized numbers for each bin
linIndTotal = sub2ind(size(RunOccMap),xBinTotal,yBinTotal);
runningInds=find(isrunning); %indices in FT used in placefields
blockTimePFpixel = linIndTotal(runningInds);
pixs=unique(blockTimePFpixel);









linIndPixs = unique(linIndTotal(on_maze_include));
linPixsFluor = cell(length(linIndPixs),1);
pixFluorTotal = nan(length(linIndPixs),1);
pixFluorMean = nan(length(linIndPixs),1);
for each=1:length(linIndPixs)
    linPixsFluor{each,1} = LPtraceNew(linIndTotal==linIndPixs(each));%-min(LPTrace)/fluorMax
    pixFluorTotal(each,1) = sum(linPixsFluor{each,1});
    pixFluorMean(each,1) = mean(linPixsFluor{each,1});
end

FTotal=zeros(size(RunOccMap));
FTotal(linIndPixs) = pixFluorMean;



FMap_unsmoothed = FTotal./RunOccMap; 
FMap_unsmoothed(isnan(FMap_unsmoothed)) = 0;

gauss_std = 2.5;
Fsum = sum(FTotal(:));
gauss_std = gauss_std/cmperbin; 
sm = fspecial('gaussian',[round(8*gauss_std,0),round(8*gauss_std)],gauss_std); 
        
FMap_gauss = imfilter(FMap_unsmoothed,sm);
FMap_gauss = FMap_gauss.*Fsum./sum(FMap_gauss(:)); 
FMap_gauss(RunOccMap==0) = nan;