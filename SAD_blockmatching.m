function [displacement match_error]=SAD_blockmatching(W,D,hist_current,hist_previous,pixel_shift)

if size(hist_current)~=size(hist_previous)
    size(hist_current)
    size(hist_previous)
    disp('not okay')
end

SAD_temp=zeros(D*2,1);

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
% hist_current= [zeros(1,border),hist_current,zeros(1,border)];
% hist_previous = [ zeros(1,border),hist_previous,zeros(1,border)];
displacement=zeros(size(hist_current));
match_error = zeros(size(hist_current));

% if border(1)<border(2)


%     for x=border(1):border(2)
for x = W+D+1:size(hist_current,2)-W-D
    
    for r=-D:D
        %             SAD_temp(r+D+1)=sum(abs(hist_previous(x-W+pixel_shift(1):x+W+pixel_shift(1))-hist_current(x+r-W:x+r+W)));
        SAD_temp(r+D+1)=sum(abs(hist_previous(x-W:x+W)-hist_current(x+r-W:x+r+W)));
        
    end
    [value,index]=min(SAD_temp);
%     total_SAD(x)=SAD_temp(end)-D-1;
    displacement(x)=index-D-1;
    match_error(x) = value;
end

% displacement = displacement(border+1:end-border);



