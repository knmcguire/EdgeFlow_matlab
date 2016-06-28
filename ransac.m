


function px = ransac(pts,iterNum,inlier_threshold,inlier_ratio)

a_it = zeros(1,iterNum);
b_it = zeros(1,iterNum);

% inlier_threshold = 8;
% inlier_ratio = 0.5;

errors = zeros(1,iterNum);

for it = 1:iterNum
    %     ind = randsample(pts(1,:),2);
    ind = datasample(pts(1,:),2,'Replace',false);
    %     while (ind(1)==ind(2))
    %             ind(2) = randsample(pts(1,:),1);
    %     end
    if (ind(1) > ind(2))
        ind = [ind(2),ind(1)];
    end
    dx = ind(2) - ind(1);
    dy = pts(2,find(pts(1,:)==ind(2))) - pts(2,find(pts(1,:)==ind(1)));
    
    a_it(it) = dy/dx;
    b_it(it) = pts(2,find(pts(1,:)==ind(1)))-a_it(it)*ind(1);
    
    
    
    predict = polyval([ a_it(it);b_it(it)],pts(1,:));
    
    error_predict = abs(pts(2,:)-predict);
    
    
    num_inliers = length(find(error_predict< inlier_threshold));
    if(num_inliers>round(size(pts,2)*inlier_ratio))
        total_error = sum(abs(pts(2,:)-predict));
        
    else
        total_error = NaN;
    end
    
    
    errors(it) = total_error;
    
end
[min_value, best_ind] = min(errors);
min_value
px(1) = a_it(best_ind);
px(2) = b_it(best_ind);
end

%  function [bestParameter1,bestParameter2] = ransac(data,num,iter,threshDist,inlierRatio)
%  % data: a 2xn dataset with #n data points
%  % num: the minimum number of points. For line fitting problem, num=2
%  % iter: the number of iterations
%  % threshDist: the threshold of the distances between points and the fitting line
%  % inlierRatio: the threshold of the number of inliers
%
%  %% Plot the data points
% %  figure;plot(data(1,:),data(2,:),'o');hold on;
%  number = size(data,2); % Total number of points
%  bestInNum = 0; % Best fitting line with largest number of inliers
%  bestParameter1=0;bestParameter2=0; % parameters for best fitting line
%  for i=1:iter
%  %% Randomly select 2 points
%      idx = randperm(number,num); sample = data(:,idx);
%  %% Compute the distances between all points with the fitting line
%      kLine = sample(:,2)-sample(:,1);% two points relative distance
%      kLineNorm = kLine/norm(kLine);
%      normVector = [-kLineNorm(2),kLineNorm(1)];%Ax+By+C=0 A=-kLineNorm(2),B=kLineNorm(1)
%      distance = normVector*(data - repmat(sample(:,1),1,number));
%  %% Compute the inliers with distances smaller than the threshold
%      inlierIdx = find(abs(distance)<=threshDist);
%      inlierNum = length(inlierIdx);
%  %% Update the number of inliers and fitting model if better model is found
%      if inlierNum>=round(inlierRatio*number) && inlierNum>bestInNum
%          bestInNum = inlierNum;
%          parameter1 = (sample(2,2)-sample(2,1))/(sample(1,2)-sample(1,1));
%          parameter2 = sample(2,1)-parameter1*sample(1,1);
%          bestParameter1=parameter1; bestParameter2=parameter2;
%      end
%  end
%
