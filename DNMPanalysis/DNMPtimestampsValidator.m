function reportedBad = DNMPtimestampsValidator ( pos_file, xls_path, xls_sheet_num )
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
        || any(strfind(txt{1,label},'Trial #')); %#ok<AGROW>
end    

load(pos_file,'xAVI','yAVI')

%msgbox('Click next to bad points, click outside for next')

checkThese = find(dontCheck==0);
reportedBad = cell(1,size(txt,2));
figure; 
for framesColumn = checkThese
    hold off
    plot( xAVI, yAVI, '.k','MarkerSize',3)
    hold on
    theseX = xAVI(frames(:,framesColumn));
    theseY = yAVI(frames(:,framesColumn));
    plot( theseX, theseY, '.r','MarkerSize',15)
    title([txt{1,framesColumn} ', zoom now'])
    howManyBad = input('how many points are bad?') %#ok<NOPRT>
    movingOn=0;
    if howManyBad > 0
    while movingOn==0
        title('Click next to each bad point')
        [xBad, yBad] = ginput(howManyBad);   
        [ idx ] = findclosest2D ( theseX, theseY, xBad, yBad);
        hold on
        plot( theseX(idx), theseY(idx), 'om', 'MarkerSize', 10)
        reportedBad{1,framesColumn} = idx;
        movingOn = input('Are we good? 1/0 for yes/no') %#ok<NOPRT>
    end
    end   
end


end