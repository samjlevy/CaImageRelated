function [strict, pctOfSmaller] = PlaceFieldOverlap(PlacefieldA, PlacefieldB)
%pctA, pctB
%Placefields are TMaps, assumes  
%Strict is bins in the TMap, rough is blocking them into squares overlap
%pct1/2 are percent of the field in the other

%Get indices where the placefield exists
%fieldIndsA = find(~isnan(PlacefieldA));
%fieldIndsB = find(~isnan(PlacefieldB));

%Which are found in the other
%AfoundinB = ismember(fieldIndsA, fieldIndsB);
%BfoundinA = ismember(fieldIndsB, fieldIndsA);

AfoundinB = ismember(PlacefieldA, PlacefieldB);
BfoundinA = ismember(PlacefieldB, PlacefieldA);

%Overlap
pctA = sum(AfoundinB)/length(PlacefieldA);
pctB = sum(BfoundinA)/length(PlacefieldB);

%Total shared ove
sharedArea = ismember(PlacefieldA(AfoundinB),PlacefieldB(BfoundinA));
strict = sum(sharedArea);

%percentage area of smaller field; could redo as pct of better pf
pctOfSmaller = strict/min([length(PlacefieldA) length(PlacefieldB)]); 

%Rough; actually harder than strict
%[ALeft, ARight, ATop, ABottom] = RoughBoundaries(PlacefieldA);
%[BLeft, BRight, BTop, BBottom] = RoughBoundaries(PlacefieldB);

%Aarea = RoughArea(ALeft, ARight, ATop, ABottom);
%Barea = RoughArea(BLeft, BRight, BTop, BBottom);

%??? Big conditional list to get arrangemend of boundaries
%{
AoverB(FieldB)=1;
AoverB(FieldA)=0.5;
AoverB(FieldA(AfoundinB))=0.75
figure; imagesc(AoverB)
hold on
plot(Acentroid(1),Acentroid(2),'*g')
plot(Bcentroid(1),Bcentroid(2),'*b')
%}
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