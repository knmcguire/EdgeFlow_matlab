function displacement=SAD_blockmatching_full_image(hist1,hist2,D)

if size(hist1)~=size(hist2)
    disp('not okay')
end



SAD_temp=zeros(2*D,1);



for i=-D:D
    
    if i<0
%         keyboard
        SAD_temp(i+D+1)=sum(abs(hist1(1:end+i)-hist2(-i+1:end)));
    else if i==0
            SAD_temp(i+D+1)=sum(abs(hist1-hist2));

        else
            SAD_temp(i+D+1)=sum(abs(hist1(i+1:end)-hist2(1:end-i)));

        end
    end

    
end
    [value,index]=min(SAD_temp);
    displacement=index+1-D;
%     keyboard