%% Clear everything
clc; clear all; close all;
%% Set initial variables
folderName = 'data/';
% Neighboring frames
p = 5;
%% Init
frameSequence = init_motion_detection(folderName);
%% Accumulative Frame Differencing
accumulativeFrameDifference = accumulative_frame_differencing(frameSequence,p);
%% Background Modelling
