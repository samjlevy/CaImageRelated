function reportedBad = DNMPtimestampsValidator( pos_file, xls_path, xls_sheet_num )
%Loads an excell file and position file and position file, plots each type
%of behavior timestamp (by lap dir?) onto a map of the positions to
%highlight where they are for confirmation that they are right. 
%Additionally allows selecting a position (will snap just to highlighted
%ones) to tell you which was off. 
%Should work for both AVI times and brain times 

if ~exist('xls_sheet_num','var')
    xls_sheet_num = 1;
end    

[frames, txt] = xlsread(xls_path, xls_sheet_num);
for label=1:size(frames,2)
    dontCheck(label) = any(strfind(txt{1,label},'L/R'))...
        || any(strfind(txt{1,label},'Trial #'))...
        || any(strfind(txt{1,label},'Trial Type')); %#ok<AGROW>
end    

try
    load(pos_file); xAVI = x; yAVI = y;
catch
    %['xAVI','yAVI'] = Reloader(pos_file,'Select x/y positions') 
    load(pos_file);
    inThisFile = whos('-file',pos_file);
    for ff=1:length(inThisFile); bitNames{ff} = inThisFile(ff).name; end;
    [s,~] = listdlg('PromptString','Select x/y positions:',...
                'ListString',bitNames);
    [whichX, ~] = listdlg('PromptString','Which is the X vector?',...
                'ListString',{bitNames{s(1)}; bitNames{s(2)}}); 
    eval([ 'xAVI = ' bitNames{s(whichX)} ';' ]);
    eval([ 'yAVI = ' bitNames{s(s~=s(whichX))} ';' ]);
end

if ~exist('FToffset','var')
    FToffset = 0;
end    
%msgbox('Click next to bad points, click outside for next') 
    
    
checkThese = find(dontCheck==0);
reportedBad = cell(1,size(txt,2));
figure; 
for framesColumn = checkThese
    hold off
    plot( xAVI, yAVI, '.k','MarkerSize',3)
    hold on
    theseFrames = (frames(:,framesColumn)) - FToffset;
    theseX = xAVI(theseFrames(theseFrames<length(xAVI)));
    theseY = yAVI(theseFrames(theseFrames<length(yAVI)));
    plot( theseX, theseY, '.r','MarkerSize',15)
    title([txt{1,framesColumn} ', zoom now'])
    howManyBad = input('how many points are bad?') %#ok<NOPRT>
    movingOn=0;
    if howManyBad > 0
    while movingOn==0
        title('Click next to each bad point')
        for bb = 1:howManyBad
            [xBad(bb), yBad(bb)] = ginput(1);   
            [ idx(bb) ] = findclosest2D ( theseX, theseY, xBad(bb), yBad(bb));
            hold on
            plot( theseX(idx(bb)), theseY(idx(bb)), 'om', 'MarkerSize', 10)
            reportedBad{1,framesColumn}(bb) = idx(bb);
        end
        movingOn = input('Are we good? 1/0 for yes/no') %#ok<NOPRT>
    end
    end   
end


end