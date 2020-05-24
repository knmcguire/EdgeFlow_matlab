function [displacement, matching_error, displacement_r]=SAD_blockmatching_stereo(W,D,hist_left,hist_right,stereo_shift)


border = W+D;

%initialize arrays
displacement=zeros(size(hist_left));
displacement_r=zeros(size(hist_left));
matching_error=zeros(size(hist_left));

SAD_temp=zeros(D,1);
SAD_temp_right=zeros(D,1);

border_left = W+1
border_right = size(hist_left,2)-W -D
if stereo_shift > 0
    border_left = border_left + stereo_shift;
else if stereo_shift < 0
        border_right = border_right + stereo_shift;
    end
end



for x = border_left:border_right
    for r=0:D
        SAD_temp(r+1)=sum(abs(hist_right(x-W:x+W)-hist_left(x-W+r-stereo_shift:x+W+r-stereo_shift)));
		SAD_temp_right(r+1)=sum(abs(hist_right(x-W+D-r:x+W+D-r)-hist_left(x-W-stereo_shift:x+W-stereo_shift)));
    end
    
    [value,index] = min(SAD_temp);
	[~,index_r] = min(SAD_temp_right);
    
	displacement(x) = index - 1;
	displacement_r(x) = index_r - 1;
    if index > 1 && index < numel(SAD_temp)
       displacement(x) = index - 1 - (SAD_temp(index+1) - SAD_temp(index-1))/(SAD_temp(index-1) - 2*SAD_temp(index) + SAD_temp(index+1))/2;
    else
       displacement(x) = index - 1;
    end
    
    matching_error(x) = value;
end

displacement

