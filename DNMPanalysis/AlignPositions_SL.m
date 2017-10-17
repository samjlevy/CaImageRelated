function AlignPositions_SL (RoomStr)%, varargin)%base_session, reg_session,
%Future work: align everything together; align to start base by getting
%base session coordinates for choice and start points, look at angle
%difference, align to that; base session points can be saved as an initial
%register, everything else adjusted to them
%for now, all we're doing is rotating everything the same way
load('Pos_brain.mat')
SR=20;

%Rotate to 0
[rot_x,rot_y,rotang] = rotate_traj(x,y);
disp(num2str(rotang))

%Convert to CM
Pix2Cm = Pix2CMlist (RoomStr);
x_adj_cm = rot_x.*Pix2Cm;
y_adj_cm = rot_y.*Pix2Cm;

%Speed for each
dx = diff(x_adj_cm);
dy = diff(y_adj_cm);
speed = hypot(dx,dy)*SR;


%Holdover overhead (probably)
xmax = max(x_adj_cm);
xmin = min(x_adj_cm);
ymax = max(y_adj_cm);
ymin = min(y_adj_cm);    

PSAbool = PSAboolAdjusted;

save('Pos_align.mat','x_adj_cm','y_adj_cm','xmin','xmax','ymin','ymax',...
                'speed', 'PSAbool');
            
            
            %{
if strcmpi(base_session.Location,reg_session.Location)
    %Rotate, save anchor points
end

%base_pos_file = 'Pos_brain.mat';
%reg_pos_file = base_pos_file;
%already_rotated_flag=0; 

for j = 1:length(varargin)
   switch varargin{j}
       case 'pos_file'
           reg_pos_file = varargin{j+1};
       case 'already_rotated'
           already_rotated_flag = 1;
   end
end

base_session.Pix2Cm = Pix2CMlist ( base_session.Room );
reg_session.Pix2Cm = Pix2CMlist ( reg_session.Room );

 
cd(base_session.Location)
base_brain_pos = load(base_pos_file);
cd(reg_session.Location)
reg_brain_pos = load(reg_pos_file);

%Rotate session to base session
disp('Assuming base session is rotated correctly; if not, rerun on base')
%Steps:
    %Find original alignment of base session; could load it?
    %Get alignment of sessiong we're registering
    %Calculate angle difference
    %Rotate reg session
    %Show both for approval
[rotx, roty, rot_ang] = rotate_traj(x,y,rot_ang);  
figure;
plot(base_session.x, base_session.y,'.');
title('Base positions; select middle of 1) CHOICE then 2) START regions', 'fontsize', 12);
[basex,basey] = ginput(2); 

 % Get ecdfs of all x and y points
    [sesh(j).e_fx, sesh(j).e_x] = ecdf(x_for_limits);
    [sesh(j).e_fy, sesh(j).e_y] = ecdf(y_for_limits);
    % Find limits that correspond to ratio_use (e.g. if ratio_use = 0.95,
    % look for the x value that corresponds to 0.025 and 0.975)
    xbound{j}(1) = sesh(j).e_x(findclosest((1-ratio_use)/2,sesh(j).e_fx));
    xbound{j}(2) = sesh(j).e_x(findclosest(1 - (1-ratio_use)/2,sesh(j).e_fx));
    ybound{j}(1) = sesh(j).e_y(findclosest((1-ratio_use)/2,sesh(j).e_fy));
    ybound{j}(2) = sesh(j).e_y(findclosest(1 - (1-ratio_use)/2,sesh(j).e_fy));
    % Calculate the span and get the ratio to the base span
    span_x(j) = xbound{j}(2) - xbound{j}(1);
    span_y(j) = ybound{j}(2) - ybound{j}(1);
    if j == 1
        span_x_ratio = 1;
        span_y_ratio = 1;
    elseif j > 1
        span_x_ratio = span_x(j)/span_x(1);
        span_y_ratio = span_y(j)/span_y(1);
    end
    
    % Linearly adjust all the coordinates to match - use all position data!
    sesh(j).x_adj = (sesh(j).rot_x - xbound{j}(1))/span_x_ratio + xmin;
    sesh(j).y_adj = (sesh(j).rot_y - ybound{j}(1))/span_y_ratio + ymin;
    
    
xmax = max(x_all);
xmin = min(x_all);
ymax = max(y_all);
ymin = min(y_all);
    
%}


end