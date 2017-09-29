function AdjustBehaviorTimesLRsplit(pos_file, xls_file, column_fix, relation)
%For taking in a spreadsheet and adjusting a set of frames. Meant to get
%behavior times close together to make placefields by behavior better, more
%comparable
%This version is identical to the other version except it identifies if the
%timestamp is forced or free so it can split by trial direction

%Load timestamps and x/y positions
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

%Handle laziness
if ~exist('column_fix', 'var')
    [column_fix,~]  = listdlg('PromptString','Which frames to adjust?','ListString',txt(1,:));
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

%Find relation, if not given
if ~exist('relation','var')
    alignSame = questdlg('Align all the same way or differently?','Align Same',...
        'Same','Different','Same');
    switch alignSame
        case 'Same'
            numPreps = 1;
        case 'Different'
            numPreps = length(column_fix);
    end

    prepositions = {'Rightmost', 'Leftmost', 'Highest', 'Lowest',...
                'Earlier', 'Latest','AlignToGInput'};%,'AlignToFrame'
   
    for fillPrep = 1:numPreps
        [usePrep(fillPrep),~] = listdlg('PromptString',['How to align ' num2str(fillPrep)...
            ' of ' num2str(numPreps) '?'],'ListString',prepositions);
    end
    
    relation = cell(1,length(column_fix));
    relation(:) = {prepositions{usePrep}}; %So elegant
end

eventOrder = {'Start on maze (start of Forced', 'ForcedChoiceEnter', 'Forced Choice',...
              'Forced Reward', 'Enter Delay', 'Lift barrier (start of free choice)'...
              'FreeChoiceEnter', 'Free Choice', 'Free Reward', 'Leave maze',...
              'Start in homecage', 'Leave homecage'};
forcedEvents = {'Start on maze (start of Forced', 'ForcedChoiceEnter', 'Forced Stem End',...
                'Forced Choice','Forced Reward', 'Enter Delay'};
freeEvents = {'Lift barrier (start of free choice)', 'FreeChoiceEnter', 'Free Stem End',...
              'Free Choice','Free Reward', 'Leave maze'};
          
for cfI = 1:length(column_fix)
    isForced = sum(strcmpi(forcedEvents,txt(1,column_fix(cfI))));
    isFree = sum(strcmpi(freeEvents,txt(1,column_fix(cfI))));
    forcedOrFree(cfI) = find([isForced isFree]);
end

directions = {'l','r'};
forcedFreeCols = [find(strcmpi(txt(1,:),'Forced Trial Type (L/R)')),...
                  find(strcmpi(txt(1,:),'Free Trial Choice (L/R)'))];
