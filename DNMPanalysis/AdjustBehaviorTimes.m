function AdjustBehaviorTimes(xls_file, pos_file, column_fix, relation)
%For taking in a spreadsheet and adjusting a set of frames. Meant to get
%behavior times close together to make placefields by behavior better, more
%comparable

[frames, txt] = xlsread(xls_file, 1);
try 
    load(pos_file,'x_adj_cm','y_adj_cm')
catch 
    load(pos_file);
    inThisFile = whos('-file',pos_file);
    for ff=1:length(inThisFile); bitNames{ff} = inThisFile(ff).name; end;
    [s,~] = listdlg('PromptString','Select x/y positions:',...
                'ListString',bitNames);
    [whichX, ~] = listdlg('PromptString','Which is the X vector?',...
                'ListString',{bitNames{s(1)}; bitNames{s(2)}}); 
    eval([ 'x_adj_cm = ' bitNames{s(whichX)} ]);
    eval([ 'y_adj_cm = ' bitNames{s(s~=s(whichX))} ]);
end

switch class(column_fix)
    case {'double','single','int'}
        column_fix = double(column_fix);
    case {'str','char'}
        for label=1:size(txt,2)
            if ~isempty(strfind(txt{1,label},column_fix))
                column_fix=label; 
            end
        end    
end
theseFrames = (frames(:,column_fix));
theseX = x_adj_cm(theseFrames);
theseY = y_adj_cm(theseFrames);

prepositions = {'Rightmost', 'Leftmost', 'Highest', 'Lowest',...
                'Earlier', 'Latest','AlignToGInput','AlignToFrame'};
   
figure(505); 
plot( x_adj_cm, y_adj_cm, '.k','MarkerSize',3)
title('Original positions'); hold on
plot( theseX, theseY, '.r','MarkerSize',15)
title([txt{1,column_fix} ', zoom now'])

switch relation
    case {'rightmost', 'leftmost', 'highest', 'lowest'}
        switch relation
            case 'rightmost'
                [~, anchorLap] = max(theseX);
            case 'leftmost'
                [~, anchorLap] = min(theseX);
            case 'highest'
                [~, anchorLap] = max(theseY);
            case 'lowest'
                [~, anchorLap] = min(theseY);
        end  
        anchorXY = [x_adj_cm(theseFrames(anchorLap)), y_adj_cm(theseFrames(anchorLap))];
    case 'AlignToGInput'
        disp('Not yet implemented')
        %[xin, yin]=ginput(1);
        %[whichRel, ~] = listdlg('PromptString','Which is this?',...
        %        'ListString',{'rightmost', 'leftmost','highest','lowest'});
        %switch again?
    case {'Earlier', 'Latest','AlignToFrame'}
        disp('Not yet implemented')
end      

[btwn,~]  = listdlg('PromptString','Adjust between which times?','ListString',txt(1,:));    
[whichFirst, ~] = listdlg('PromptString','Which comes first?',...
    'ListString',{txt{1,btwn(1)}; txt{1,btwn(2)}});    
anchorFrames = [frames(:,btwn(whichFirst)) frames(:,btwn(btwn~=btwn(whichFirst)))];   
%adjustDir = questdlg('Which direction from timestamp?',	'Adjust Dir', ...
%                    'Forward','Backward','Forward'); %and don't need this
newFrame=theseFrames;
for adjustLap = 1:length(theseFrames)
    if adjustLap~=anchorLap
        goodInds = anchorFrames(adjustLap,1):anchorFrames(adjustLap,2);
        [adjustThisMuch, ~] = findclosest2D(x_adj_cm(goodInds), y_adj_cm(goodInds),...
            anchorXY(1), anchorXY(2));
        
        %adjustThisMuch = find(x_adj_cm(anchorFrames(adjustLap):end) < anchorPoint, 1, 'first');  
        newFrame(adjustLap) = anchorFrames(adjustLap,1) + adjustThisMuch - 1;
    end
end
newFrame(newFrame > length(x_adj_cm)) = length(x_adj_cm);
            
figure(555);
plot( x_adj_cm, y_adj_cm, '.k','MarkerSize',3)
title('Adjusted positions, anchor in red'); hold on
plot(x_adj_cm(newFrame),y_adj_cm(newFrame),'.y','MarkerSize',12)
plot(theseX(anchorLap),theseY(anchorLap),'.r','MarkerSize',12)    

frames(:,column_fix) = newFrame;
[newAll] = CombineForExcel(frames, txt);
saveName = [xls_file(1:end-5) '_Adjusted.xlsx'];
if ~exist(saveName,'file')
    xlswrite( saveName, newAll);
else   
    overwrite = input('Already exists. Overwrite? (0/1)') %#ok<NOPRT>
    switch overwrite
        case 0
            disp('not writing file')
            save('luckout.mat','newFrame')
        case 1
            xlswrite( saveName, newAll);
    end
end         
            
end