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
make_plots_journal = false;
addpath('../matlab2tikz/src');

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
stereoboard=1; % select which stereoboard to choose from (1 and/or 2, see Edgeflow_prepare_data)

% Select which track to choose from to  calculate edgeflow on
chosen_tracks(1).track = [4];
chosen_tracks(2).track = [];

% Intialize arrays for boxplot

fitting=1; %select a fitting type (1: linear line fit, 2: ransac, 3: weighted linefit (experimental)

for window = 1:9
    for stereoboard_type = stereoboard
        for track = chosen_tracks(stereoboard_type).track;
            
            % Prepare the images, groundtruth data and calibration
            Edgeflow_prepare_data
            
            
            %% calculate optical flow on images
            calculate_OF_on_images
            
            %% Plot velocity to groundtruth
            
            Edgeflow_generate_plots
            calculate_quality_values
            %             keyboard
            
            pause(0.2)
            
            % Save data for statical analysis
            
            
            results_per_windowsize(window).nmxm_x = nmxm_x;
            results_per_windowsize(window).nmxm_x_FB = nmxm_x_FB;
            results_per_windowsize(window).nmxm_y= nmxm_y;
            results_per_windowsize(window).nmxm_y_FB = nmxm_y_FB;
            
            results_per_windowsize(window).MSE_x = MSE_x;
            results_per_windowsize(window).MSE_x_FB = MSE_x_FB;
            results_per_windowsize(window).MSE_y = MSE_y;
            results_per_windowsize(window).MSE_y_FB = MSE_y_FB;
            
            results_per_windowsize(window).var_x = var_x;
            results_per_windowsize(window).var_x_FB = var_x_FB;
            results_per_windowsize(window).var_y = var_y;
            results_per_windowsize(window).var_y_FB = var_y_FB;
            
            
            clearvars -except max_frame_horizon  window max_search_distance kernel FOV image_size border radperpx...
                matching_error_flow_tot ...
                pxperrad stereoboard_type chosen_tracks track stereoboard fitting fix make_plots_journal ...
                results_per_windowsize
        end
        
    end
end

%% Make boxplots of results
window= 1:9;
make_plots_journal = true;

figure, subplot(3,2,1), plot(window*2+1,[results_per_windowsize.MSE_x_FB],'g'), hold on,plot(window*2+1,[results_per_windowsize.MSE_x]); %xlim([0 9])
ylabel MSE
title x

ylim([0 0.1])
box off

subplot(3,2,2), plot(window*2+1,[results_per_windowsize.MSE_y_FB],'g'), hold on,plot(window*2+1,[results_per_windowsize.MSE_y]); %xlim([0 9])
title y
ylim([0 0.1])
box off

legend Farneback EdgeFlow
legend boxoff

subplot(3,2,3), plot(window*2+1,[results_per_windowsize.nmxm_x_FB],'g'), hold on,plot(window*2+1,[results_per_windowsize.nmxm_x]); %xlim([0 9])
ylabel NMXM
ylim([0 1])
box off

subplot(3,2,4), plot(window*2+1,[results_per_windowsize.nmxm_y_FB],'g'), hold on,plot(window*2+1,[results_per_windowsize.nmxm_y]); %xlim([0 9])
ylim([0 1])
box off


subplot(3,2,5), plot(window*2+1,[results_per_windowsize.var_x_FB],'g'), hold on,plot(window*2+1,[results_per_windowsize.var_x]);%xlim([0 9])

ylim([0 0.05])
box off

ylabel VAR
xlabel('window size')


subplot(3,2,6), plot(window*2+1,[results_per_windowsize.var_y_FB],'g'), hold on,plot(window*2+1,[results_per_windowsize.var_y]);%xlim([0 9])
ylim([0 0.05])
box off

xlabel('window size')
set(gca,'FontSize',6)

if make_plots_journal
    filename_savevel = sprintf('generated_plots/Edgeflow_Farneback_windowsize_board_%d_data_%d',stereoboard_type,track);
    %     cleanfigure;
    matlab2tikz([filename_savevel,'.tex'],'height', '\figureheight', 'width', '\figurewidth',...
        'extraaxisoptions',['title style={font={\small\bfseries}},'...
        'legend style={font=\tiny},scaled ticks=false,  tick label style={/pgf/number format/fixed}'])
end