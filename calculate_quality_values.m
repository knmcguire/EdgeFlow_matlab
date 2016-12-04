
norm_max_xcorr_mag = @(x,y)(max(abs(xcorr(x,y)))/(norm(x,2)*norm(y,2)));
start_i =10;
end_i = end_i -10;

velocity_x_optitrack = cam_Vz_frame(start_i:end_i)';
velocity_y_optitrack = cam_Vx_frame(start_i:end_i)';

velocity_x_edgeflow = velocity_tot_forward_plot(start_i:end_i);
velocity_y_edgeflow = velocity_tot_sideways_plot(start_i:end_i);


velocity_x_edgeflow_global = velocity_tot_forward_global_plot(start_i:end_i);
velocity_y_edgeflow_global = velocity_tot_sideways_global_plot(start_i:end_i);

velocity_x_farneback = velocity_tot_forward_FB_plot(start_i:end_i);
velocity_y_farneback = velocity_tot_sideways_FB_plot(start_i:end_i);


velocity_x_lucaskanade = velocity_tot_forward_LK_plot(start_i:end_i);
velocity_y_lucaskanade = velocity_tot_sideways_LK_plot(start_i:end_i);
% calculate quality values

%  Edgeflow
nmxm_x= norm_max_xcorr_mag(velocity_x_edgeflow,velocity_x_optitrack);
nmxm_y= norm_max_xcorr_mag(velocity_y_edgeflow,velocity_y_optitrack);
MSE_x=mean((velocity_x_edgeflow-velocity_x_optitrack).^2);
MSE_y=mean((velocity_y_edgeflow-velocity_y_optitrack).^2);
var_x = var(abs(velocity_x_edgeflow-velocity_x_optitrack));
var_y = var(abs(velocity_y_edgeflow-velocity_y_optitrack));


%  Farneback
nmxm_x_FB= norm_max_xcorr_mag(velocity_x_farneback,velocity_x_optitrack);
nmxm_y_FB= norm_max_xcorr_mag(velocity_y_farneback,velocity_y_optitrack);
MSE_x_FB=mean((velocity_x_farneback-velocity_x_optitrack).^2);
MSE_y_FB=mean((velocity_y_farneback-velocity_y_optitrack).^2);
var_x_FB = var(abs(velocity_x_farneback-velocity_x_optitrack));
var_y_FB = var(abs(velocity_y_farneback-velocity_y_optitrack));

% Lukas Kanade
nmxm_x_LK= norm_max_xcorr_mag(velocity_x_lucaskanade,velocity_x_optitrack);
nmxm_y_LK= norm_max_xcorr_mag(velocity_y_lucaskanade,velocity_y_optitrack);
MSE_x_LK=mean((velocity_x_lucaskanade-velocity_x_optitrack).^2);
MSE_y_LK=mean((velocity_y_lucaskanade-velocity_y_optitrack).^2);
var_x_LK = var(abs(velocity_x_lucaskanade-velocity_x_optitrack));
var_y_LK = var(abs(velocity_y_lucaskanade-velocity_y_optitrack));