%Actually adjust stuff
oldAnchors = [];
adjustedFrames = frames;
for nowCol = 1:length(column_fix)
    for lrSide = 1:2
        
    areGood=0;
    while areGood==0
        theseFrames = frames(:,column_fix(nowCol));
        rightTrialDir = strcmpi(directions(lrSide),txt(2:end,forcedFreeCols(forcedOrFree(nowCol))));
        theseX = x_adj_cm(theseFrames(rightTrialDir));
        theseY = y_adj_cm(theseFrames(rightTrialDir));

        figure(505); 
        plot( x_adj_cm, y_adj_cm, '.k','MarkerSize',3)
        title('Original positions'); hold on
        plot( theseX, theseY, '.r','MarkerSize',12)
        title([txt{1,column_fix(nowCol)} ' - zoom now'])

        anchorLap = 0;
        findAnchor = 1;
        if any(oldAnchors)
            figure(602);
            plot(x_adj_cm, y_adj_cm, '.k','MarkerSize',3)
            hold on
            plot(oldAnchors(:,1), oldAnchors(:,2), '.y', 'MarkerSize',12)
            title('Old Anchors')
            promptq = ['Found old anchor points. Use one for ' txt{1,column_fix(nowCol)} ', dir: ' directions{lrSide} '?'];
            useOA = questdlg(promptq,'Use old anchors','Yes','No','Yes');
            switch useOA
                case 'Yes'
                    figure(602);
                    title('Click near preffered old anchor')
                    [xUse, yUse] = ginput(1);   
                    [idx] = findclosest2D (oldAnchors(:,1), oldAnchors(:,2), xUse, yUse);
                    anchorXY = oldAnchors(idx,:);
                    plot( anchorXY(1), anchorXY(2), 'om', 'MarkerSize', 10)
                    findAnchor = 0;
                case 'No'
                    findAnchor = 1;
            end
        
            close 602;
        end   

        if findAnchor==1
            switch relation{nowCol}
                case {'rightmost', 'leftmost', 'highest', 'lowest'}
                    disp('Needs testing')
                    %{
                    switch relation
                        case 'rightmost'
                            [~, anchorLap] = max(theseX);
                            alignDim = 1;
                        case 'leftmost'
                            [~, anchorLap] = min(theseX);
                            alignDim = 1;
                        case 'highest'
                            [~, anchorLap] = max(theseY);
                            alignDim = 2;
                        case 'lowest'
                            [~, anchorLap] = min(theseY);
                            alignDim = 2;
                    end  
                    anchorXY = [x_adj_cm(theseFrames(anchorLap)), y_adj_cm(theseFrames(anchorLap))];
                    %}
                case 'AlignToGInput'
                    figure(505);
                    [anchorXY(1), anchorXY(2)]=ginput(1);
                    hold on
                    plot(anchorXY(1),anchorXY(2),'.y','MarkerSize',12)
                    hold off
                case {'Earlier', 'Latest','AlignToFrame'}
                    disp('Not yet implemented')
            end
        end
        
        btwn = [];
        while length(btwn)~=2
        [btwn,~]  = listdlg('PromptString','Adjust between which times?','ListString',txt(1,:)); 
        end
        anchorFrames = [frames(:,btwn(1)) frames(:,btwn(2))];
        allLaps = 1:size(anchorFrames,1); keepLaps = ones(size(anchorFrames,1),1);
        keepLaps(allLaps==anchorLap) = 0;
        rightTrialDir = rightTrialDir & keepLaps;
        anchorFrames = anchorFrames(rightTrialDir,:); 
    
        if sum(anchorFrames(1:end,1)>anchorFrames(1:end,2))==size(anchorFrames,1)
            anchorFrames = [anchorFrames(:,2) anchorFrames(:,1)];
        elseif sum(anchorFrames(1:end,1)<anchorFrames(1:end,2))==size(anchorFrames,1)
            %do nothing
        else
            [whichFirst, ~] = listdlg('PromptString','Which comes first?',...
                'ListString',{txt{1,btwn(1)}; txt{1,btwn(2)}}); 
            %anchorFrames = [frames(:,btwn(whichFirst)) frames(:,btwn(btwn~=btwn(whichFirst)))];
            otherOne = [1 2]; otherOne = otherOne(otherOne~=whichFirst);
            anchorFrames = [anchorFrames(:,whichFirst), anchorFrames(:,otherOne)];
        end    

        newFrame=theseFrames(rightTrialDir);
        for adjustLap = 1:size(anchorFrames,1)
            goodInds = anchorFrames(adjustLap,1):anchorFrames(adjustLap,2);
            [adjustThisMuch, ~] = findclosest2D(x_adj_cm(goodInds), y_adj_cm(goodInds),...
                anchorXY(1), anchorXY(2));

            newFrame(adjustLap) = anchorFrames(adjustLap,1) + adjustThisMuch - 1;
        end
        newFrame(newFrame > length(x_adj_cm)) = length(x_adj_cm);

        figure(555);
        plot( x_adj_cm, y_adj_cm, '.k','MarkerSize',3)
        title(['Adjusted positions ' txt{1,column_fix(nowCol)} ' - anchor in red']); hold on
        plot(x_adj_cm(newFrame),y_adj_cm(newFrame),'.y','MarkerSize',12)
        plot(anchorXY(1),anchorXY(2),'.r','MarkerSize',12) 

        %Here somehow need to allow looking at old figures
        coorG = input('Are these points good? (0/1) >');
        switch coorG
            case 1
                areGood=1;
                adjustedFrames(rightTrialDir,column_fix(nowCol)) = newFrame;
            case 0
                areGood=0;
        end
    
        close 505; close 555;
        %need to hold onto anchor for next pass
        %oldAnchors(nowCol,1:2) = anchorXY;
        oldAnchors(size(oldAnchors,1)+1,1:2) = anchorXY;
    end
    end
    
end

[newAll] = CombineForExcel(adjustedFrames, txt);
saveName = [xls_file(1:end-5) '_Adjusted.xlsx'];
%{
if strcmpi(xls_file(end-12:end-5),'adjusted')
    reuse = input('Overwrite existing adjusted file? (0/1)') %#ok<NOPRT>
    switch reuse
        case 1
            xlswrite( xls_file, newAll);
        case 0
            if ~exist(saveName,'file')
                xlswrite( saveName, newAll);
            end
    end
    %}
if exist(saveName,'file') == 2
    fexists=1;
    while fexists==1
        newName = inputdlg('File name already exists, give new name','File name bad',...
                            1,{[saveName(1:end-5) '_2.xlsx']});
        if exist(saveName,'file') == 2
            disp('Nope, try again')
            fexists = 1;
        elseif exist(saveName,'file') == 0
            fexists = 0;
            saveName = newName;
            xlswrite( saveName, newAll);
        end
    end
else   
    xlswrite( saveName, newAll);
end        

end