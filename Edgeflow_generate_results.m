%% Edge flow Estimation for forward camera
% by K.N.McGuire
% 20/04/16
% E: k.n.mcguire@tudelft.nl
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc

%save plots of journal
make_plots_journal = true;
addpath('../matlab2tikz/src');

%% Edge flow algorthim with test data
%Define function parameters
max_frame_horizon=5;
window=5;
max_search_distance=15;
kernel=[1 0 -1];
FOV=[60,50];
image_size = [96 128];
border =max_search_distance+window;

% radperpx or pxperrad for horizontal direction
radperpx=deg2rad(FOV(1))/(image_size(2));
pxperrad=image_size(2)/deg2rad(FOV(1));


%% Load all position data and images
stereoboard=1; % select which stereoboard to choose from (1 and/or 2, see Edgeflow_prepare_data)

% Select which track to choose from to  calculate edgeflow on
chosen_tracks(1).track = [4,16];
chosen_tracks(2).track = [];

% Intialize arrays for boxplot
matching_error_flow_tot = [];
peaks_hist_tot = [];
velocity_error_forward_tot = [];
velocity_error_sideways_tot = [];
mean_distance_tot = [];

fitting=1; %select a fitting type (1: linear line fit, 2: ransac, 3: weighted linefit (experimental)

for stereoboard_type = stereoboard
    for track = chosen_tracks(stereoboard_type).track;
        
        % Prepare the images, groundtruth data and calibration
        Edgeflow_prepare_data
        
        
        %% calculate optical flow on images
        calculate_OF_on_images
        
        %% Plot velocity to groundtruth
        calculate_quality_values
        Edgeflow_generate_plots
        
        keyboard
        
        pause(0.2)
        
        % Save data for statical analysis
        matching_error_flow_t(find(matching_error_flow_t==inf&isnan(matching_error_flow_t))) = 0;
        peaks_hist(find(peaks_hist==inf & isnan(peaks_hist))) = 0;
        velocity_error_forward(find(velocity_error_forward==inf & isnan(velocity_error_forward))) = 0;
        velocity_error_sideways(find(velocity_error_sideways==inf & isnan(velocity_error_sideways))) = 0;
        
        matching_error_flow_tot = [matching_error_flow_tot; matching_error_flow_t];
        velocity_error_forward_tot = [velocity_error_forward_tot ; velocity_error_forward];
        velocity_error_sideways_tot = [velocity_error_sideways_tot ; velocity_error_sideways];
        peaks_hist_tot = [peaks_hist_tot ; peaks_hist];
        mean_distance_tot = [mean_distance_tot; mean_distance];
        
        clearvars -except max_frame_horizon  window max_search_distance kernel FOV image_size border radperpx...
            matching_error_flow_tot peaks_hist_tot velocity_error_sideways_tot velocity_error_forward_tot mean_distance_tot ...
            pxperrad stereoboard_type chosen_tracks track stereoboard fitting fix make_plots_journal
    end
    
end

%% Make boxplots of results

figure, subplot(2,1,1),
boxplot(velocity_error_forward_tot',peaks_hist_tot')
subplot(2,1,2),
boxplot(velocity_error_sideways_tot,peaks_hist_tot)
ylim([0 0.3])
ylabel('Velocity Error [m/s]')

xlabel('Amount of peaks')
title('Boxplot y-direction')

, hold on,


figure
subplot(2,1,1),
boxplot(velocity_error_forward_tot,round(mean_distance_tot*2)/2)
ylim([0 0.3])
xlim([1.5 7.5])
ylabel('Vel Error (x) [m/s]')
% title('Boxplot  x-direction')

subplot(2,1,2),
boxplot(velocity_error_sideways_tot,round(mean_distance_tot*2)/2)
ylim([0 0.3])
xlim([1.5 7.5])

ylabel('Vel Error (y) [m/s]')
xlabel('Mean depth measured [m]')
% title('Boxplot  y-direction')
, hold on,

if (make_plots_journal)
    filename_savevel = sprintf('generated_plots/boxplot1',stereoboard_type,track);
    %     printpdf(gcf,[filename_savevel,'.pdf'])
    %
    cleanfigure;
    matlab2tikz([filename_savevel,'.tex'],'height', '\figureheight', 'width', '\figurewidth',...
        'extraaxisoptions',['title style={font={\small\bfseries}},'...
        'legend style={font=\tiny},'])
end
