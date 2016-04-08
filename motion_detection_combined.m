function [foreground] = motion_detection_combined(frameSequence, p)
% TODO: Add explicit explanations here
% 0.2989 * R + 0.5870 * G + 0.1140 * B 
coefficient.R = 0.2989;
coefficient.G = 0.5870;
coefficient.B = 0.1140;
%% initialize
frameNumber = numel(frameSequence);
foreground = struct([]);
% loop over the frames
for i=1:frameNumber
    % Clear screen
    clc;
    info = sprintf('Total Number of Frame: %d, Current Frame Number: %d, (%%) Done: %d', frameNumber, i, int16((i-1)/frameNumber));
    disp(info);
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
    assignin('base', 'gmfit', gmfit)
    clusterX = cluster(gmfit,tt);
    clustered = reshape(clusterX,[y,x]);
    [~, minIdx] = min(gmfit.ComponentProportion);
    foreground(i).gmm_foreground = clustered == minIdx;
    foreground(i).gmm_percent = sum(foreground(i).gmm_foreground(:))/numel(foreground(i).gmm_foreground(:));
    disp('Finish Color-Based Background Subtraction');
    %% Gradient-based Background Subtraction
    % TODO: Implement this method
%     disp('Start Gradient-Based Background Subtraction');

%     disp('Finish Gradient-Based Background Subtraction');
    
    %% Visualization of the Results
    figure(1);
    subplot(2,2,1); imshow(foreground(i).afd_image); title('AFD Result');
    subplot(2,2,2); imshow(foreground(i).gmm_foreground); title('Color-based BG Subtraction Result');
    subplot(2,2,3); imshow(foreground(i).gmm_foreground .* foreground(i).afd_image); title('Combined Result'); 
    drawnow;
end

end

