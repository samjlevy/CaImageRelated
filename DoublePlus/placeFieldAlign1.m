placeFieldAlign1(trialbytrial,cellPlot,distRadius,sessUse,correctOnly,allowedFix,boundingTier)

sessUse = [1 2 3];
for sessI = 1:length(sessUse)
    sessPlot = sessUse(sessI);
    [spikePosX{sessI},spikePosY{sessI},bins{sessI}] = placeFieldPolys1(trialbytrial,cellPlot,sessPlot,...
        correctOnly,allowedFix,boundingTier,distRadius);
end

figure; 
for sessI = 1:3
    for condI = 1:2
        subplot(2,3,sessI + 3*(condI-1))
        %plot(spikePosX{sessI}{condI},spikePosY{sessI}{condI},'.')
        for ii = 1:length(unique(bins{sessI}{condI}))
            ptpt = bins{sessI}{condI} == ii;
            plot(spikePosX{sessI}{condI}(ptpt),spikePosY{sessI}{condI}(ptpt),'.')
            hold on
        end
        xlim([-60 60]); ylim([-60 60])
    end
end

wid = 'MATLAB:polyshape:repairedBySimplify';
warning('off',wid)
for scI = 1:size(sessComp,1)
    sessA = sessComp(scI,1);
    sessB = sessComp(scI,2);
    
    fieldsA = bins{sessA}{condI};
    numFieldsA = length(unique(fieldsA));
    fieldsB = bins{sessB}{condI};
    numFieldsB = length(unique(fieldsB));
    
    clear polyA polyB
    for faI = 1:numFieldsA
        ptsHere = fieldsA == faI;
        ptsAX = spikePosX{sessA}{condI}(ptsHere);
        ptsAY = spikePosY{sessA}{condI}(ptsHere);
        
        [ptsIncluded,area] = convhull(ptsAX,ptsAY);
        
        polyA{faI} = polyshape(ptsAX(ptsIncluded),ptsAY(ptsIncluded));
        polyAarea{faI} = polyarea(ptsAX(ptsIncluded),ptsAY(ptsIncluded));
    end
    
    for fbI = 1:numFieldsB
        ptsHere = fieldsB == fbI;
        ptsBX = spikePosX{sessB}{condI}(ptsHere);
        ptsBY = spikePosY{sessB}{condI}(ptsHere);
        
        [ptsIncluded,area] = convhull(ptsBX,ptsBY);
        
        polyB{fbI} = polyshape(ptsBX(ptsIncluded),ptsBY(ptsIncluded));
        polyBarea{fbI} = polyarea(ptsBX(ptsIncluded),ptsBY(ptsIncluded));
    end
    
    for faI = 1:numFieldsA
        for fbI = 1:numFieldsB
            overlap{faI}{fbI} = intersect(polyA{faI},polyB{fbI});
            overlapArea(faI,fbI) = polyarea(overlap{faI}{fbI}.Vertices(:,1),overlap{faI}{fbI}.Vertices(:,2));
            
            % How much of this intersect out of original polys
            pctOverlapA(faI,fbI) = overlapArea(faI,fbI) / polyAarea{faI};
            pctOverlapB(faI,fbI) = overlapArea(faI,fbI) / polyBarea{fbI};
        end
    end
    
    
end     
        
   warning('on',wid)     