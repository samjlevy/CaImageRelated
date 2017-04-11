function [strict, pctA, pctB] = PlaceFieldOverlap(PlacefieldA, PlacefieldB)
%Placefields are TMaps, assumes  
%Strict is bins in the TMap, rough is blocking them into squares overlap
%pct1/2 are percent of the field in the other

%Get indices where the placefield exists
fieldIndsA = find(~isnan(PlacefieldA));
fieldIndsB = find(~isnan(PlacefieldB));

%Which are found in the other
AfoundinB = ismember(fieldIndsA, fieldIndsB);
BfoundinA = ismember(fieldIndsB, fieldIndsA);

%AfoundinB = ismember(PlacefieldA, PlacefieldB);
%BfoundinA = ismember(PlacefieldB, PlacefieldA);

%Overlap
pctA = sum(AfoundinB)/length(fieldIndsA);
pctB = sum(BfoundinA)/length(fieldIndsB);

%Total shared ove
sharedArea = ismember(fieldIndsA(AfoundinB),fieldIndsB(BfoundinA));
strict = sum(sharedArea);

%Rough; actually harder than strict
%[ALeft, ARight, ATop, ABottom] = RoughBoundaries(PlacefieldA);
%[BLeft, BRight, BTop, BBottom] = RoughBoundaries(PlacefieldB);

%Aarea = RoughArea(ALeft, ARight, ATop, ABottom);
%Barea = RoughArea(BLeft, BRight, BTop, BBottom);

%??? Big conditional list to get arrangemend of boundaries

end
function [xLeft, xRight, yTop, yBottom] = RoughBoundaries(placeField)
xYes = any(placeField,1); xMids = find(xYes);
yYes = any(placeField,1); yMids = find(yYes);
xLeft = min(xMids) - 0.5; xRight = max(xMids) + 0.5;
yTop = min(yMids) - 0.5; yBottom = max(yMids) + 0.5;
end
function [area]=RoughArea(left, right, up, down)

area = (max([left right]) - min([left right]))*...
        (max([up down]) - min([up down]));
end