cd%%% Aerial Tracking System 
%%% Orson Lin, Richard Fedora, Murat Ambarkutuk
%%% 04/30/2016
%%% Virginia Tech
%% Initialization
% clear all; close all; clc;
%% Variables and parameters
params.isAnnotated = true;
params.isTrained = true;
params.datasetLocation = '../data/DARPA_VIVID/eg_test01/egtest01/';
params.fileName = '';
params.modelLocation = '';
params.modelFileName = 'egtest01_model_2class_true_negative.mat';
params.annotationLocation = '';
params.annotationFileName = 'egtest01_annotation_2class_true_negative.mat';
params.filePrefix = 'frame';
params.isVideo = false;
params.annotationToolLocation = '../annotator';
params.trainingSkip = 50;
params.numNeighbors = 10;
params.searchMethod = 'exhaustive';
params.distanceMetric = 'minkowski';
params.Standardize = 1;
%% Create Path
addpath(genpath(params.annotationToolLocation));
% %% Training Routine
% % Check if the annotation is completed for the dataset
% if params.isAnnotated == true;
%     % Check if training is completed
%     if params.isTrained == true
%         load([params.modelLocation, params.modelFileName], 'mdl');
%     else
%     % Train it and save
%         load([params.annotationLocation, params.annotationFileName], 'annotation');
%         featureSpace = construct_feature_space(annotation);
%         mdl = training_knn(featureSpace, params.numNeighbors, params.searchMethod, params.distanceMetric, params.Standardize, [params.modelLocation, params.modelFileName]);
%     end
% % Start annotation routine to create the training model    
% elseif params.isAnnotated == false
%     % Start Annotation Toolbox
%     annotation = annotate_data_set(params.isVideo, params.datasetLocation, params.fileName, [params.annotationLocation, params.annotationFileName], params.trainingSkip);
%     annotation = annotate_background(annotation);
%     params.isAnnotated = true;
%     featureSpace = construct_feature_space(annotation);
%     mdl = training_knn(featureSpace, params.numNeighbors, params.searchMethod, params.distanceMetric, params.Standardize, [params.modelLocation, params.modelFileName]);
%     params.isTrained = true;
% end

%% Main Routine
%% Motion Compensation (Orson Lin)
%find the images, initialize some variables
imageNames = dir(fullfile(params.datasetLocation,'*.jpg'));
imageNames = {imageNames.name}';
nframes = numel(imageNames);
% nframes=30;
startFrame = 1;

margin.X=20;
margin.Y=30;
current_frame=[];
previous_frame=[];

%set parameters for grid devider 
gs.x=16;
gs.y=16;
thresh=4;
percent=98;
grid_sifting_time=4;

for i=startFrame:nframes
    img = imread([params.datasetLocation,imageNames{i}]);
    if (ndims(img) == 3)
        img = rgb2gray(img);
    end  
    img = double(img) / 255;
    %% inialization
    current_frame=img;
    if i==1
        [h, w]=size(img);
        dst= [1 1; 1 h; w h; w 1]';
        yt1=margin.Y+1;
        yt2=h-margin.Y;
        xt1=margin.X+1;
        xt2=w-margin.Y;
        templateBox = [xt1 xt1 xt2 xt2 xt1; yt1 yt2 yt2 yt1 yt1];
    end
    
    if ~isempty(previous_frame)
        %Show image pair
%         figure(1)
%         subplot(1,2,2)
%         imshow(current_frame);
%         title('current frame');
%         subplot(1,2,1)
%         imshow(previous_frame);
%         title('previous frame');
        killed_his=[];
        %% build a mask defining the extent of the template
        template = previous_frame;
        mask     = NaN(size(template));
        mask2    = NaN(size(template));
        mask_in_loop   = NaN(size(template));
        mo_mask   = NaN(size(template));
        %  selected area is decided by margin
        mask(yt1:yt2, xt1:xt2) = 1;        
        %% divider comes into play. This part has some redundancy with tracking initialization
        %  selected area is decided by margin
        select_A= previous_frame(yt1:yt2, xt1:xt2); 
        
        [Gx,Gy]=gradient(select_A);
        select_A_grad=sqrt(Gx.^2+Gy.^2);
        % Sift out the grid that contain "gradient" information
        [sub_mask, ind,uti]= divider(select_A_grad,gs,thresh);
        mask2(yt1:yt2, xt1:xt2)= sub_mask; 
        % mask visualization 
        figure(67);
        subplot(1,2,1)
        imshow(mask.*current_frame);
        subplot(1,2,2)
        imshow(mask2.*current_frame); 
        p=[0,0,0,0,0,0];
        %% KLT
        mask_converted2  = mask_converter(mask2);
        for i2=1:grid_sifting_time
            % Get the inital guess from KLT. If sensor data is available,
            % this part can be a lot faster.
            tic;
            [affineLKContext, row, col, value]=InitAffineLKTracker(previous_frame, mask2);
            p=KLT_tracking(current_frame,value,row,col,affineLKContext,p,0,15);
            ftime = toc;
            %% calculate the covariance of each grid
            M = [ 1+p(1) p(3) p(5); p(2) 1+p(4) p(6); 0 0 1];
            % Warp the image with current estimated Affine parameters 
            warped_current = warp_a_v(current_frame, p, dst);
            error_square=(current_frame(yt1:yt2, xt1:xt2)-warped_current(yt1:yt2, xt1:xt2)).^2;
            % A lot of calculations in the following fucntion are already done in "divider". Can be
            % optimized
            [mask_updated,ind_updated,killed]=divider2(error_square,gs,percent,ind,killed_his);
            killed_his=[killed_his;killed];
            mask_in_loop(yt1:yt2, xt1:xt2)= mask_updated;
            %% mask visualization
