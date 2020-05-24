function displacement = SAD_blockmatching_full_image(hist1,hist2,D,stereo_shift)

if size(hist1)~=size(hist2)
    disp('Histograms should be same size!')
end


border_left = D + 1;
border_right = size(hist1,2);
if stereo_shift > 0
    border_left = border_left + stereo_shift;
else
    border_right = border_right + stereo_shift;
end

SAD_temp = zeros(D,1);

for c = 1:D
    SAD_temp(c) = sum(abs(hist2(border_left:border_right) - hist1((border_left:border_right) - c - stereo_shift)));
end

[value,index] = min(SAD_temp);
displacement = index + 1;
