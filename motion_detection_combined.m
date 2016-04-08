function [foreground] = motion_detection_combined(frameSequence, p)
% TODO: Add explicit explanations here
%% initialize
foreground = struct([]);
% loop over the frames
for i=1:frameNumber
    %% Accumulative Frame Differencing
    disp('Start AFD');
    foreground(i).afd_image = zeros(size(frameSequence(i).image_gray));
    foreground(i).histogram = zeros(1,256);
    if(i<p || i>(frameNumber-p))
        continue;
    else
        sumFrame = zeros(size(frameSequence(i).image_gray));
        for counter=-p+1:p
            diff = abs(frameSequence(i).image_gray - frameSequence(i+counter).image_gray);
            sumFrame = sumFrame + im2double(diff);
        end
        foreground(i).afd_image = log(sumFrame);
        foreground(i).histogram = imhist(sumFrame);
    end
    disp('Finish AFD');
    %% Color-based Background Subtraction
    disp('Start Color-Based Background Subtraction');
    [y, x, c] = size(frameSequence(i).image_rgb);

    tt = double(reshape(frameSequence(i).image_rgb,y*x,3));

    k = 4;
    options = statset('MaxIter', 1000, 'Display', 'final'); % Increase number of EM iterations

    gmfit = fitgmdist(tt, k,'CovarianceType', 'diagonal', 'SharedCovariance', ...
            false, 'Options', options);

    clusterX = cluster(gmfit,tt);
    clustered = reshape(clusterX,[y,x]);
    [~, minIdx] = min(gmfit.ComponentProportion);
    foreground.gmm_foreground = clustered == minIdx;
    foreground.gmm_percent = sum(foreground.gmm_foreground(:))/numel(foreground.gmm_foreground);
    disp('Finish Color-Based Background Subtraction');
    %% Gradient-based Background Subtraction
    % TODO: Implement this method
    disp('Start Gradient-Based Background Subtraction');

    disp('Finish Gradient-Based Background Subtraction');

end

end

