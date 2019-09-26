function [onMazeFinal,behTable] = ParseOnMazeBehaviorMultiWrapper(posLEDfile)

posLEDfile = 'C:\Users\Sam\Desktop\marble19_190818\posAnchored.mat';

saveFolder = strsplit(posLEDfile,'\');
saveFolder = fullfile(saveFolder{1:end-1});

load(posLEDfile,'v0','epochs','xAVI','yAVI');
%fn = fieldnames(pf);
%xind = listdlg('PromptString','Which is X positions?','ListString',fn);
%yind = listdlg('PromptString','Which is Y positions?','ListString',fn);

%xPos = pf.(fn{xind});
%yPos = pf.(fn{yind});

%v0 = pf.v0;
%epochs = pf.epochs;

allFrames = 1:length(xAVI);
numEpochs = length(v0);

for epochI = 1:numEpochs
    %Parse behavior automatically, lap times and correct alternation directions
    framesHere = epochs(epochI,1):epochs(epochI,2);
    xAVIhere = xAVI(framesHere);
    yAVIhere = yAVI(framesHere);

    [behTableE{epochI},areaX{epochI},areaY{epochI},areaLabels{epochI},behLabels{epochI}] =...
        ParseAlternationBehavior1(xAVIhere,yAVIhere,v0{epochI});
    
    behTable{epochI} = framesHere(behTableE{epochI});
    
    lapDirections{epochI} = ParseLapDirection(behTable{epochI}(:,5:6),...
        [areaX{epochI}{2} areaY{epochI}{2}],[areaX{epochI}{3} areaY{epochI}{3}],xAVI,yAVI);
    
    trialCorrect{epochI} = ParseCorrectAlternation(lapDirections{epochI});
    
    %Set limits for stem
    hh = figure; imagesc(v0{epochI})
    limm = questdlg('Is this a good figure to mark limits?','Mark stem','Yes','No','Yes');
    if strcmpi(limm,'No')
        [ff,ll] = uigetfile('Please get the video file');
        pp = fullfile(ll,ff);
        h1 = implay(pp);
        fnum = str2double(input('Choose a frame number with a good frame to mark limits >> ','s'));
        
        obj = VideoReader(pp);
        aviSR = obj.FrameRate;
        obj.CurrentTime = (fnum-1)/obj.FrameRate;
        delImage = readFrame(obj);
        imagesc(delImage)
    end
    
    title('Mark Stem Start')
    [stemX{epochI}(1),stemY{epochI}(1)] = ginput(1);
    title('Mark Stem End')
    [stemX{epochI}(2),stemY{epochI}(2)] = ginput(1);
end

save(fullfile(saveFolder,'behaviorParse.mat'),'behTable','areaX','areaY','areaLabels',...
    'behLabels','lapDirections','trialCorrect','stemX','stemY')

end
                
    
    