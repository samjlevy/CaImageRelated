function [anglesRect] = RectifyAngleDiffs(angleDiffs,degOrRad)
% The point of this function is to make things like 90/-270 the same thing

if strcmpi(degOrRad,'rad')
    angleDiffs = rad2deg(angleDiffs);
end
anglesRect = angleDiffs;

% Lower the angles too big...
anglesRect(angleDiffs>180) = rem(angleDiffs(angleDiffs>180),360);
anglesRect(angleDiffs>180) = angleDiffs(angleDiffs>180) - 360;    

% Raise the angles too small
anglesRect(angleDiffs<-180) = rem(angleDiffs(angleDiffs<-180),360);
anglesRect(angleDiffs<-180) = angleDiffs(angleDiffs<-180) + 360;   

if any(any(anglesRect>180)) || any(any(anglesRect<-180))
    disp('error, bad logic above')
    keyboard
end

if strcmpi(degOrRad,'rad')
    anglesRect = deg2rad(anglesRect);
end

%anglesRect = angleDiffs;

end