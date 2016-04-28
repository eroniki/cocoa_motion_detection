function frameSequence = init_motion_detection(folderName, isVideo)
% TODO: Add explicit explanations here

if ~isVideo
    files = dir(folderName);
    % Delete ".", ".." and the video file from the list
    frameNumber = numel(files)-3;
    for i=1:frameNumber
        frameSequence(i).fileName = [folderName, num2str(i-1) , '.jpg'];
        frameSequence(i).image_rgb = imresize(imread(frameSequence(i).fileName), [200, 200]);
        
        frameSequence(i).image_gray = rgb2gray(frameSequence(i).image_rgb);
    end
else
    vidObj = VideoReader(folderName);
    i=1;
    while hasFrame(vidObj)
        frameSequence(i).image_rgb = imresize(readFrame(vidObj), [200, 200]);
        frameSequence(i).image_gray = rgb2gray(frameSequence(i).image_rgb);
        i = i+1;
    end
end
end

