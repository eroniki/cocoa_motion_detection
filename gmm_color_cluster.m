%% GMM with Color Images
clc;
%%
frame = frameSequence(165).image_gray;
[y,x] = size(frame);

yy = repmat([1:y]',[x,1]);
xx = repmat([1:x]',[y,1]);

% tt = [xx, yy, double(frame(:))];
tt = double(frame(:));
k = 10;
d = 500;
options = statset('MaxIter', 1000, 'Display', 'final'); % Increase number of EM iterations

gmfit = fitgmdist(tt, k,'CovarianceType', 'diagonal', 'SharedCovariance', ...
        false, 'Options', options);
clusterX = cluster(gmfit,tt);
imshow(frame);
figure(2);
imagesc(reshape(clusterX,[y,x]));
% h1 = gscatter(tt(:,1), tt(:,2), clusterX); hold on;
% h1 = gscatter(frame(:), clusterX); hold on;
% h1 = plot([tt(:,1), tt(:,2)], clusterX); hold on;
% plot(gmfit.mu(:,1), gmfit.mu(:,2), 'kx', 'LineWidth', 2, 'MarkerSize', 10)
