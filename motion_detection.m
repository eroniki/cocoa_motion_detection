%% Clear everything
clc; close all; clearvars -except frameSequence p
%% Set initial variables
folderName = 'data/';
videoName ='/home/murat/opencv/samples/data/768x576.avi';
% Neighboring frames
p = 5;
%% Init
disp('Start Initialization');
frameSequence = init_motion_detection(folderName, 0);
disp('Finish Initialization');
%% Motion Detection
foreground = motion_detection_combined(frameSequence,p);