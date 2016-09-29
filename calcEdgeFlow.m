%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%EDGEFLOW%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make Edge Histograms 
%(Note that this is same principle as a oneway conv2 implemitation)

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

displacement_stereo_global=SAD_blockmatching_full_image(Fx_hist_left,Fx_hist_right,max_search_distance,shift_stereo_image);


pixelshift_yaw_derotate_EF=0;
translation_yaw(i) = new_parameters.translation.x;

%%
% Calculate distance per column
faulty_distance = zeros(size(disp_distance));
faulty_distance(find(disp_distance<2)) = 1;%a stereo displacement smaller than 1 is too small resolution to get a valuable distance measurement out of ti

% On the borders, no valuable information is present

faulty_distance(end-max_search_distance-window-1:end)=1;
faulty_distance(1:max_search_distance+window+1)=1;

distance=zeros(size(disp_distance));
distance(find(faulty_distance==0)) = pxperrad*0.06./disp_distance(find(faulty_distance==0));

%Save the mean distance measured
mean_distance(i) = mean(distance(find(faulty_distance==0)));

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

if(fitting==1)
    
    px=polyfit(velocity_x_ptx,velocity_x_pty,1);
end

if (fitting==2)
    %TODO: decide weither to use RANSAC or not...
    inlier_threshold = 1;
    inlier_ratio = 0.5;
    if length(velocity_x_ptx)>=2
        px = ransac([velocity_x_ptx;velocity_x_pty],100,inlier_threshold,inlier_ratio);
    else
        px = [0;0];
    end
end

if fitting ==3
    weights = (1.1- matching_error_flow.x(find(faulty_distance==0))/max(matching_error_flow.x(find(faulty_distance==0))));
    weights_plot = (1.1- matching_error_flow.x/max(matching_error_flow.x));
    result=fit(velocity_x_ptx',velocity_x_pty','poly1','Weights',weights);
    px(1)=result.p1;
    px(2)=result.p2;
end

%%
% distance_stereo_global =  pxperrad*0.06./(displacement_stereo_global );
distance_stereo_global = (mean(distance));

velocity_tot_forward_global = new_parameters.divergence.x * distance_stereo_global * frequency;
velocity_tot_sideways_global = (new_parameters.translation.x+new_parameters.divergence.x*round(image_size(2)/2))*radperpx * distance_stereo_global * frequency;


% keyboard
velocity_tot_forward_pixelwise = px(1);
velocity_tot_sideways_pixelwise = (px(2)+px(1)*round(image_size(2)/2))*radperpx;

matching_error_flow_t(i) = mean(matching_error_flow.x);
velocity_tot_forward_plot(i) =   velocity_tot_forward_pixelwise;
velocity_tot_sideways_plot(i) = velocity_tot_sideways_pixelwise;
velocity_tot_forward_global_plot(i) =   velocity_tot_forward_global;
velocity_tot_sideways_global_plot(i) = velocity_tot_sideways_global;
