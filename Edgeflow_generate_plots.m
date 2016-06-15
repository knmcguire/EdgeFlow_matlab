figure(1),subplot(2,1,1), plot(t_frame(3:end),cam_Vz_frame(3:end))
xlim([t_frame(1),t_frame(end)])
hold on, plot(t_frame(start_i:end_i),velocity_tot_forward_plot(start_i:end_i),'r');

hold on, plot(t_frame(start_i:end_i),velocity_tot_forward_FB_plot(start_i:end_i),'g');
hold off
ylim([-1 1])
xlim([t_frame(1),t_frame(end)])
ylabel('velocity')
xlabel('Time[s]')
title(['Forward Velocity of dataset ',num2str(track)])

subplot(2,1,2), plot(t_frame(start_i:end_i),-cam_Vx_frame(start_i:end_i))

hold on, plot(t_frame(start_i:end_i),velocity_tot_sideways_plot(start_i:end_i),'r');


hold on, plot(t_frame(start_i:end_i),velocity_tot_sideways_FB_plot(start_i:end_i),'g');
hold off

ylim([-1 1])
xlim([t_frame(1),t_frame(end)])
legend('Ground Truth', 'Edge Flow', 'F\"arneback')

ylabel('velocity')
xlabel('Time[s]')
title(['Sideways Velocity of dataset ',num2str(track)])

filename = sprintf('generated_plots/Edgeflow_Farneback_board_%d_data_%d.png',stereoboard_type,track);


saveas(gcf,filename)