%             figure(90);
%              imshow(mask_in_loop.*current_frame);
            %imshow(mask_in_loop);
%             title('Current Mask');
            mask_converted1  = mask_converter(mask_in_loop);
            mask_converted2=mask_converted1+mask_converted2;
%             figure(85);
%             imagesc(mask_converted2);
%             title('Mask update history');
%             %% mask update
            mask2=mask_in_loop;
            ind=ind_updated;
            %% Visualization of grid refinement 
            currentBox = M * [templateBox; ones(1,5)];
            currentBox = currentBox(1:2,:);
            overlap=warped_current*.5+previous_frame*.5;
            hold off;
            figure(99);
            imagesc(overlap);
            hold on;
            plot(currentBox(1,:), currentBox(2,:), 'g', 'linewidth', 2);
            drawnow;
        end
        %Show the grids that might contain object 
        [mask_constructed] = mask_constructor(killed_his,uti,gs);
        mo_mask(yt1:yt2, xt1:xt2)=mask_constructed;
        
        figure(91);
        imshow(mo_mask.*current_frame);
        
        figure(92);
        imshow(mo_mask)
        mo_mask(isnan(mo_mask))=0;
        st = regionprops(logical(mo_mask), 'BoundingBox' );
        hold on 
        
%%      Murat Ambarkutuk
% Detection and Classification Routine (Murat Ambarkutuk)
% TODO: Anaylze the grids for possible objects
% TODO: Background differencing for the static objects (using homography)
% TODO: 
        frame_struct = struct();
        
        frame_struct.maskCumulative = zeros(h, w, 'uint8');
        target_k=1;
        for k = 1 : length(st)
            thisBB = int16(st(k).BoundingBox);

            if thisBB(4)~=gs.x & thisBB(3) ~= gs.y
                rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
                    'EdgeColor','r','LineWidth',2 );
                roi = current_frame(max(0, thisBB(2)-5):min(thisBB(2)+thisBB(4)+5,w), max(thisBB(1)-5,0):min(thisBB(1)+thisBB(3)+5), :);
                target(k).RGB = imresize(roi, [50, 50]);
                % Feature representation
                [target(k).features, target(k).hogVisualization] = extractHOGFeatures(target(k).RGB);
%                 surfpoints = detectSURFFeatures(target(k).RGB);
%                 surfpoints = surfpoints.selectStrongest(10);
%                 [f1, ~] = extractFeatures(target(k).RGB, surfpoints);
%                 target(k).features = [target(k).features, f1(:)'];
%                 missing = 1540 - numel(target(k).features);
%                 target(k).features = padarray(target(k).features, [0 missing], 'post');
                [l, s] = detect_and_classify(mdl, target(k).features)
                
                
                [Gmag, Gdir] = imgradient(roi);
                
                startAngle = -180;
                finishAngle = 180;
                binNumber = 10;
                bin = zeros(1,binNumber);
                gradients = linspace(startAngle, finishAngle, binNumber);
                for i=0:binNumber-1
                    searchSpaceMin = startAngle + i/binNumber*(finishAngle-startAngle);
                    searchSpaceMax = startAngle + (i+1)/binNumber*(finishAngle-startAngle);
                    foundMin = Gdir >= searchSpaceMin;
                    foundMax = Gdir < searchSpaceMax;
                    bin(i+1) = sum(Gmag(foundMin & foundMax));
                end
                
                disp('main gradient');
                [maxVal, indVal] = max(bin)
                target(k).features = circshift(target(k).features, [1 gradients(indVal)]);
                
                if strcmp(char(l), 'target')
                    [l, s] = detect_and_classify(mdl_car_truck, target(k).features)
                
                    
                    frame_struct.maskCumulative(max(0, thisBB(2)-5):min(thisBB(2)+thisBB(4)+5,w), max(thisBB(1)-5,0):min(thisBB(1)+thisBB(3)+5)) = 255;
                    frame_struct.target(target_k).id = 'target';
                    mask = zeros(h,w,'uint8');
                    mask(max(0, thisBB(2)-5):min(thisBB(2)+thisBB(4)+5,w), max(thisBB(1)-5,0):min(thisBB(1)+thisBB(3)+5)) = 255;
                    frame_struct.target(target_k).targetMask = mask;
                    target_k = target_k + 1;
                    
                    
                    
                end
                
                figure(666); imshow(roi);
            end
            
        end

       
%%      Richard Fedora
        
        %%  main Visualization
        currentBox = M * [templateBox; ones(1,5)];
        currentBox = currentBox(1:2,:);
        overlap=warped_current*.5+previous_frame*.5;
        hold off;
%         figure(99);
%         imagesc(overlap);  
%         hold on;
%         plot(currentBox(1,:), currentBox(2,:), 'g', 'linewidth', 2);
%         drawnow;
    end
    fprintf('ping_passed\n');
    previous_frame=current_frame; 
 
end