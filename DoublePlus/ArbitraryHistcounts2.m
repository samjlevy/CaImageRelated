function [counts, binLoc] = ArbitraryHistcounts2(posX,posY,binsX,binsY)

bX = mat2cell(binsX,ones(size(binsX,1),1),size(binsX,2));
bY = mat2cell(binsY,ones(size(binsY,1),1),size(binsY,2));

hc = cellfun(@(x,y) inpolygon(posX,posY,x,y),bX,bY,'UniformOutput',false);

counts = cellfun(@sum,hc,'UniformOutput',true);

hcc = cell2mat(hc); %sum(sum(hcc,1)==1); %to check all accounted for
binID = hcc.*([1:21]');
binLoc = sum(binID,1);

%{
figure; 
plot(posX,posY,'.')
hold on
for bI = 1:length(bX)
    patch(bX{bI},bY{bI},rand(1,3),'FaceAlpha',0.5)
end
hcc = sum(cell2mat(hc),1);
plot(posX(hcc==0),posY(hcc==0),'.r')
%}

end