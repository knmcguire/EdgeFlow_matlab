%% Edge flow Estimation for forward camera
% by K.N.McGuire
% 20/04/16
% E: k.n.mcguire@tudelft.nl
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc



%% Edge flow algorthim with test data
%Define function parameters
max_frame_horizon=5;
window=8;
max_search_distance=15;
kernel=[1 0 -1];
FOV=[60,50];
image_size = [96 128];
border =max_search_distance+window;

% radperpx or pxperrad for horizontal direction
radperpx=deg2rad(FOV(1))/(image_size(2));
pxperrad=image_size(2)/deg2rad(FOV(1));


%% Load all position data and images
stereoboard=1;

chosen_tracks(1).track = 3;
chosen_tracks(2).track = 2;

matching_error_flow_tot = [];
peaks_hist_tot = [];
velocity_error_forward_tot = [];
velocity_error_sideways_tot = [];

for stereoboard_type = stereoboard
    for track = chosen_tracks(stereoboard_type).track;
        Edgeflow_prepare_data
        
        
        %% calculate OF on images
        calculate_OF_on_images
        
        
        %% Plot velocity to groundtruth
        
        Edgeflow_generate_plots
        
        
        % keyboard
        pause(0.2)
        
        matching_error_flow_t(find(matching_error_flow_t==inf&isnan(matching_error_flow_t))) = 0;
        peaks_hist(find(peaks_hist==inf & isnan(peaks_hist))) = 0;
        velocity_error_forward(find(velocity_error_forward==inf & isnan(velocity_error_forward))) = 0;
        velocity_error_sideways(find(velocity_error_sideways==inf & isnan(velocity_error_sideways))) = 0;
        
%         keyboard
        matching_error_flow_tot = [matching_error_flow_tot; matching_error_flow_t];
        velocity_error_forward_tot = [velocity_error_forward_tot ; velocity_error_forward];
        velocity_error_sideways_tot = [velocity_error_sideways_tot ; velocity_error_sideways];
        peaks_hist_tot = [peaks_hist_tot ; peaks_hist];
        
        clearvars -except max_frame_horizon  window max_search_distance kernel FOV image_size border radperpx...
            matching_error_flow_tot peaks_hist_tot velocity_error_sideways_tot velocity_error_forward_tot ...
            pxperrad stereoboard_type chosen_tracks track stereoboard 
    end
    
end

%%
figure, subplot(2,1,1),
boxplot(velocity_error_forward_tot',peaks_hist_tot')
subplot(2,1,2),
boxplot(velocity_error_sideways_tot,peaks_hist_tot)
ylim([0 0.8])
ylabel('Velocity Error [m/s]')

xlabel('Amount of peaks')

, hold on,


figure
subplot(2,1,1),
boxplot(velocity_error_forward_tot,round(matching_error_flow_tot/100))
subplot(2,1,2),
boxplot(velocity_error_sideways_tot,round(matching_error_flow_tot/100))
ylim([0 0.8])
ylabel('Velocity Error [m/s]')

xlabel('Amount of peaks')

, hold on,