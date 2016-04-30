%%% Simple video annotation tool
%%% Orson Lin, Richard Fedora, Murat Ambarkutuk
%%% 04/30/2016
%%% Virginia Tech
%% Initialization
clear all; close all; clc;
%% Variables and parameters
params.isAnnotated = false;
params.isTrained = false;
params.datasetLocation = '../data/DARPA_VIVID/eg_test01/egtest01/';
params.fileName = '';
params.modelLocation = '';
params.modelFileName = 'egtest01_model.mat';
params.annotationLocation = '';
params.annoationFileName = 'egtest01_annotation.mat';
params.filePrefix = 'frame';
params.isVideo = false;
params.annotationToolLocation = '../annotator';
params.trainingSkip = 50;
%% Create Path
addpath(genpath(params.annotationToolLocation));

%% Training Routine
% Check if the annotation is completed for the dataset
if params.isAnnotated == true;
    % Check if training is completed
    if params.isTrained == true
        load(modelLocation, 'mdl');
    else
        load([params.annotationLocation, params.annotationFileName], 'annotation');
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
        save([params.modelLocation, params.modelFileName], 'mdl');
    end
% Start annotation routine to create the training model    
elseif params.isAnnotated == false
    if params.isVideo==true
        vidObj = VideoReader([params.dataSetLocation, params.fileName]);
        frameNum = 1;
        while hasFrame(vidObj)
            info = sprintf('Frame Number = %d', num2str(frameNum));
            disp(info);
            % Obtain the frame
            frame = readFrame(vidObj);
            % Extract HoG features for the frame
            % Create a new empty frame with the same size of the input frame
            annotation.frame(frameNum) = annotator(frame);
            save(params.modelLocation, 'annotation');
            frameNum = frameNum + 1;        
        end
    else
        imageNames = dir(fullfile(params.datasetLocation,'*.jpg'));
        imageNames = {imageNames.name}';
        % Delete ".", ".." and the video file from the list
        frameNumber = numel(imageNames);
        k = 1;
        for frameNum=1:params.trainingSkip:frameNumber
            % Obtain the frame
            frame = imread([params.datasetLocation,imageNames{frameNum}]);
            % Extract features for the frame given the bounding boxes
            % provided by the user
            % Concatinate the response
            annotation.frame(k) = annotator(frame);
            save([params.modelLocation, params.annoationFileName], 'annotation'); 
            k = k + 1;
        end
    end
    %%
    params.isAnnotated == true;
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
    %%

    mdl = fitcknn(featureSpace.features, featureSpace.id,'NumNeighbors', 60,...
        'NSMethod','exhaustive','Distance','minkowski',...
        'Standardize',1);
    params.isTrained = true;
end
%% Main Routine
%% Motion Compensation (Orson Lin)

%% Detection and Classification Routine (Murat Ambarkutuk)
% TODO: Anaylze the grids for possible objects
% TODO: Background differencing for the static objects (using homography)
% TODO: 
if exist('mdl') == 1
    [label, confidence] = detect_and_classify(mdl,featureSpace.features);
    [label, featureSpace.id]
    recall = sum(strcmp(label,featureSpace.id))/numel(featureSpace.id)
    
% else
%     if exist([params.modelLocation, params.modelFileName]) == 2
%         load([params.modelLocation, params.modelFileName], 'mdl');
%     else
%         load([params.modelLocation, params.modelFileName], 'annotation');
%         featureSpace.features = [];
%         featureSpace.id = [];
%         nFrames = numel(annotation.frame);
%         for i=1:nFrames
%             objectsMarked = numel(annotation.frame(i).targetIndividual);
%             for j=1:objectsMarked
%                 featureSize = numel(annotation.frame(i).targetIndividual(j).features);
%                 missing = 1540 - featureSize;
%                 features = padarray(annotation.frame(i).targetIndividual(j).features, [0 missing], 'post');
%                 featureSpace.features = [featureSpace.features; features];
%                 annotation.frame(i).targetIndividual(j).id;
%                 featureSpace.id = [featureSpace.id; annotation.frame(i).targetIndividual(j).id];
%             end
%         end
% 
%         mdl = fitcknn(featureSpace.features, featureSpace.id,'NumNeighbors',2,...
%             'NSMethod','exhaustive','Distance','minkowski',...
%             'Standardize',1);
%     end
%     error('Training model could not find!');
end
%% Tracking Routine (Richard Fedora)
