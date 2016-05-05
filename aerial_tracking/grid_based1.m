clear;close all;
%folder containing data (a sequence of jpg images)
dirname = '../data/DARPA_VIVID/eg_test01/egtest01/';
%find the images, initialize some variables
dirlist = dir(sprintf('%s/*.jpg', dirname));
nframes = numel(dirlist);
startFrame = 1;
margin.X=20;
margin.Y=30;
current_frame=[];
previous_frame=[];
%set parameters for grid divider 
%gs-grid size
gs.x=16;
gs.y=16;
%threshold for the gradient detection
thresh=4;
%percentange of grid deleted in each loop
percent=98;
%looping number
grid_sifting_time=3;
%image related initialization
img = imread(sprintf('%s/%s', dirname, dirlist(1).name));
if (ndims(img) == 3)
    img = rgb2gray(img);
end
img = double(img) / 255;
[h, w]=size(img);
dst= [1 1; 1 h; w h; w 1]';
yt1=margin.Y+1;
yt2=h-margin.Y;
xt1=margin.X+1;
xt2=w-margin.Y;
fov_size=[yt2-yt1+1,xt2-xt1+1];
fov_vec.y=yt1:yt2;
fov_vec.x=xt1:xt2;
templateBox = [xt1 xt1 xt2 xt2 xt1; yt1 yt2 yt2 yt1 yt1];
%setting parameters for grids
[uti]= initilizer(fov_size,gs);
%feature point flag
%whether to do feature point detection or not.
feat_flag1=1;
for i=startFrame:nframes
    img = imread(sprintf('%s/%s', dirname, dirlist(i).name));
    if (ndims(img) == 3)
        img = rgb2gray(img);
    end  
    img = double(img) / 255;
    %% inialization
    current_frame=img;
    if ~isempty(previous_frame)
       
        if feat_flag1==1
            corners_C=corner_detection(current_frame(yt1:yt2,xt1:xt2),'MinimumEigenvalue',400);
            corners_P=corner_detection(previous_frame(yt1:yt2,xt1:xt2),'MinimumEigenvalue',400);
            corners_C(:,1)=corners_C(:,1)+xt1;
            corners_C(:,2)=corners_C(:,2)+yt1;
            corners_P(:,1)=corners_P(:,1)+xt1;
            corners_P(:,2)=corners_P(:,2)+yt1;
        end
             
        %% build a mask defining the extent of the template

        mask    = NaN([h, w]);
        mask_in_loop  = NaN([h, w]);
        mo_mask   = NaN([h, w]);
        %  selected area is decided by margin
   
        %% divider comes into play. 
        select_A= previous_frame(fov_vec.y,fov_vec.x); 
        [Gx,Gy]=gradient(select_A);
        select_A_grad=sqrt(Gx.^2+Gy.^2);
        % Sift out the grid that contain "gradient" information
        [sub_mask, ind]= divider(select_A_grad,gs,thresh,uti);
        % index that pass the "gradient test"
        ind_init=ind;
        % initial mask
        mask(fov_vec.y, fov_vec.x)= sub_mask;
        killed_his=[];
        %visualization;
        % set up KLT parameters
        p=[0,0,0,0,0,0];
        % record the grids' change of difference history 
        grid_his=[];
        %% KLT
        mask_converted2  = mask_converter(mask);
        for i2=1:grid_sifting_time
            % Get the inital guess from KLT. If sensor data is available,
            % this part can be a lot faster.
            tic;
            [affineLKContext, row, col, value]=InitAffineLKTracker(previous_frame, mask);
            p=KLT_tracking(current_frame,value,row,col,affineLKContext,p,0,20);
            ftime = toc;
            %% calculate the covariance of each grid
            M = [ 1+p(1) p(3) p(5); p(2) 1+p(4) p(6); 0 0 1];
            % Warp the image with current estimated Affine parameters 
            warped_current = warp_a_v(current_frame, p, dst);
            error_square=(current_frame(fov_vec.y, fov_vec.x)-warped_current(fov_vec.y,fov_vec.x)).^2;
            [mask_updated,ind_updated,killed_his,grid_his]=divider2(error_square,gs,percent,ind,killed_his, ind_init,grid_his,uti);
            mask_in_loop(fov_vec.y,fov_vec.x)= mask_updated;
            %% mask update
            mask=mask_in_loop;
            ind=ind_updated;
            %%v
            %visualization2;            
        end
        [mask_constructed] = mask_constructor(killed_his,uti,gs);
        mo_mask(fov_vec.y, fov_vec.x)=mask_constructed;       
        %% visualization 
        %visualization3;
    
        
        
        %%
%         final_sift=[ind_init,grid_his];
%                 [h_loc,~]=size(final_sift);
%                 k=h_loc-ceil(h_loc*0.4);
%          final_sift=[ind_init,grid_his];
%          final_sift=sortrows(final_sift,grid_sifting_time+1);
%          removed_grid=final_sift(k:h_loc,1);
%       [mask_constructed] = mask_constructor(removed_grid,uti,gs);
%         
%           mo_mask(fov_vec.y, fov_vec.x)=mask_constructed;
%         figure(999);
%         imshow(mo_mask.*current_frame)
%         mo_mask(isnan(mo_mask))=0;
%         st = regionprops(logical(mo_mask), 'BoundingBox' );
%         hold on 
%         for k = 1 : length(st)
%             thisBB = st(k).BoundingBox;
%             rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
%                 'EdgeColor','r','LineWidth',2 )
%         end
%         
        
        
        
        
        %%
        
        
        figure(92);
        imshow(mo_mask.*current_frame)
        mo_mask(isnan(mo_mask))=0;
        st = regionprops(logical(mo_mask), 'BoundingBox' );
        
%          hold on 
%         for k = 1 : length(st)
%             thisBB = st(k).BoundingBox;
%             rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
%                 'EdgeColor','r','LineWidth',2 )
%         end



[ BB_list_sifted,center_list ] = box_center_find( st,gs );     
        
        [hbb,~]=size(BB_list_sifted);
for k=1:hbb
 thisBB=BB_list_sifted(k,:);
 rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
        'EdgeColor','b','LineWidth',2 );
 drawnow;
end
        
 
        %%  main Visualization
        currentBox = M * [templateBox; ones(1,5)];
        currentBox = currentBox(1:2,:);
        overlap=warped_current*.5+previous_frame*.5;
        hold off;
        figure(99);
        imagesc(overlap);  
        hold on;
        plot(templateBox(1,:), templateBox(2,:), 'r', 'linewidth', 2);
        plot(currentBox(1,:), currentBox(2,:), 'g', 'linewidth', 2);
        
        if feat_flag1==1
            plot(corners_P(:,1), corners_P(:,2), 'r*');
            [hc,wc]=size(corners_C);
            corners_C = M * [corners_C'; ones(1,hc)];
            corners_C = corners_C(1:2,:);
            corners_C=corners_C';
            plot(corners_C(:,1), corners_C(:,2), 'g*');
        end
        drawnow;
    end
    fprintf('ping_passed\n');
    previous_frame=current_frame; 
 
end