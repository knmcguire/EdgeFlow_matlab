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
wf=window*2+1;
make_plots_journal = true;

fig = figure, 

set(fig,'defaultAxesColorOrder',[[ 0 0 0];[0 0 0]]);
subplot(2,1,1),


[AX1,HMSEFB,HNMXMFB] = plotyy(wf,[results_per_windowsize.MSE_x_FB],wf,[results_per_windowsize.nmxm_x_FB]);
hold on,
[AX2,HMSE,HNMXM] = plotyy(wf,[results_per_windowsize.MSE_x],wf,[results_per_windowsize.nmxm_x]);
HVARFB = plot(wf,[results_per_windowsize.var_x_FB]);
HVAR = plot(wf,[results_per_windowsize.var_x]);

AX1(1).YLim = [0 0.1];
AX1(2).YLim = [0 1];
AX2(1).YLim = [0 0.1];
AX2(2).YLim = [0 1];
AX1(2).Visible = 'off';

AX1(1).YLabel.String = ['MSE';'VAR'];
AX2(2).YLabel.String = ['NMXM'];

HMSEFB.LineStyle = '-';
HMSE.LineStyle = '-';
HNMXMFB.LineStyle = '--';
HNMXM.LineStyle = '--';
HVAR.LineStyle = '-.';
HVARFB.LineStyle = '-.';
HMSEFB.Color = 'g';
HNMXMFB.Color = 'g';
HVARFB.Color = 'g';
HMSE.Color = 'b';
HNMXM.Color = 'b';
HVAR.Color = 'b';


subplot(2,1,2),


[AX1,HMSEFB,HNMXMFB] = plotyy(wf,[results_per_windowsize.MSE_y_FB],wf,[results_per_windowsize.nmxm_y_FB]);
hold on,
[AX2,HMSE,HNMXM] = plotyy(wf,[results_per_windowsize.MSE_y],wf,[results_per_windowsize.nmxm_y]);
HVARFB = plot(wf,[results_per_windowsize.var_y_FB]);
HVAR = plot(wf,[results_per_windowsize.var_y]);

AX1(1).YLim = [0 0.02];
AX1(2).YLim = [0 0.7];
AX2(1).YLim = [0 0.02];
AX2(2).YLim = [0 0.7];
% AX1(2).Visible = 'off';

AX1(1).YLabel.String = ['MSE';'VAR'];
AX2(2).YLabel.String = ['NMXM'];

HMSEFB.LineStyle = '-';
HMSE.LineStyle = '-';
HNMXMFB.LineStyle = '--';
HNMXM.LineStyle = '--';
HVAR.LineStyle = '-.';
HVARFB.LineStyle = '-.';
HMSEFB.Color = 'g';
HNMXMFB.Color = 'g';
HVARFB.Color = 'g';
HMSE.Color = 'b';
HNMXM.Color = 'b';
HVAR.Color = 'b';


H_dummy1 = plot(NaN,NaN,'k');
H_dummy2 = plot(NaN,NaN,'--k');
H_dummy3 = plot(NaN,NaN,'-.k');

h=[HMSEFB HMSE, H_dummy1 H_dummy2 H_dummy3];
legend(h, 'Farneback','EdgeFlow','MSE','VAR', 'NMXM','orientation','horizontal' ,'Location', 'northwest')
        legend boxoff
        
        xlabel('window size')


% set(gca,'FontSize',6)

if make_plots_journal
    filename_savevel = sprintf('generated_plots/Edgeflow_Farneback_windowsize_board_%d_data_%d',stereoboard_type,track);
        cleanfigure;
    matlab2tikz([filename_savevel,'.tex'],'height', '\figureheight', 'width', '\figurewidth',...
        'extraaxisoptions',['title style={font={\small\bfseries}},'...
        'legend style={font=\tiny},scaled ticks=false,  tick label style={/pgf/number format/fixed}'])
end