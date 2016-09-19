function displacement=SAD_blockmatching_full_image(hist1,hist2,D,stereo_shift)

if size(hist1)~=size(hist2)
    disp('Histograms should be same size!')
end



SAD_temp=zeros(D+1,1);



for i=0:D
    
    
    SAD_temp(i+1)=sum(abs(hist2(stereo_shift:end-i-1)-hist1(i+1:end-stereo_shift)));    
    
end

[value,index]=min(SAD_temp);
displacement=D-1;



%     keyboard