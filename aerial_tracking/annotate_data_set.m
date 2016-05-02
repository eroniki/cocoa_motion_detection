function [annotation] = annotate_data_set(isVideo, datasetLocation, fileName, annotationFileName, trainingSkip)
% TODO: Add explicit explanations here
if isVideo==true
    vidObj = VideoReader([dataSetLocation, fileName]);
    frameNum = 1;
    while hasFrame(vidObj)
        info = sprintf('Frame Number = %d', num2str(frameNum));
        disp(info);
        % Obtain the frame
        frame = readFrame(vidObj);
        % Extract HoG features for the frame
        % Create a new empty frame with the same size of the input frame
        annotation.frame(frameNum) = annotator(frame);
        save(annotationFileName, 'annotation');
        frameNum = frameNum + 1;        
    end
else
    imageNames = dir(fullfile(datasetLocation,'*.jpg'));
    imageNames = {imageNames.name}';
    frameNumber = numel(imageNames);
    k = 1;
    for frameNum=1:trainingSkip:frameNumber
        info = sprintf('Frame Number = %d, Total Number of Frames: %d', num2str(frameNum), num2str(frameNumber));
        disp(info);
        % Obtain the frame
        frame = imread([datasetLocation,imageNames{frameNum}]);
        % Extract features for the frame given the bounding boxes
        % provided by the user
        % Concatinate the response
        annotation.frame(k) = annotator(frame);
        save(annotationFileName, 'annotation'); 
        k = k + 1;
    end
end
end

