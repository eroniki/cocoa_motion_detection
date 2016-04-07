%% Clear everything
clc; clear all; close all;
%% Set initial variables
folderName = 'data/';
videoName ='/home/murat/opencv/samples/data/768x576.avi';
% Neighboring frames
p = 5;
%% Init
disp('Start Initialization');
frameSequence = init_motion_detection(videoName, 1);
disp('Finish Initialization');
%% Accumulative Frame Differencing
disp('Start AFD');
accumulativeFrameDifference = accumulative_frame_differencing(frameSequence,p);
disp('Finish AFD');
%% Background Modelling
background = backgroundModelling(frameSequence);