function [displacement match_error fit_quality] = SAD_blockmatching(W,D,hist_current,hist_previous,pixel_shift, plot_)

if size(hist_current)~=size(hist_previous)
    size(hist_current)
    size(hist_previous)
    disp('not okay')
end

SAD_temp=zeros(D*2+1,1);

%Check if pixel shift makes it more difficult
% border = [0,0];
% if pixel_shift(1) > 0
%     border(1) = W+D+1;
%     border(2) = max(size(hist1,2))-W-D-1-abs(pixel_shift(1));
% else if pixel_shift(1) < 0
%         border(1) = W+D+1+abs(pixel_shift(1));
%         border(2) = max(size(hist1,2))-W-D-1;
%     else
%         border(1) = W+D+1;
%         border(2) = max(size(hist1,2))-W-D-1;
%     end
% end

border = W+D;
displacement=zeros(size(hist_current));
match_error = zeros(size(hist_current));
fit_quality = zeros(size(hist_current));

% if border(1)<border(2)

%     for x=border(1):border(2)
for x = W+D+1:size(hist_current,2)-W-D
    for r=-D:D
        SAD_temp(r+D+1)=sum(abs(hist_previous(x-W+pixel_shift:x+W+pixel_shift)-hist_current(x+r-W:x+r+W)));
        %SAD_temp(r+D+1) = sum(abs(hist_previous(x-W:x+W)-hist_current(x+r-W:x+r+W)));
    end
    
    [value,index]=min(SAD_temp);
%     total_SAD(x)=SAD_temp(end)-D-1;
    displacement(x)= index-D-1;
    match_error(x) = value;
    
    sum_SAD = 0;
    num_el = 0;
    for i = index-round(D/3):index-1
        if i > 0 && i <= D*2+1
            sum_SAD = sum_SAD + SAD_temp(i);
        end
        num_el = num_el + 1;
    end
    
    fit_quality(x) = sum_SAD / (value * num_el);
    
    sum_SAD = 0;
    num_el = 0;
    for i = index+1:index+round(D/3)
        if i > 0 && i <= D*2+1
            sum_SAD = sum_SAD + SAD_temp(i);
        end
        num_el = num_el + 1;
    end
    
    fit_quality(x) = min([fit_quality(x), sum_SAD / (value * num_el)]);
    
%     if (fit_quality(x) > 1.5 && fit_quality(x) < 2)
%         fit_quality(x)
%         figure(2)
%         plot(-D:D,SAD_temp);
%         title(x)
%         pause
%     end
end


