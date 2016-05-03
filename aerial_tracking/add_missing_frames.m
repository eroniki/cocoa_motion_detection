imageNames = dir(fullfile(datasetLocation,'*.jpg'));
imageNames = {imageNames.name}';
frameNumber = numel(imageNames);
k = 1;
for frameNum=1:params.ftrainingSkip:frameNumber
    info = sprintf('Frame Number = %d, Total Number of Frames: %d', num2str(frameNum), num2str(frameNumber));
    disp(info);
    % Obtain the frame
    frame = imread([datasetLocation,imageNames{frameNum}]);
    % Extract features for the frame given the bounding boxes
    % provided by the user
    % Concatinate the response
    annotation.frame(k).frame = frame;
%     annotation.frame(k) = annotator(frame);
    save(annotationFileName, 'annotation'); 
    k = k + 1;
end