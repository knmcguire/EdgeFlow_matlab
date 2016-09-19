%% Loop and calculate through all images

%% Intialize structures
for(i=1:max_frame_horizon+1)
    edge_histogram(i).x=zeros(1,128);
    edge_histogram(i).y=zeros(1,94);
end

new_parameters.translation.x=0.0;
new_parameters.translation.y=0.0;
new_parameters.divergence.x=0.0;
new_parameters.divergence.y=0.0;
frame_previous_number.x = 1;
frame_previous_number.y = 1;

opticFlow = opticalFlowFarneback;
opticFlow_stereo = opticalFlowFarneback;

%% Loop through images
for i= start_i:end_i
    disp(i)
    
    %Load Images
    filename = strcat(dirname,names{i});
    if stereoboard_type==1
        I=imread(filename);
        I_left=I(1:94,129:256);
        I_right=I(1:94,1:128);
    else
        I=rgb2gray(imread(filename));
        I_left=I(1:94,129:256);
        I_right=I(1:94,1:128);
        
    end
    
    %     shift I_left to compensate for stereocamera shift
    
    if i>start_i+max_frame_horizon
        pixelshift_yaw_derotate = -deg2rad(yaw_frame(i-1)-yaw_frame(i))*pxperrad;
        
        calcEdgeFlow
        
%         figure(2),subplot(3,2,1),imshow(I),subplot(3,1,2),plot(velocity_tot_forward_plot),
%         ylim([-0.5,0.5])
%         subplot(3,1,3),plot(distance*2),hold on,plot(displacement.x*10),plot(velocity_column_forward),plot(polyval(px,[1:128])),hold off
%          ylim([-50,50])

%         keyboard
        if shift_stereo_image<0
            I_left = [I_left(:,1+abs(shift_stereo_image):end),0*ones(size(I_left,1),abs(shift_stereo_image))];
            I_right(:,end+shift_stereo_image+1:end) = 0;
        end
        if shift_stereo_image>0
            I_left = [0*ones(size(I_left,1),abs(shift_stereo_image)),I_left(:,1:end-abs(shift_stereo_image))];
            I_right(:,1:abs(shift_stereo_image)) = 0;
        end
        
        calcFarneback
        
    end
    
    I_left_prev = I_left;
    I_right_prev = I_right;
    edge_histogram(2:end)=edge_histogram(1:end-1);
    frame_previous_number_prev = frame_previous_number;
    previous_parameters =  new_parameters;
    
    
end
velocity_tot_forward_plot(1:max_frame_horizon*2) = 0;
velocity_tot_sideways_plot(1:max_frame_horizon*2) = 0;

velocity_error_forward= abs(velocity_tot_forward_plot(3:end)' - cam_Vz_frame(3:end));
velocity_error_sideways= abs(velocity_tot_sideways_plot(3:end)' - cam_Vx_frame(3:end));
peaks_hist = peaks_hist(3:end)';
matching_error_flow_t = matching_error_flow_t(3:end)';
min_distance = min_distance(3:end)';