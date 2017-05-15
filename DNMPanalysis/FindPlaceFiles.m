function filesOut = FindPlaceFiles (cmperbin, halfFiles)
%finds the files you want based on some input vars; if don't want PT1/PT2
%files, set halfFiles=0 or leave out 

if nargin==1
    getHalf = 0;
elseif nargin==2
    getHalf = halfFiles;
end

whichType = {'Placefields','PlaceStats'};

for ft = 1:length(whichType)
files = dir([whichType{ft} '*']);
switch class(cmperbin)
    case 'double'
        rightcm = cellfun(@any, (strfind({files.name},[num2str(cmperbin) 'cm'])));
    case 'char'
        rightcm = cellfun(@any, (strfind({files.name},'2p5cm')));
end

%part = cellfun(@(x) x(strfind(x,'PT')+2:strfind(x,'.mat')-1),{files.name},'UniformOutput',false)

isHalf = cellfun(@any, (strfind({files.name},'PT')));
pfFiles = find( rightcm & ([files.isdir]==0) & isHalf==getHalf);
switch whichType{ft}
    case 'Placefields'
        placeFiles = {files(pfFiles).name};
    case 'PlaceStats'
        statsFiles = {files(pfFiles).name};
end
end
if length(placeFiles) ~= length(statsFiles)
    disp('Not as many place as stats files here')
end

%suffices = cellfun(@(x) x(13:end),placeFiles,'UniformOutput',false);
thesePts = cellfun(@(x) strsplit(x,'_'),placeFiles,'UniformOutput',false);
for pf = 1:length(placeFiles)
    type{pf} = [thesePts{1,pf}{1,2} '_' thesePts{1,pf}{1,3}]; 
end

filesOut.placeFiles = placeFiles';
filesOut.statsFiles = statsFiles';
filesOut.type = type';

%pieces = strsplit(placeFiles{1},'_');

end

