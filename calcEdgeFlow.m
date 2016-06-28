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

distance=zeros(size(disp_distance));
for k=1:length(disp_distance)
    if k>border && k<length(disp_distance)-border&&prev_disp_distance(k) ~= 0 && abs(prev_disp_distance(k)) < max_search_distance && abs(displacement.x(k)) < max_search_distance
        %    if prev_disp_distance(k) ~= 0 && abs(prev_disp_distance(k)) < max_search_distance && abs(displacement.x(k)) < max_search_distance
        
        distance(k)=pxperrad*0.06./(abs(prev_disp_distance(k)));
    else
        distance(k)= 0;
        faulty_distance(k) = 1;
    end
    abs(displacement.x(k))
    
end
%Save the smallest min measured
distance_min(i) = min(smooth(distance));
prev_disp_distance = disp_distance;
pixelshift_yaw_derotate_EF=-deg2rad(yaw_frame(i-frame_previous_number.x)-yaw_frame(i))*pxperrad/frame_previous_number.x;

%Derotation (based on IMU (1)

displacement.x  = displacement.x - pixelshift_yaw_derotate_EF;
displacement.x([1:border,end-border:end]) =0;

%%%%%%%%%%%%%%%%%%%%% Calculate Velocity %%%%%%%%%%%%%%%%%%%%

frequency = 1/(t_frame(i)-t_frame(i-1));
velocity_column_forward=  distance.*displacement.x;

velocity_x_ptx=[1:image_size(2)];
velocity_x_ptx=velocity_x_ptx(find(faulty_distance==0));
velocity_x_pty=velocity_column_forward(velocity_x_ptx);

% px=polyfit(velocity_x_ptx,velocity_x_pty,1);

inlier_threshold = 1;
inlier_ratio = 0.5;
if length(velocity_x_ptx)>=2
    px = ransac([velocity_x_ptx;velocity_x_pty],100,inlier_threshold,inlier_ratio);
else
    px = [0;0];
end


velocity_tot_forward = px(1)*frequency;
velocity_tot_sideways = (px(2)+px(1)*round(length(velocity_x_ptx)/2))*radperpx*frequency;

matching_error_flow_t(i) = mean(matching_error_flow.x);


velocity_tot_forward_plot(i) =   velocity_tot_forward;
velocity_tot_sideways_plot(i) = velocity_tot_sideways;
% figure(2),imshow(I_left)
% figure(1),subplot(3,1,1),plot(edge_histogram(1).x(5:end-5)),hold on, plot(edge_histogram(2).x(5:end-5)), hold off
% subplot(3,1,2),plot(displacement.x), hold on, plot(distance), plot(faulty_distance), hold off;
% subplot(3,1,3),plot(velocity_column_forward),hold on, line([0 128],[px(2) px(1)*128+px(2)]),%line([0 128],[pxr(2) pxr(1)*128+pxr(2)]),
% hold off
% ylim([-10 10])
% pause(0.5)