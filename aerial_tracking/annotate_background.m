function [annotation] = annotate_background(annotation)
% TODO: Add explicit explanations here
numFrames = numel(annotation.frame);
[row, col, ~] = size(annotation.frame(1).frame);

for frameNum=1:numFrames
    tic;
%     figure(1); imshow(annotation.frame(frameNum).maskCumulative);
    for i=1:10:row-50
        for j=1:10:col-50
            if sum(annotation.frame(frameNum).maskCumulative(i:i+50,j:j+50,:))==0
                numTargets = numel(annotation.frame(frameNum).targetIndividual);
                
                annotation.frame(frameNum).targetIndividual(numTargets+1).id = {'background'};
                annotation.frame(frameNum).targetIndividual(numTargets+1).targetRGB = annotation.frame(frameNum).frame(i:i+50,j:j+50,:);
                
                roi = annotation.frame(frameNum).frame(i:i+50,j:j+50,:);
                [annotation.frame(frameNum).targetIndividual(numTargets+1).features, annotation.frame(frameNum).targetIndividual(numTargets+1).hogVisualization] = extractHOGFeatures(roi);
                surfpoints = detectSURFFeatures(rgb2gray(roi));
                surfpoints = surfpoints.selectStrongest(10);
                [f1, ~] = extractFeatures(rgb2gray(roi), surfpoints);
                annotation.frame(frameNum).targetIndividual(numTargets+1).features = [annotation.frame(frameNum).targetIndividual(numTargets+1).features, f1(:)'];
%                 figure(2); imshow(annotation.frame(frameNum).frame); hold on;
%                 rectangle('Position', [j, i , 50, 50]);
%                 drawnow;
%                 pause(0.02);
            end
        end
    end
   toc;
end
end