%main_script
clear;close all;
%folder containing data (a sequence of jpg images)
dirname = '../data/egtest';
%find the images, initialize some variables
dirlist = dir(sprintf('%s/*.jpg', dirname));
nframes = numel(dirlist);
startFrame = 1;




params.margin.X=20;
params.margin.Y=30;
current_frame=[];
previous_frame=[];
%set parameters for grid divider 
%params.gs-grid size
params.gs.x=16;
params.gs.y=16;
%threshold for the gradient detection
params.thresh=4;
%percentange of grid deleted in each loop
params.percent=98;
%looping number
params.grid_sifting_time=3;
%image related initialization
img = imread(sprintf('%s/%s', dirname, dirlist(1).name));
if (ndims(img) == 3)
    img = rgb2gray(img);
end
img = double(img) / 255;
[params.h, params.w]=size(img);

params.dst= [1 1; 1 params.h; params.w params.h; params.w 1]';
params.yt1=params.margin.Y+1;
params.yt2=params.h-params.margin.Y;
params.xt1=params.margin.X+1;
params.xt2=params.w-params.margin.Y;
params.fov_size=[params.yt2-params.yt1+1,params.xt2-params.xt1+1];
params.fov_vec.y=params.yt1:params.yt2;
params.fov_vec.x=params.xt1:params.xt2;
params.templateBox = [params.xt1 params.xt1 params.xt2 params.xt2 params.xt1;params.yt1 params.yt2 params.yt2 params.yt1 params.yt1];
%setting parameters for grids
[params.uti]= initilizer(params.fov_size,params.gs);
%feature point flag
%params.wparams.hetparams.her to do feature point detection or not.
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
        [ st, M ] = orson_fag(current_frame, previous_frame, params);
    end
    fprintf('ping_passed\n');
    previous_frame=current_frame; 
 
end