function [anglesRect] = RectifyAngleDiffs(angleDiffs,degOrRad)
% The point of this function is to make things like 90/-270 the same thing

if strcmpi(degOrRad,'rad')
    angleDiffs = rad2deg(angleDiffs);
end
%anglesRect = angleDiffs;
ba = angleDiffs>180 | angleDiffs<-180; % index % 0.027493 seconds
%ad = angleDiffs(ba);
bb = -360*(angleDiffs./abs(angleDiffs)).*ba; % 0.1
%bb(ba) = 0;

anglesRect = rem(angleDiffs,360); %0.09
anglesRect = anglesRect + bb; % 0.04

%{
tic
% Lower the angles too big...
ba = angleDiffs>180; % 0.026269 seconds
anglesRect = rem(angleDiffs,360); % 0.091474 seconds
%anglesRect(angleDiffs>180) = angleDiffs(angleDiffs>180) - 360;    
anglesRect(ba) = anglesRect(ba) - 360;  % 0.185723 seconds 

% Raise the angles too small
ba = angleDiffs<-180; % 0.023895 seconds
%anglesRect(ba) = rem(angleDiffs(ba),360);
%anglesRect(angleDiffs<-180) = angleDiffs(angleDiffs<-180) + 360;   
anglesRect(ba) = anglesRect(ba) + 360; % 0.173190 seconds  
toc
%}
if any(any(anglesRect>180)) || any(any(anglesRect<-180))
    disp('error, bad logic above')
    keyboard
end

if strcmpi(degOrRad,'rad')
    anglesRect = deg2rad(anglesRect);
end

end