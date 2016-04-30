%%% Simple video annotation tool
%%% Murat Ambarkutuk
%%% 03/28/2016
%%% Virginia Tech
%% Clear everything
clc; clear all; close all;
fileToRead = ['../data/DARPA_VIVID/eg_test01/frame.mat'];

load(fileToRead, 'annotation');
featureSpace.features = [];
featureSpace.id = [];
nFrames = numel(annotation.frame);
for i=1:nFrames
    objectsMarked = numel(annotation.frame(i).targetIndividual);
    for j=1:objectsMarked
        featureSize = numel(annotation.frame(i).targetIndividual(j).features);
        missing = 1540 - featureSize;
        features = padarray(annotation.frame(i).targetIndividual(j).features, [0 missing], 'post');
        featureSpace.features = [featureSpace.features; features];
        annotation.frame(i).targetIndividual(j).id;
        featureSpace.id = [featureSpace.id; annotation.frame(i).targetIndividual(j).id];
    end
end

mdl = fitcknn(featureSpace.features, featureSpace.id,'NumNeighbors',2,...
    'NSMethod','exhaustive','Distance','minkowski',...
    'Standardize',1);