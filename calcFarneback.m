
%%%%%%%%%%%%%%%%%%%%%%%%%FARNEBACK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% calculate stereo dense map
estimateFlow(opticFlow_stereo,I_right_prev);
stereo = estimateFlow(opticFlow_stereo,I_left_prev);
reset(opticalFlowFarneback);
stereo_displacement = double(stereo.Vx);

% Select on which image points to use for the line fit
faulty_distance = zeros(size(stereo_displacement));
faulty_distance(find(stereo_displacement<=1)) = 1; %a stereo displacement smaller than 1 is too small resolution to get a valuable distance measurement out of ti

% From disparity to distance[m]
% put borders on zero
faulty_distance(:,end-10:end)=1;
faulty_distance(:,1:10)=1;
faulty_distance(end-10:end,:)=1;
faulty_distance(1:10,:)=1;

distance_FB=zeros(size(stereo_displacement));
distance_FB(find(faulty_distance==0)) = pxperrad*0.06./stereo_displacement(find(faulty_distance==0));

% Calculate dense flow (over entire image)
flow = estimateFlow(opticFlow,I_left);
V_FB_OF = flow.Vx;

%Derotation (based on IMU (1) or flow(2))
V_FB_OF = V_FB_OF - pixelshift_yaw_derotate;

% Calculate velocity (forward and sideways)
frequency = 1/(t_frame(i)-t_frame(i-1));
velocity_column_forward_FB= distance_FB.*V_FB_OF*frequency;
velocity_x_ptx=repmat([1:128],[94 1]);
velocity_x_pty=velocity_column_forward_FB;

% select the points to use for linefit
velocity_x_ptx=velocity_x_ptx(find(faulty_distance==0));
velocity_x_pty=velocity_x_pty(find(faulty_distance==0));

%Linefit with Polyfit
px=polyfit(velocity_x_ptx,velocity_x_pty,1);
velocity_tot_forward_FB = px(1);
velocity_tot_sideways_FB = (px(2)+px(1)*round(image_size(2)/2))*radperpx;

%     Save for plotting afterwards
velocity_tot_forward_FB_plot(i) = velocity_tot_forward_FB;
velocity_tot_sideways_FB_plot(i) = velocity_tot_sideways_FB;