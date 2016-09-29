
norm_max_xcorr_mag = @(x,y)(max(abs(xcorr(x,y)))/(norm(x,2)*norm(y,2)));

if(~make_plots_journal)
    
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
    
    subplot(2,1,2), plot(t_frame(start_i:end_i),cam_Vx_frame(start_i:end_i))
    
    hold on, plot(t_frame(start_i:end_i),velocity_tot_sideways_plot(start_i:end_i),'r');
        
    hold on, plot(t_frame(start_i:end_i),velocity_tot_sideways_FB_plot(start_i:end_i),'g');
    
    hold off
    
    ylim([-1 1])
    xlim([t_frame(1),t_frame(end)])
    legend('Ground Truth', 'Edge Flow', 'F\"arneback')
    
    ylabel('velocity')
    xlabel('Time[s]')
    title(['Sideways Velocity of dataset ',num2str(track)])
else
    start_i =10;
    end_i = end_i -10;
    
    time = t_frame(start_i:end_i);
    velocity_x_optitrack = cam_Vz_frame(start_i:end_i)';
    velocity_y_optitrack = cam_Vx_frame(start_i:end_i)';
    
    velocity_x_edgeflow = velocity_tot_forward_plot(start_i:end_i);
    velocity_y_edgeflow = velocity_tot_sideways_plot(start_i:end_i);
    
    velocity_x_farneback = velocity_tot_forward_FB_plot(start_i:end_i);
    velocity_y_farneback = velocity_tot_sideways_FB_plot(start_i:end_i);
    % calculate quality values
    nmxm_x= norm_max_xcorr_mag(velocity_x_edgeflow,velocity_x_optitrack);
    nmxm_y= norm_max_xcorr_mag(velocity_y_edgeflow,velocity_y_optitrack);
    MSE_x=mean((velocity_x_edgeflow-velocity_x_optitrack).^2);
    MSE_y=mean((velocity_y_edgeflow-velocity_y_optitrack).^2);
    var_x = var(abs(velocity_x_edgeflow-velocity_x_optitrack));
    var_y = var(abs(velocity_y_edgeflow-velocity_y_optitrack));
    
    nmxm_x_FB= norm_max_xcorr_mag(velocity_x_farneback,velocity_x_optitrack);
    nmxm_y_FB= norm_max_xcorr_mag(velocity_y_farneback,velocity_y_optitrack);
    MSE_x_FB=mean((velocity_x_farneback-velocity_x_optitrack).^2);
    MSE_y_FB=mean((velocity_y_farneback-velocity_y_optitrack).^2);
    var_x_FB = var(abs(velocity_x_farneback-velocity_x_optitrack));
    var_y_FB = var(abs(velocity_y_farneback-velocity_y_optitrack));
    
    
    figure,subplot(2,1,1),
    
    plot(  time, velocity_x_optitrack),
    hold on
    
    plot(  time, velocity_x_edgeflow),
    plot(  time, velocity_x_farneback,'g') ,
    
    plot(time,zeros(size(time)),'k:'),
    hold off
    hleg= legend('Groundtruth','EdgeFlow',...
        'FarneBack');
    %     set(hleg,'Position',[0.655833314916502 0.874444441719661 0.261785718781608 0.12619047891526], 'FontSize',7);
    legend boxoff
    xlim([time(1),time(end)])
    
    xlim_figure =get(gca,'xlim');
    ylim([-1.0 1.0])
    box off
    descr = {['\fontsize{6}NMXM_x:\color{red} ',num2str(nmxm_x,'%.4f'),' \color{green}(',num2str(nmxm_x_FB,'%.4f'),'),  \fontsize{6}\color{black}MSE_x\color{red}: ' ,num2str(MSE_x,'%.4f'),' \color{green}(',num2str(MSE_x_FB,'%.4f'),'), \fontsize{6}\color{black}var_x: \color{red}',num2str(var_x,'%.4f'),' (\color{green}',num2str(var_x_FB,'%.4f'),')']};
    text(xlim_figure(1)+1,1.0,descr,...
        'VerticalAlignment','top',...
        'HorizontalAlignment','left', 'FontSize',7)
    xlabel('Time [s]')
    ylabel('Velocity (x) [m/s]')
    title({' ';' '; 'velocity x-direction'})
    %y-direction
    subplot(2,1,2),
    plot(time, velocity_y_optitrack),hold on,
    plot(  time, velocity_y_edgeflow),
    plot(  time, velocity_y_farneback,'g')
    plot(time,zeros(size(time)),'k:')
    hold off
    
    %     legend('Groundtruth','EdgeFlow pixelwise','Edgeflow global')
    xlim([time(1),time(end)])
    ylim([-1.0 1.0])
    xlim_figure =get(gca,'xlim');
    
    descr = {['\fontsize{6}NMXM_y:\color{red} ',num2str(nmxm_y,'%.4f'),' \color{green}(',num2str(nmxm_y_FB,'%.4f'),'),  \fontsize{6}\color{black}MSE_y\color{red}: ' ,num2str(MSE_y,'%.4f'),' \color{green}(',num2str(MSE_y_FB,'%.4f'),'), \fontsize{6}\color{black}var_y: \color{red}',num2str(var_y,'%.4f'),' (\color{green}',num2str(var_y_FB,'%.4f'),')']};
    text(xlim_figure(1)+1,1.0,descr,...
        'VerticalAlignment','top',...
        'HorizontalAlignment','left', 'FontSize',7)
    box off
    title('velocity y-direction')
    xlabel('Time [s]')
    ylabel('Velocity (y) [m/s]')
    
    set(gcf,'Position',[0 0 400 500])
    
    
    filename_savevel = sprintf('../journal_paper_edgeflow/matlab_plots/Edgeflow_Farneback_board_%d_data_%d',stereoboard_type,track);
    
    printpdf(gcf,[filename_savevel,'.pdf'])
    
    filename = sprintf('generated_plots/Edgeflow_Farneback_board_%d_data_%d.png',stereoboard_type,track);
    
    
    saveas(gcf,filename)
end