function [xRotated,yRotated] = RotatePts(ptsX,ptsY,degRotate)
%Assumes degRotate is in degrees, not radians

allAngles = atan2(ptsX(:),ptsY(:));
allDistances = hypot(ptsX,ptsY);

rotatedAngles = allAngles + deg2rad(degRotate);

%Rectify; maybe doesn't matter?
rotatedAngles(rotatedAngles > pi) = rotatedAngles(rotatedAngles > pi) - 2*pi;
rotatedAngles(rotatedAngles < -pi) = rotatedAngles(rotatedAngles < -pi) + 2*pi;

%Convert back to pts
[yRotated,xRotated] = pol2cart(rotatedAngles,allDistances); %For some reason these come out wrong?

%{

figure; plot(ptsX,ptsY,'*r')
hold on
plot(xRotated,yRotated,'*b')
for pp = 1:size(ptsX,1); plot([ptsX(pp) xRotated(pp)],[ptsY(pp) yRotated(pp)],'m'); end


plot([min([ptsX(:); xRotated(:)]) max([ptsX(:); xRotated(:)])],[0 0],'k')
plot([0 0],[min([ptsY(:); yRotated(:)]) max([ptsY(:); yRotated(:)])],'k')
%}
end
