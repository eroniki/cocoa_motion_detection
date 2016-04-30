clear;close all;
%folder containing data (a sequence of jpg images)
dirname = '../data/egtest';
%dirname = '../data/simpse2';
%find the images, initialize some variables
dirlist = dir(sprintf('%s/*.jpg', dirname));
nframes = numel(dirlist);
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
    img = imread(sprintf('%s/%s', dirname, dirlist(i).name));
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
        figure(1)
        subplot(1,2,2)
        imshow(current_frame);
        title('current frame');
        subplot(1,2,1)
        imshow(previous_frame);
        title('previous frame');
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
            figure(90);
             imshow(mask_in_loop.*current_frame);
            %imshow(mask_in_loop);
            title('Current Mask');
            mask_converted1  = mask_converter(mask_in_loop);
            mask_converted2=mask_converted1+mask_converted2;
            figure(85);
            imagesc(mask_converted2);
            title('Mask update history');
            %% mask update
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
        for k = 1 : length(st)
            thisBB = st(k).BoundingBox;
            rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
                'EdgeColor','r','LineWidth',2 )
        end
        
        
        
        %%  main Visualization
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
    fprintf('ping_passed\n');
    previous_frame=current_frame; 
 
end