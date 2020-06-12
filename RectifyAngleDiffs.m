function [anglesRect] = RectifyAngleDiffs(angleDiffs,degOrRad)
% The point of this function is to make things like 90/-270 the same thing

if strcmpi(degOrRad,'rad')
    angleDiffs = rad2deg(angleDiffs);
end

% Lower the angles too big...
angleDiffs(angleDiffs>180) = rem(angleDiffs(angleDiffs>180),360);
angleDiffs(angleDiffs>180) = angleDiffs(angleDiffs>180) - 360;    

% Raise the angles too small
angleDiffs(angleDiffs<-180) = rem(angleDiffs(angleDiffs<-180),360);
angleDiffs(angleDiffs<-180) = angleDiffs(angleDiffs<-180) + 360;   

if any(any(angleDiffs>180)) || any(any(angleDiffs<-180))
    disp('error, bad logic above')
    keyboard
end

if strcmpi(degOrRad,'rad')
    angleDiffs = deg2rad(angleDiffs);
end

anglesRect = angleDiffs;

end