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

%%%%%%%%%%%%%%%%%%%%% Calculate Distance %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calculate displacement for distance
[disp_distance matching_error_distance]=SAD_blockmatching_stereo(window,max_search_distance,Fx_hist_left,Fx_hist_right);

% Calculate distance per column
faulty_distance = zeros(size(disp_distance));

distance=zeros(size(disp_distance));
for k=1:length(disp_distance)
    if disp_distance(k) ~= 0 && disp_distance(k) ~= max_search_distance
        distance(k)=pxperrad*0.06./(abs(disp_distance(k)));
    else
        distance(k)= 0;
        faulty_distance(k) = 1;
    end
end
distance(:,end-border)=0;
distance(:,border)=0;
%Save the smallest min measured
distance_min(i) = min(smooth(distance));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%calculate edgeflow%%%%%%%%%%%%%%%%%%%%

pixelrot.x =0;
pixelrot.y = 0;

[new_parameters,displacement,edge_histogram,frame_previous_number matching_error_flow]=...
    edge_flow_v2(Fx_hist_left,Fy_hist_left,edge_histogram,previous_parameters,...
    frame_previous_number_prev,window,max_search_distance,max_frame_horizon,pixelrot);

pixelshift_yaw_derotate_EF=0;
translation_yaw(i) = new_parameters.translation.x;

pixelshift_yaw_derotate_EF=-deg2rad(yaw_frame(i-frame_previous_number.x)-yaw_frame(i))*pxperrad/frame_previous_number.x;

%Derotation (based on IMU (1)

displacement.x  = displacement.x - pixelshift_yaw_derotate_EF;


%%%%%%%%%%%%%%%%%%%%% Calculate Velocity %%%%%%%%%%%%%%%%%%%%

frequency = 1/(t_frame(i)-t_frame(i-1));
velocity_column_forward=  distance.*displacement.x*frequency;

velocity_x_ptx=[border:image_size(2)-border];
velocity_x_ptx=velocity_x_ptx(find(faulty_distance==0));
velocity_x_pty=velocity_column_forward(velocity_x_ptx);
px=polyfit(velocity_x_ptx,velocity_x_pty,1);
velocity_tot_forward = px(1);
velocity_tot_sideways = (px(2)+px(1)*round(length(velocity_x_ptx)/2))*radperpx;

% keyboard
matching_error_flow_t(i) = mean(matching_error_flow.x);


velocity_tot_forward_plot(i) =   velocity_tot_forward;
velocity_tot_sideways_plot(i) = velocity_tot_sideways;

