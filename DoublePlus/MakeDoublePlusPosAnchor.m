function [anchorX,anchorY,bounds] = MakeDoublePlusPosAnchor(saveDir)

mazeSize = questdlg('Which size plus maze?','How big is it?','Big (24in)','Small (12in)','Custom','Big (24in)');
switch mazeSize
    case 'Big (24in)'
        realArmLength = 24;
    case 'Small (12in)'
        realArmLength = 12;
    case 'Custom'
        realArmLength = str2double(input('Enter the length of the arms in inches: ','s'));
end

%realArmLength = 24; %inches
realArmWidth = 2.25; %inches
pixPerInch = 10;

v0Anchors={'Center SW','Center NW','Center SE','Center NE',...
           'West N','West S','East N','East S',...
           'South W','South E','North W','North E'};
       
raw = realArmWidth*pixPerInch;
ral = realArmLength*pixPerInch;

%Center
anchorX(1) = -raw/2;
anchorY(1) = -raw/2;

anchorX(2) = -raw/2;
anchorY(2) = raw/2;

anchorX(3) = raw/2;
anchorY(3) = -raw/2;

anchorX(4) = raw/2;
anchorY(4) = raw/2;

%West
anchorX(5) = -ral;
anchorY(5) = raw/2;

anchorX(6) = -ral;
anchorY(6) = -raw/2;

%East
anchorX(7) = ral;
anchorY(7) = raw/2;

anchorX(8) = ral;
anchorY(8) = -raw/2;

%South
anchorX(9) = -raw/2;
anchorY(9) = -ral;

anchorX(10) = raw/2;
anchorY(10) = -ral;

%North
anchorX(11) = -raw/2;
anchorY(11) = ral;

anchorX(12) = raw/2;
anchorY(12) = ral;

bounds{1} = [1 2 5 6];
bounds{2} = [3 4 7 8];
bounds{3} = [1 3 9 10];
bounds{4} = [2 4 11 12];

posAnchorIdeal = [anchorX(:), anchorY(:)];
posAnchorIdeal = (posAnchorIdeal/pixPerInch)*2.54;

if any(saveDir)
    save(fullfile(saveDir,'mainPosAnchor.mat'),'anchorX','anchorY','bounds','posAnchorIdeal')
end

end