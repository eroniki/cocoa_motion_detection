%%% Simple video annotation tool
%%% Murat Ambarkutuk
%%% 03/28/2016
%%% Virginia Tech
%% Clear everything
clc; clear all; close all;
%% Create a video reader object
% If this line crashes the script, 
% it is likely to result from a missing G-Streamer plugin or G-Streamer
% itself; most likely missing plugin: gstreamer0.10-ffmpeg plugin 
fileName = 'video.mp4';
fileToRead = [fileName,'.mat'];

load(fileToRead, 'annotation');
featureSpace.features = [];
featureSpace.id = [];
nFrames = numel(annotation.frame);
for i=1:nFrames
    objectsMarked = numel(annotation.frame(i).targetIndividual);
    for j=1:objectsMarked
        featureSpace.features = [featureSpace.features; annotation.frame(i).targetIndividual(j).features];
        annotation.frame(i).targetIndividual(j).id;
        featureSpace.id = [featureSpace.id; annotation.frame(i).targetIndividual(j).id];
    end
end

mdl = fitcknn(featureSpace.features, featureSpace.id,'NumNeighbors',2,...
    'NSMethod','exhaustive','Distance','minkowski',...
    'Standardize',1);

label = predict(mdl,featureSpace.features) 