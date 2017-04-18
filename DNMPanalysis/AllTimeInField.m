function [allPFtime, onsAndOffs] = AllTimeInField (place_maps_file, place_stats_file, placeField)
%finds all the time when the mouse is in specified pixes, can restrict to a
%single pf by indicating which [cell, field]

load(place_maps_file,'TMap_gauss','xBinTotal','yBinTotal')
load(place_stats_file,'PFpixels')

%Can probably rebin in here for y-coord only for remapping
linIndTotal = sub2ind(size(TMap_gauss{1}),xBinTotal,yBinTotal);

if nargin==3 && exist('placeField','var')
    if length(placeField)==2
        runAll=0;
    else 
        disp('placeField needs row and column; running all')
        runAll=1;
    end
end
if nargin==2 || runAll==1
    numCells = size(PFpixels,1); numFields = size(PFpixels,2);
    allPFtime = cell(numCells,numFields);
    onsAndOffs = cell(numCells,numFields);
    for thisCell = 1:numCells
        for thisField = 1:numFields
            fieldPixels = PFpixels{thisCell,thisField};
            if any(fieldPixels)
                logicalInPF = ismember(linIndTotal,fieldPixels);
                allPFtime{thisCell,thisField} = logicalInPF;
                onOff = diff([0 logicalInPF 0],1);
                ons = find(onOff==1);
                offs = find(onOff==-1)-1;
                onsAndOffs{thisCell,thisField} = [ons' offs'];
            end
        end
    end
end

end
