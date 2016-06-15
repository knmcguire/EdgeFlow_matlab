function [cam_Vx_frame, cam_Vz_frame, yaw_frame, t_frame] = getOptiTrack(track,database_loc)

% keyboard

%% load image timing data

time=fopen([database_loc num2str(track) '\timing.dat']);


    tline = fgets(time);

tims=textscan(time,'%f	%f');

fclose(time);

% check if recording slider was onn
check_image=tims{2};
t_frame_uncheck = tims{1};
t_frame = [];


for i =1:length(check_image)
    if check_image(i) == 1
t_frame=[t_frame;t_frame_uncheck(i)];
    end
% keyboard
end
% remove either first or last timestamp to match number of images
% t_frame = t_frame(1:end-1);


%% load optitrack data
position=fopen([database_loc num2str(track) '\position.dat']);

tline = fgets(time);

pos=textscan(position,'%f	%f	%f	%f	%f	%f	%f	%f');

fclose(position);

% [time optishit X Y Z roll pitch yaw]
t = pos{1};
X = pos{3};
Y = pos{4};
Z = pos{5};
roll = pos{6};
pitch = pos{7};
yaw = pos{8};
% plot(pos{3})
%% match images to optitrack
index_frame = t_frame;
frame_number = t;
prev_index_frame = 1;

for i = 1:length(t_frame)
    
    [time_error,index_frame(i)] = min(abs(t_frame(i)-t));
    
    frame_number(prev_index_frame:index_frame(i)) = i-1;
    prev_index_frame = index_frame(i);
    
end

%% smooth data
X = smooth(X,5);
Y = smooth(Y,5);
Z = smooth(Z,5);
roll = smooth(roll,19);
pitch = smooth(pitch,19);
yaw = smooth(yaw,15);

%% estimate velocity
Vx = [diff(X)./diff(t);0];
Vy = [diff(Y)./diff(t);0];
Vz = [diff(Z)./diff(t);0];
yaw_rate = [diff(yaw)./diff(t);0];

cam_Vx = Vx.*cos(yaw*pi/180)-Vz.*sin(yaw*pi/180);
cam_Vz = Vz.*cos(yaw*pi/180)+Vx.*sin(yaw*pi/180);

cam_Vx_frame = cam_Vx(index_frame); % lateral velocity (positive ->)
cam_Vz_frame = cam_Vz(index_frame); % longitudinal velocity (positive is forward)

cam_X = X.*cos(yaw*pi/180)-Z.*sin(yaw*pi/180);
cam_Z = Z.*cos(yaw*pi/180)+X.*sin(yaw*pi/180);

% cam_X_obst = X_obst.*cos(yaw*pi/180)-Z_obst.*sin(yaw*pi/180);
% cam_Z_obst = -Z_obst.*cos(yaw*pi/180)-X_obst.*sin(yaw*pi/180);

% cam_X_obst_frame = cam_X_obst(index_frame);
% cam_Z_obst_frame = cam_Z_obst(index_frame);

cam_X_frame = cam_X(index_frame);
cam_Z_frame = cam_Z(index_frame);
 yaw_frame = yaw(index_frame);
 
 yaw_rate_frame = [diff(yaw_frame);0];
 
% figure(1)
% subplot(3,1,1)
% plot(cam_Vz_frame(10:end))
% subplot(3,1,2)
% plot(cam_Vx_frame(10:end))
% subplot(3,1,3)
% plot(yaw_rate_frame)

time = t_frame;