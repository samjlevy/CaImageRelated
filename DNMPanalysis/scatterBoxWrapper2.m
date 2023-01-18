function scatterBoxWrapper2(figHand,labels,colorsUse,varargin)
%varargin is all the data you're inputting where each thing is a cell within varargin

if length(varargin) == 1 %< length(numDays)
    varargin = varargin{1};
end

numDatas = numel(varargin);

grps = [];
dataHere = [];
colorsHere = [];
for ddd = 1:numDatas
    dataHere = [dataHere; varargin{ddd}(:)];
    grps = [grps; ddd*ones(numel(varargin{ddd}),1)];
    if ~isempty(colorsUse)
    if iscell(colorsUse)
        colorsHere = [colorsHere; repmat(colorsUse{ddd},numel(varargin{ddd}),1)];
    end
    if isnumeric(colorsUse)
        colorsHere = [colorsHere; repmat(colorsUse(ddd,:),numel(varargin{ddd}),1)];
    end
    end
end

if isempty(figHand)
    hh = figure; axes;
    figHand = hh.Children;
end

if any(colorsHere)
    scatterBoxSL(dataHere, grps, 'xLabel', labels, 'plotBox', true, 'circleColors', colorsHere, 'transparency', 0.5, 'plotHandle',figHand)
else
    scatterBoxSL(dataHere, grps, 'xLabel', labels, 'plotBox', true, 'transparency', 0.5, 'plotHandle',figHand)        
end

end
