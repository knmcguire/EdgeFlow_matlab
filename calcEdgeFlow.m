%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%EDGEFLOW%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Edge Histograms
Fx_left= imfilter(I_left,kernel) + imfilter(I_left,fliplr(kernel));
Fy_left= imfilter(I_left,kernel') + imfilter(I_left,fliplr(kernel)');
Fx_right= imfilter(I_right,kernel) + imfilter(I_right,fliplr(kernel));

Fx_hist_left = sum(Fx_left);
Fy_hist_left = sum(Fy_left,2)';
Fx_hist_right = sum(Fx_right);


peaks_hist(i) = numel(findpeaks(Fx_hist_left));

if ~exist('prev_disp_distance','var')
    prev_disp_distance = zeros(1,128);
end


%%%%%%%%%%%%%%%%%%%%% Calculate Distance %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calculate displacement for distance
[disp_distance matching_error_distance]=SAD_blockmatching_stereo(window,max_search_distance,Fx_hist_left,Fx_hist_right,shift_stereo_image);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%calculate edgeflow%%%%%%%%%%%%%%%%%%%%

pixelrot.x =0;
pixelrot.y = 0;

[new_parameters,displacement,edge_histogram,frame_previous_number matching_error_flow]=...
    edge_flow_v2(Fx_hist_left,Fy_hist_left,edge_histogram,previous_parameters,...
    frame_previous_number_prev,window,max_search_distance,max_frame_horizon,pixelrot);

pixelshift_yaw_derotate_EF=0;
translation_yaw(i) = new_parameters.translation.x;


% Calculate distance per column
faulty_distance = zeros(size(disp_distance));
faulty_distance(find(disp_distance<=1)) = 1;%a stereo displacement smaller than 1 is too small resolution to get a valuable distance measurement out of ti

% On the borders, no valuable information is present
faulty_distance(end-max_search_distance:end)=1;
faulty_distance(1:max_search_distance)=1;

distance=zeros(size(disp_distance));
distance(find(faulty_distance==0)) = pxperrad*0.06./disp_distance(find(faulty_distance==0));

%Save the smallest min measured
prev_disp_distance = disp_distance;
pixelshift_yaw_derotate_EF=-deg2rad(yaw_frame(i-frame_previous_number.x)-yaw_frame(i))*pxperrad/frame_previous_number.x;

%Derotation (based on IMU (1))
displacement.x  = displacement.x - pixelshift_yaw_derotate_EF;
displacement.x([1:border,end-border:end]) =0;

%%%%%%%%%%%%%%%%%%%%% Calculate Velocity %%%%%%%%%%%%%%%%%%%%
frequency = 1/(t_frame(i)-t_frame(i-1));

%multiply distance with displacement.
velocity_column_forward=  distance.*displacement.x*frequency;

%Prepare data for linefit
velocity_x_ptx=[1:image_size(2)];
velocity_x_ptx=velocity_x_ptx(find(faulty_distance==0));
velocity_x_pty=velocity_column_forward(find(faulty_distance==0));

px=polyfit(velocity_x_ptx,velocity_x_pty,1);

%TODO: decide weither to use RANSAC or not...
% inlier_threshold = 1;
% inlier_ratio = 0.5;
% if length(velocity_x_ptx)>=2
%     px = ransac([velocity_x_ptx;velocity_x_pty],100,inlier_threshold,inlier_ratio);
% else
%     px = [0;0];
% end

velocity_tot_forward = px(1);
velocity_tot_sideways = (px(2)+px(1)*round(image_size(2)/2))*radperpx;

matching_error_flow_t(i) = mean(matching_error_flow.x);
velocity_tot_forward_plot(i) =   velocity_tot_forward;
velocity_tot_sideways_plot(i) = velocity_tot_sideways;

