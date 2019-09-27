function ExcludeLapFrames

bTable = readtable('AlternationSheet.xlsx');
load('posAnchored.mat','xAVI','yAVI','v0')

vNames = bTable.Properties.VariableNames;
ss = listdlg('ListString',vNames,...
             'PromptString','Select first in segment',...
             'SelectionMode','single');
tt = listdlg('ListString',vNames,...
             'PromptString','Select second in segment',...
             'SelectionMode','single');

excludeFrames = false(length(xAVI),1);
for lapI = 1:size(bTable,1)
    yeaok = 0;
    while yeaok==0
    gg = figure('Position',[417 159 1049 799]); imagesc(v0{bTable.MazeID(lapI)})
    hold on
    title(['Lap ' num2str(lapI) ' out of ' num2str(size(bTable,1))])
    framesHere = bTable.(vNames{ss})(lapI):bTable.(vNames{tt})(lapI);
    plot(xAVI(framesHere),yAVI(framesHere),'.')
    
    ex = input('Exclude frames? (y/n) >>','s');
    switch ex
        case {'n','0'}
            %Do nothing
            yeaok = 1;
        case {'y','1'}
            [~,boundX,boundY] = roipoly;
            [badFrames,~] = inpolygon(xAVI(framesHere),yAVI(framesHere),boundX,boundY);
            plot(xAVI(framesHere(badFrames)),yAVI(framesHere(badFrames)),'.r')
            wg = input('Was this good? (y/n) >> ','s');
            switch wg
                case {'n','0'}
                    yeaok = 0;
                case {'y','1'}
                    excludeFrames(framesHere(badFrames)) = true;
                    yeaok = 1;
            end
    end
    close(gg)
    end
end

load FToffsetSam.mat

badFrames = find(excludeFrames);

for bfI = 1:length(badFrames)
efb(bfI) = findclosest(time(badFrames(bfI)), brainTime)...
               - (FToffset - (imaging_start_frame-1));
end

excludeFramesBrain = false(length(brainTime),1);
excludeFramesBrain(efb) = true;
           
save('excludeFrames.mat','excludeFrames','excludeFramesBrain')

end