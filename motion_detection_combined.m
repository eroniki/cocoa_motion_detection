function [foreground] = motion_detection_combined(frameSequence, p)
% TODO: Add explicit explanations here
% TODO: Check the formulations for the deviation and the variance
% 0.2989 * R + 0.5870 * G + 0.1140 * B 
coefficient.R = 0.2989;
coefficient.G = 0.5870;
coefficient.B = 0.1140;
%% initialize
frameNumber = numel(frameSequence);
foreground = struct([]);
% loop over the frames
for i=1:frameNumber
%     Clear screen
%     clc;
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    info = sprintf('Total Number of Frame: %d, Current Frame Number: %d, (%%) Done: %d', frameNumber, i, int16((i-1)/frameNumber));
    disp(info);
    %% Accumulative Frame Differencing
    disp('Start AFD');
    foreground(i).afd_image = zeros(size(frameSequence(i).image_gray), 'uint8');
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
    options = statset('MaxIter', 100, 'Display', 'final'); % Increase number of EM iterations

    gmfit = fitgmdist(tt, k,'CovarianceType', 'diagonal', 'SharedCovariance', ...
            false, 'Options', options);
    assignin('base', 'gmfit', gmfit)
    clusterX = cluster(gmfit,tt);
    clustered = reshape(clusterX,[y,x]);
    [~, minIdx] = min(gmfit.ComponentProportion);
    foreground(i).gmm_foreground = zeros(y, x, 'uint8');
    foreground(i).gmm_foreground(clustered == minIdx) = 255;
    foreground(i).gmm_percent = sum(foreground(i).gmm_foreground(:))/numel(foreground(i).gmm_foreground(:));
    disp('Finish Color-Based Background Subtraction');
    %% Gradient-based Background Subtraction
    % TODO: Implement this method
    disp('Start Gradient-Based Background Subtraction');
    foreground(i).gradient.mu = zeros(y, x, 'double');
    foreground(i).gradient.variance = zeros(y, x, 'double');
    gray_mu = zeros(1, k);
    gray_variance = zeros(1, k);
     
    for t=1:k
%         (Javed et al, 2002) Eq.2
        gray_mu(t) = gmfit.mu(t,1) * coefficient.R + gmfit.mu(t,2) * coefficient.G + gmfit.mu(t,3) * coefficient.B;
        gray_variance(t) = coefficient.R^2 * gmfit.Sigma(:,1,t)^2 + coefficient.G^2 * gmfit.Sigma(:,2,t)^2 + coefficient.B^2 * gmfit.Sigma(:,3,t)^2;
        foreground(i).gradient.mu(clustered == t) = gray_mu(t);
        foreground(i).gradient.variance(clustered == t) = gray_variance(t);  
    end
    
    [Gx, Gy] = imgradientxy(frameSequence(i).image_gray);
    [Gmag, Gdir] = imgradient(Gx, Gy);
    
    distribution = zeros(y, x, 'double');
    
    cosGdir = cos(Gdir);
    sinGdir = sin(Gdir);
    
  
    for row=2:y-1
        for col=2:x-1
%             (Javed et al, 2002) Eq. 5,6
            mu_fx = foreground(i).gradient.mu(row,col+1) ...
               - foreground(i).gradient.mu(row,col);
            mu_fy = foreground(i).gradient.mu(row+1,col) ...
               - foreground(i).gradient.mu(row,col);
           
            variance_fx = foreground(i).gradient.variance(row,col+1)^2 ...
                + foreground(i).gradient.variance(row,col)^2; 
            
            variance_fy = foreground(i).gradient.variance(row+1,col)^2 ...
                + foreground(i).gradient.variance(row,col)^2;
            
%             (Javed et al, 2002) Eq. 8
            rho = foreground(i).gradient.variance(row,col)^2 / (variance_fx*variance_fy)^0.5;
            
            z = ((Gmag(row, col) * cosGdir(row, col)-mu_fx)/variance_fx)^2 ...
                -2*rho*((Gmag(row, col) * cosGdir(row, col)-mu_fx)/variance_fx) ...
                * (Gmag(row, col) * sinGdir(row, col)-mu_fy)/variance_fy ...
                + ((Gmag(row, col) * sinGdir(row, col)-mu_fy)/variance_fy)^2;

            distribution(row,col) = Gmag(row, col) * exp(-1*z/(2*(1-rho^2))) ...
                / (2*pi*variance_fx*variance_fy*sqrt(1-rho^2));
        end
    end
    
    foreground(i).distribution = uint8(distribution/max(distribution(:))*255);
    disp('Finish Gradient-Based Background Subtraction');
    assignin('base', 'foreground', foreground);
    %% Visualization of the Results
    figure(1);
    subplot(4,2,1); imshow(foreground(i).afd_image); title('AFD Result');
    subplot(4,2,2); bar([10:256], foreground(i).histogram(10:end)); title('Histogram of log evidence');
    subplot(4,2,3); imshow(foreground(i).gmm_foreground); title('Color Based BG Subtraction Result');
    subplot(4,2,5); imshow(foreground(i).distribution); title('Gradient Based BG Model');
    subplot(4,2,7); imshow(foreground(i).gmm_foreground & foreground(i).distribution & foreground(i).afd_image); title('Combined Result'); 
    drawnow;
end
