function [new_parameters,displacement,edge_histogram,frame_previous_number, match_error]=edge_flow_v2(Fx_hist,Fy_hist,edge_histogram,previous_parameters,frame_previous_number_prev,window,max_search_distance,max_frame_horizon,pixelshift_rot,disp_distance)

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
    min_flow = 0.02;
    max_flow = 0.1;
    flow_mag_x = abs(previous_parameters.translation.x);
    flow_mag_y = abs(previous_parameters.translation.y);
    div_mag = numel(Fx_hist)*abs(previous_parameters.divergence.x);
    
    flow_mag_x = max([flow_mag_x, div_mag])
    flow_mag_y = max([flow_mag_y, div_mag])
    
    if flow_mag_x > max_flow && frame_previous_number_prev.x > 1;
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

frame_previous_number_prev.x
frame_previous_number_prev.y

%Calculate the local translations of the edge histogram using a Sum of All
%Differences (SAD)
[displacement.x match_error.x]=SAD_blockmatching(window,max_search_distance,edge_histogram(1).x, edge_histogram(frame_previous_number.x+1).x,pixelshift_rot.x);
[displacement.y match_error.y]=SAD_blockmatching(window,max_search_distance,edge_histogram(1).y, edge_histogram(frame_previous_number.y+1).y,pixelshift_rot.y);

displacement.x = displacement.x/(frame_previous_number.x);
displacement.y = displacement.y/(frame_previous_number.y);

dist_x = 127.767*0.06./disp_distance;
dist_x(find(disp_distance<1)) = 0;
dist_y = 127.767*0.06./mean(disp_distance(find(disp_distance>1)));
%dist_y = mean(dist_x(find(disp_distance>1)));
scaled_displacement.x = dist_x.*displacement.x;
scaled_displacement.y = dist_y*displacement.y;

% Line fitting, the distances will be fitted with a linear line
% to determine the global divergence and translation,
displacement_x_ptx=find(scaled_displacement.x~=0);
displacement_x_pty=scaled_displacement.x(displacement_x_ptx);
displacement_y_ptx=find(scaled_displacement.y~=0);
displacement_y_pty=scaled_displacement.y(displacement_y_ptx);

px=polyfit(displacement_x_ptx,displacement_x_pty,1);
py=polyfit(displacement_y_ptx,displacement_y_pty,1);

px(1)
py(1)
(px(1) + py(1)) / 2

new_parameters.translation.x = px(1)*size(Fx_hist,2)/2+px(2);
new_parameters.translation.y = py(1)*size(Fy_hist,2)/2+py(2);
new_parameters.divergence.x = px(1);
new_parameters.divergence.y = py(1);

%% compute coupled divergence and corresponding ventral flow
border = window + max_search_distance;
xend = numel(scaled_displacement.x) - border - 1;
yend = numel(scaled_displacement.y) - border - 1;

n1 = numel(scaled_displacement.x) - 2*border;
n2 = numel(scaled_displacement.y) - 2*border;
x1 = xend * (xend + 1) / 2 - border * (border + 1) / 2 + border;
x2 = yend * (yend + 1) / 2 - border * (border + 1) / 2 + border;
x12 = xend * (xend + 1) * (2 * xend + 1) / 6 - border * (border + 1) * (2 * border + 1) / 6 + border*border;
x22 = yend * (yend + 1) * (2 * yend + 1) / 6 - border * (border + 1) * (2 * border + 1) / 6 + border*border;

y1 = 0; X1 = 0;
for x = border + 1:numel(scaled_displacement.x) - border + 1
    y1 = y1 + scaled_displacement.x(x);
    X1 = X1 + scaled_displacement.x(x)*x;
end
y2 = 0; X2 = 0;
for x = border + 1:numel(scaled_displacement.y) - border + 1
    y2 = y2 + scaled_displacement.y(x);
    X2 = X2 + scaled_displacement.y(x)*x;
end

denom = n1*n2*x12 + n1*n2*x22 - n1*(x2^2) - n2*(x1^2);
b = (n1*n2*X1 + n1*n2*X2 - n1*x2*y2 - n2*x1*y1) / denom;
a1 = (-n2*x1*X1 - n2*x1*X2 + n2*x12*y1 + n2*x22*y1 + x1*x2*y2 - (x2^2)*y1) / denom;
a2 = (-n1*X1*x2 + n1*x12*y2 - n1*x2*X2 + n1*x22*y2 - (x1^2)*y2 + x1*x2*y1) / denom;

% figure(1)
% hold off; plot(0:numel(scaled_displacement.x)-1, scaled_displacement.x); hold on;
% plot (0:numel(scaled_displacement.x)-1, b*(0:numel(scaled_displacement.x)-1) + a1);
% plot (0:numel(scaled_displacement.x)-1, px(1)*(0:numel(scaled_displacement.x)-1) + px(2));
% 
% figure(2)
% hold off; plot(0:numel(scaled_displacement.y)-1, scaled_displacement.y); hold on;
% plot (0:numel(scaled_displacement.y)-1, b*(0:numel(scaled_displacement.y)-1) + a2);
% plot (0:numel(scaled_displacement.y)-1, py(1)*(0:numel(scaled_displacement.y)-1) + py(2));
% 
% b
% b*size(Fx_hist,2)/2 + a1
% b*size(Fy_hist,2)/2 + a2

% error_new = 0;
% error_orig = 0;
% for x = 0:n1-1
%    error_new = error_new + (scaled_displacement.x(x+1) - b*x - a1)^2;
%    error_orig = error_orig + (scaled_displacement.x(x+1) - px(1)*x - px(2))^2;
% end
% 
% for x = 0:n2-1
%    error_new = error_new + (scaled_displacement.y(x+1) - b*x - a2)^2;
%    error_orig = error_orig + (scaled_displacement.y(x+1) - py(1)*x - py(2))^2;
% end
% 
% error_new
% error_orig

new_parameters.translation.x = b*size(Fx_hist,2)/2 + a1;
new_parameters.translation.y = b*size(Fy_hist,2)/2 + a2;
new_parameters.divergence.x = b;
new_parameters.divergence.y = b;

%pause