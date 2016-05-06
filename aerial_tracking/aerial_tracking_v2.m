%%% Aerial Tracking System 
%%% Orson Lin, Richard Fedora, Murat Ambarkutuk
%%% 04/30/2016
%%% Virginia Tech
%% Initialization
clear all; close all; clc;
%% Variables and parameters
params.isAnnotated = true;
params.isTrained = false;
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
params.margin.X=20;
params.margin.Y=30;
params.current_frame=[];
params.previous_frame=[];

%set parameters for grid devider 
params.gs.x=16;
params.gs.y=16;
params.thresh=3;
params.percent=98;
params.grid_sifting_time=3;
params.startFrame = 1;
params.skipFrames = 1;

params.imageNames = dir(fullfile(params.datasetLocation,'*.jpg'));
params.imageNames = {params.imageNames.name}';
params.nFrames = numel(params.imageNames);


params.MGlobal = eye(3,3);
%image related initialization
img = imread([params.datasetLocation, params.imageNames{1}]);
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
params.globalFrame = [];
%setting parameters for grids
[params.uti]= initilizer(params.fov_size,params.gs);
params.MGlobal = affine2d(eye(3));
%feature point flag
%params.wparams.hetparams.her to do feature point detection or not.
feat_flag1=1;

%%
global path_circle_size;
global obj;
global tracks;
global nextId;
global mean_shift_kf_tag;  
path_circle_size = 3;
obj = setupSystemObjects();
tracks = initializeTracks(); % Create an empty array of tracks.
nextId = 1; % ID of the next track
mean_shift_kf_tag = 'kf';  
%% Create Path
addpath(genpath(params.annotationToolLocation));

%% Initialize Models
% [mdl_target_background, mdl_car_truck] = initialize_models(params);
load('matlab.mat');
%% Main Routine
for i=params.startFrame:params.skipFrames:params.nFrames
%%     Orson Lin
    img = imread([params.datasetLocation,params.imageNames{i}]);
    if (ndims(img) == 3)
        img = rgb2gray(img);
    end  
    img = double(img) / 255; 
    %% inialization
    params.current_frame=img;
    
    if ~isempty(params.previous_frame)      
        [boundingBox, M, warped_current] = motion_compensation(params.current_frame, params.previous_frame, params);
        
        [params.globalFrame, params.MGlobal] = constructGlobalMap(params.globalFrame, img, M, params.MGlobal);
        %%     Murat Ambarkutuk
        [frame_struct] = classification(boundingBox, mdl_target_background, mdl_car_truck, params, false); 
        %%     Richard Fedora
        multiObjectTracking(frame_struct, warped_current, M);
    else
        params.globalFrame = img;
    end
    
    
    figure(666);
    imshow(params.globalFrame);
    fprintf('ping_passed\n');
    params.previous_frame= params.current_frame;     
end