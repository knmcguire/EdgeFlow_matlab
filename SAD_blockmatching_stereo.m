function [displacement matching_error]=SAD_blockmatching_stereo(W,D,hist_left,hist_right)

% pad histograms for height detection over entire histogram
border = W+D;
    hist_left = [zeros(1,border),hist_left,zeros(1,border)];
    hist_right = [ zeros(1,border),hist_right,zeros(1,border)];
    %initialize arrays
displacement=zeros(size(hist_left));
matching_error=zeros(size(hist_left));

SAD_temp=zeros(D,1);
    
% figure(6)
% for x = W+D+1:size(hist_left,2)-W     
for x = W+1:size(hist_left,2)-W -D    

%     for r=-D:0
    for r=0:D
        SAD_temp(r+D+1)=sum(abs(hist_right(x-W:x+W)-hist_left(x+r-W:x+r+W)));
% plot([hist_left;hist_right]'), hold on, plot(x,4000,'o'), plot(x+r,4000,'*'), hold off;
% keyboard
%         SAD_temp(r+1)=sum(abs(hist_right(x-W:x+W)-hist_left(x-W+r:x+W+r)));

        SAD_temp(r+1)=sum(abs(hist_left(x-W:x+W)-hist_right(x-W+r:x+W+r)));
    end
    [value,index]=min(SAD_temp);
%     displacement(x)=D+1-index;
    displacement(x)=index;

    matching_error(x) = value;
end

displacement = displacement(border+1:end-border);

 matching_error = matching_error(border+1:end-border);


