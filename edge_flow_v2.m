function [new_parameters,displacement,edge_histogram,frame_previous_number, match_error]=edge_flow_v2(Fx_hist,Fy_hist,edge_histogram,previous_parameters,frame_previous_number_prev,window,max_search_distance,max_frame_horizon,pixelshift_rot)

%Store histogram in structure
edge_histogram(1).x=Fx_hist;
edge_histogram(1).y=Fy_hist;

%Determine if subpixel flow must be taken into account and which previous
%frame will be used (until max_frame_horizon)
%TODO: update this to new previous frame rule
% frame_previous_number.x=round(min(1/abs(previous_parameters.translation.x),max_frame_horizon-1));
% frame_previous_number.y=round(min(1/abs(previous_parameters.translation.y),max_frame_horizon-1));

frame_previous_number.x=frame_previous_number_prev.x;
frame_previous_number.y=frame_previous_number_prev.y;
if max_frame_horizon>1
    min_flow = 0.01;
    max_flow = 2.0;
    flow_mag_x = abs(previous_parameters.translation.x);
    flow_mag_y = abs(previous_parameters.translation.y);
    
    
    
    if flow_mag_x > max_flow && frame_previous_number_prev.x >1;
        frame_previous_number.x=frame_previous_number_prev.x-1;
    end
    if flow_mag_x < min_flow && frame_previous_number_prev.x < max_frame_horizon;
        frame_previous_number.x=frame_previous_number_prev.x+1;
        %     else
        %       if frame_previous_number_prev.x > 1
        %           frame_previous_number.x=frame_previous_number_prev.x-1;
        %       else
        %       end
        
    end
    if flow_mag_y > max_flow && frame_previous_number_prev.y >1;
        frame_previous_number.y=frame_previous_number_prev.y-1;
    end
    if flow_mag_y < min_flow && frame_previous_number_prev.y < max_frame_horizon;
        frame_previous_number.y=frame_previous_number_prev.y+1;
    end
    
    
end


%Calculate the local translations of the edge histogram using a Sum of All
%Differences (SAD)
[displacement.x match_error.x]=SAD_blockmatching(window,max_search_distance,edge_histogram(1).x, edge_histogram(frame_previous_number.x+1).x,pixelshift_rot.x);
[displacement.y match_error.y]=SAD_blockmatching(window,max_search_distance,edge_histogram(1).y, edge_histogram(frame_previous_number.y+1).y,pixelshift_rot.y);


displacement.x = displacement.x/(frame_previous_number.x);
displacement.y = displacement.y/(frame_previous_number.y);

% Line fitting, the distances will be fitted with a linear line
% to determine the global divergence and translation,

displacement_x_ptx=find(displacement.x~=0);
displacement_x_pty=displacement.x(displacement_x_ptx);
displacement_y_ptx=find(displacement.y~=0);
displacement_y_pty=-displacement.y(displacement_y_ptx);

px=polyfit(displacement_x_ptx,displacement_x_pty,1);
py=polyfit(displacement_y_ptx,displacement_y_pty,1);

new_parameters.translation.x = px(1)*size(Fx_hist,2)/2+px(2);
new_parameters.translation.y = py(1)*size(Fy_hist,2)/2+py(2);
new_parameters.divergence.x = px(1);
new_parameters.divergence.y = py(1);

