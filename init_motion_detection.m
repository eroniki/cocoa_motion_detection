function frameSequence = init_motion_detection(folderName)
% TODO: Add explicit explanations here

files = dir(folderName);
% Delete "." and ".." from the list
frameNumber = numel(files)-2;

for i=1:frameNumber
    frameSequence(i).fileName = [folderName, num2str(i-1) , '.jpg'];
%     frameSequence(i).fileName
    frameSequence(i).image = imread(frameSequence(i).fileName);
end
end

