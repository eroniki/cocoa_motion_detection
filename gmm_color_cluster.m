function [foreground] = gmm_color_cluster(frame)
% TODO: Add explicit explanations here
[y, x, c] = size(frame);

tt = double(reshape(frame,y*x,3));

k = 4;
options = statset('MaxIter', 1000, 'Display', 'final'); % Increase number of EM iterations

gmfit = fitgmdist(tt, k,'CovarianceType', 'diagonal', 'SharedCovariance', ...
        false, 'Options', options);

clusterX = cluster(gmfit,tt);
% imshow(frame);
clustered = reshape(clusterX,[y,x]);
[~, minIdx] = min(gmfit.ComponentProportion);
foreground = clustered == minIdx;
end

