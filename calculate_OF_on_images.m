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


%parameters for Farneback optical flow
OF_Farneback = opticalFlowFarneback;
OF_Farneback_stereo = opticalFlowFarneback;

OF_Farneback.NeighborhoodSize = window*2+1;
OF_Farneback.NumPyramidLevels = 1;
OF_Farneback.NumIterations = 1;

OF_Farneback_stereo.NeighborhoodSize = window*2+1;
OF_Farneback_stereo.NumPyramidLevels = 1;
OF_Farneback_stereo.NumIterations = 1;


%parameters for Lucas Kanade optical flow

%no possiblity to change windowsize???

OF_LK = opticalFlowLK;
OF_LK_stereo = opticalFlowLK;


distance_gradient_plot = [];

if make_video ==true
    writerObj = VideoWriter('generated/edgeflow.avi'); % Name it.
    writerObj.FrameRate = 10; % How many frames per second.
    open(writerObj);
end

%% Loop through images
for i= start_i:end_i
    disp(i)
    
    %Load Images
    filename = strcat(dirname,names{i});
    if stereoboard_type==1
        I=imread(filename);
        I_left=I(1:96,129:256);
        I_right=I(1:96,1:128);
    else
        I=rgb2gray(imread(filename));
        I_left=I(1:96,129:256);
        I_right=I(1:96,1:128);
        
    end
    
    
    if i>start_i+max_frame_horizon
        %     shift I_left to compensate for stereocamera shift
        pixelshift_yaw_derotate = -deg2rad(yaw_frame(i-1)-yaw_frame(i))*pxperrad;
        
        %% Calculate Edgeflow
        
        calcEdgeFlow
        
        if make_video ==true
            
            figure(3)
            %         set(gcf,'units','normalized','outerposition',[0 0 1 1])
            ,subplot(2,2,1),imshow(I)
            title('stereo image')
            subplot(2,2,2),
            yyaxis left
            plot(edge_histogram(1).x,'b'), hold on,
            plot(edge_histogram(2).x,'r')
            hold off
            set(gca,'YTick',[])
            
            %         yyaxis right
            yyaxis right
            plot(displacement.x,'Color',[0.5 0 0.5]);hold on
            plot(zeros(1,128),'k:');
            xlim([20 100])
            ylim([-5 5])
            hold off
            set(gca,'XTick',[])
            set(gca,'YTick',[])
            
            title('EdgeFlow')
            
            Fx_right= imfilter(I_right,kernel) + imfilter(I_right,fliplr(kernel));
            
            Fx_hist_right = sum(Fx_right);
            subplot(2,2,3),
            yyaxis left
            
            plot(edge_histogram(1).x,'b'), hold on,
            plot([Fx_hist_right(shift_stereo_image:end)],'g')
            hold off
            set(gca,'YTick',[])
            
            yyaxis right
            
            plot(disp_distance,'Color',[0 0.5 0.5])
            ylim([0 10])
            hold off
            xlim([20 100])
            set(gca,'XTick',[])
            set(gca,'YTick',[])
            
            title('EdgeStereo')
            
            if i>max_frame_horizon*2
                subplot(2,2,4),plot(velocity_tot_forward_plot(max_frame_horizon*2:i))
                hold on
                plot(velocity_tot_sideways_plot(max_frame_horizon*2:i))
                ylim([-1 1])
                ylabel [M/s]
                
                hold off
                title('velocity by Edge-FS')
                
                
            end
            
            pause(0.1)
            frame = getframe(gcf); % 'gcf' can handle if you zoom in to take a movie.
            writeVideo(writerObj, frame);
        end
        
        %% Calculate Farneback
        % Shift stereo images for Farneback (Note that this is done within
        % the code of EdgeFlow already)
        if shift_stereo_image<0
            I_left = [I_left(:,1+abs(shift_stereo_image):end),0*ones(size(I_left,1),abs(shift_stereo_image))];
            I_right(:,end+shift_stereo_image+1:end) = 0;
        end
        if shift_stereo_image>0
            I_left = [0*ones(size(I_left,1),abs(shift_stereo_image)),I_left(:,1:end-abs(shift_stereo_image))];
            I_right(:,1:abs(shift_stereo_image)) = 0;
        end
        
        calcFarneback
        calcLucasKanade
        
    end
    
    % Save values for next loop
    I_left_prev = I_left;
    I_right_prev = I_right;
    edge_histogram(2:end)=edge_histogram(1:end-1);
    frame_previous_number_prev = frame_previous_number;
    previous_parameters =  new_parameters;
    
    
end
if make_video ==true
    
    close(writerObj); % Saves the movie.
end
%Prepare values for plotting
velocity_tot_forward_plot(1:max_frame_horizon*2) = 0;
velocity_tot_sideways_plot(1:max_frame_horizon*2) = 0;

velocity_error_forward = abs(velocity_tot_forward_plot(3:end)' - cam_Vz_frame(3:end));
velocity_error_sideways = abs(velocity_tot_sideways_plot(3:end)' - cam_Vx_frame(3:end));
velocity_error_forward_glob = abs(velocity_tot_forward_global_plot(3:end)' - cam_Vz_frame(3:end));
velocity_error_sideways_glob = abs(velocity_tot_sideways_global_plot(3:end)' - cam_Vx_frame(3:end));
peaks_hist = peaks_hist(3:end)';
matching_error_flow_t = matching_error_flow_t(3:end)';
mean_distance = mean_distance(3:end)';
