clear;close all;
%folder containing data (a sequence of jpg images)
dirname = '../data/simpse2';

%find the images, initialize some variables
dirlist = dir(sprintf('%s/*.jpg', dirname));
nframes = numel(dirlist);
nframes=30;
startFrame = 1;

margin.X=20;
margin.Y=30;


%set parameters for grid devider 
gs.x=16;
gs.y=16;
thresh=3;



%loop over the images in the video sequence
for i=startFrame:nframes
    img = imread(sprintf('%s/%s', dirname, dirlist(i).name));
    
    if (ndims(img) == 3)
        img = rgb2gray(img);
    end
    
    img = double(img) / 255;
%% if this is the first image, this is the frame to mark a template on
    if (i == startFrame)
        %display the image and ask the user to click where the template is
        hold off;
        figure(1)
        imshow(img);
        hold on;
        drawnow;
        title('Click on the upper left corner of the template region to track');
        [xt1, yt1] = ginput(1);
        title('Click on the lower right corner of the template region to track');
        [xt2, yt2] = ginput(1);
        yt1 = round(yt1); yt2 = round(yt2);
        xt1 = round(xt1); xt2 = round(xt2);
%         
%         xt1=443;xt2=583;
%         yt1=76;yt2=172;
  




% 
%         [h,w]=size(img);
%         yt1=1+margin.Y; yt2=h-margin.Y;
%         xt1=1+margin.X; xt2=w-margin.X;
        
        
        
        %% build a mask defining the extent of the template
        template = img;
        mask     = NaN(size(template));
        mask2    = NaN(size(template));
        mask(yt1:yt2, xt1:xt2) = 1;        
        %% divider comes into play. This part has some redundancy with tracking initialization
        select_A= img(yt1:yt2, xt1:xt2); 
        [Gx,Gy]=gradient(select_A);
        select_A_grad=sqrt(Gx.^2+Gy.^2);
        sub_mask = divider(select_A_grad,gs,thresh);
        mask2(yt1:yt2, xt1:xt2)= sub_mask; 
        
        
        figure(67);
        subplot(1,2,1)
        imshow(mask);
        subplot(1,2,2)
        imshow(mask2);
        %% Initialize warping parameter  
        %warp_p = [0,0,xt1-1;0,0,yt1-1];
        warp_p = [0,0,0;0,0,0];
        %% Template verticies, rectangular [minX minY; minX maxY; maxX maxY; maxX minY]
%         tmplt_pts = [1 1; 1 h; w h; w 1]';
         templateBox = [xt1 xt1 xt2 xt2 xt1; yt1 yt2 yt2 yt1 yt1];
        %initialize the LK tracker for this template
        [affineLKContext, row, col, value] = InitAffineLKTracker(template,mask);
    end
    %actually do the LK tracking to update transform for current frame
    tic;                                                                  
    warp_p =KLT_tracking(img,value,row,col,affineLKContext,warp_p); 
    ftime = toc;                                                           
    
    %% draw the location of the template onto the current frame, display
%     M = [warp_p; 0 0 1];
%     M(1,1) = M(1,1) + 1;
%     M(2,2) = M(2,2) + 1;
    M = [ 1+warp_p(1) warp_p(3) warp_p(5); warp_p(2) 1+warp_p(4) warp_p(6); 0 0 1];
    currentBox = M * [templateBox; ones(1,5)];
    currentBox = currentBox(1:2,:);
    hold off;
    figure(6)
    imshow(img);
    hold on;
    plot(currentBox(1,:), currentBox(2,:), 'g', 'linewidth', 2);
    title(sprintf('frame #%g. %g FPS', i, 1./ftime));
    drawnow;
    
end