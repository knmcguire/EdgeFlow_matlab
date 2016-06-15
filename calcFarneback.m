
    %%%%%%%%%%%%%%%%%%%%%%%%%FARNEBACK
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % calculate stereo dense map
        estimateFlow(opticFlow_stereo,I_left_prev);
        stereo = estimateFlow(opticFlow_stereo,I_right_prev);
        reset(opticalFlowFarneback);
        
      
        
        % From disparity to distance[m]
        distance_FB = pxperrad*0.06./stereo.Vx;
        
        distance_FB(find(distance_FB<0)) = 0; %anything smaller than 0 is not possible
        distance_FB(find(distance_FB>5)) = 5; %maximum measured distance on 5 [m]
        % put borders on zero
        distance_FB(:,end-border)=0;
        distance_FB(:,border)=0;
        
        % Calculate dense flow (over entire image)
        flow = estimateFlow(opticFlow,I_left);
        V_FB_OF = flow.Vx;
        
        %Derotation (based on IMU (1) or flow(2))
        V_FB_OF = V_FB_OF - pixelshift_yaw_derotate;

        % Calculate velocity (forward and sideways)
        if i>1
            frequency = 1/(t_frame(i)-t_frame(i-1));
        else
            frequency = 10;
        end
        velocity_column_forward_FB= distance_FB.*V_FB_OF*frequency;
        velocity_x_ptx=repmat([1:128],[94 1]);
        velocity_x_pty=velocity_column_forward_FB;
        px=polyfit(velocity_x_ptx,velocity_x_pty,1);
        velocity_tot_forward_FB = px(1);
        velocity_tot_sideways_FB = (px(2)+px(1)*round(length(velocity_x_ptx)/2))*radperpx;
        
        %     Save for plotting afterwards
            velocity_tot_forward_FB_plot(i) = velocity_tot_forward_FB;
            velocity_tot_sideways_FB_plot(i) = velocity_tot_sideways_FB;