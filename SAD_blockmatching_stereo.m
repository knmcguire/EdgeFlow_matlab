function [displacement matching_error]=SAD_blockmatching_stereo(W,D,hist_left,hist_right)


border = W+D;

    %initialize arrays
displacement=zeros(size(hist_left));
matching_error=zeros(size(hist_left));

SAD_temp=zeros(D,1);
   
for x = W+1:size(hist_left,2)-W -D    


    for r=0:D
        SAD_temp(r+1)=sum(abs(hist_left(x-W:x+W)-hist_right(x-W+r:x+W+r)));
    end
    [value,index]=min(SAD_temp);
    displacement(x)=index - 1;

    matching_error(x) = value;
end



