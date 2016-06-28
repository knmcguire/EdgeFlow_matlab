function [displacement matching_error]=SAD_blockmatching_stereo(W,D,hist_left,hist_right,stereo_shift)


border = W+D;

    %initialize arrays
displacement=zeros(size(hist_left));
matching_error=zeros(size(hist_left));

SAD_temp=zeros(D,1);
 
border_left = W+1;
border_right = size(hist_left,2)-W -D;
if stereo_shift > 0
    border_left = border_left + stereo_shift;
else if stereo_shift < 0
            border_right = border_right + stereo_shift;
    end
end


   
for x = border_left:border_right   
    for r=0:D
        SAD_temp(r+1)=sum(abs(hist_left(x-W:x+W)-hist_right(x-W+r-stereo_shift:x+W+r-stereo_shift)));
    end
    [value,index]=min(SAD_temp);
    displacement(x)=index - 1;

    matching_error(x) = value;
end



