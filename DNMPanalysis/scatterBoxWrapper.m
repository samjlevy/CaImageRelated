function scatterBoxWrapper(figHand,useID,labels,numDays,varargin)
%varargin is all the data you're inputting where each thing is a cell within varargin

if length(varargin) == 1 %< length(numDays)
    varargin = varargin{1};
end

numDatas = length(varargin);
numMice = length(numDays);
numDataPts = length(varargin{1});

if numDataPts == sum(numDays)
    mouseIDvec = []; for mouseI = 1:numMice; mouseIDvec = [mouseIDvec; ones(numDays(mouseI),1)*mouseI]; end    
elseif numDataPts == (sum(numDays)-numMice)
    mouseIDvec = []; for mouseI = 1:numMice; mouseIDvec = [mouseIDvec; ones(numDays(mouseI)-1,1)*mouseI]; end    
end

grps = repmat(1:numDatas,numDataPts,1); grps = grps(:);

dataHere = [];
for ddd = 1:numDatas
    dataHere = [dataHere; varargin{ddd}(:)];
end

mousecolors2 = [1 0 0; 0 1 0; 0 0 1; 1 1 0];
mousecolors2 = mousecolors2(1:numMice,:);
colorsHere = mousecolors2(mouseIDvec,:);
colorsHere = repmat(colorsHere,numDatas,1);

if isempty(figHand)
    hh = figure; axes;
    figHand = hh.Children;
end

switch useID
    case 0
        scatterBoxSL(dataHere, grps, 'xLabel', labels, 'plotBox', true, 'transparency', 0.5, 'plotHandle',figHand)
    case 1
        scatterBoxSL(dataHere, grps, 'xLabel', labels, 'plotBox', true, 'circleColors', colorsHere, 'transparency', 0.5, 'plotHandle',figHand)
end

end
