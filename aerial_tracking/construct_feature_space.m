function featureSpace = construct_feature_space(annotation)
% TODO: Add explicit explanations here
featureSpace.features = [];
featureSpace.id = [];
nFrames = numel(annotation.frame);
for i=1:nFrames
    backgroundInd = [];
    objectsMarked = numel(annotation.frame(i).targetIndividual);
    for j=1:objectsMarked
        fprintf('Frame %%: %f, Target (Foreground) %%: %f \n', i/nFrames*100, j/objectsMarked*100);
        if strcmp(char(annotation.frame(i).targetIndividual(j).id), 'background') == 1
            backgroundInd = [backgroundInd, j];
        else
            featureSize = numel(annotation.frame(i).targetIndividual(j).features);
            missing = 1540 - featureSize;
            features = padarray(annotation.frame(i).targetIndividual(j).features, [0 missing], 'post');
            featureSpace.features = [featureSpace.features; features];
            featureSpace.id = [featureSpace.id; annotation.frame(i).targetIndividual(j).id];       
        end
    end
    maxSample = min(50,numel(backgroundInd));

    sampledWindows = randsample(backgroundInd, maxSample);    
    
    for k=1:maxSample
        fprintf('Frame %%: %f, Target (Background) %%: %f \n', i/nFrames*100, k/maxSample*100);
        featureSize = numel(annotation.frame(i).targetIndividual(sampledWindows(k)).features);
        missing = 1540 - featureSize;
        features = padarray(annotation.frame(i).targetIndividual(sampledWindows(k)).features, [0 missing], 'post');
        featureSpace.features = [featureSpace.features; features];
        featureSpace.id = [featureSpace.id; {'background'}];    
    end
end

save('feature_Space.mat', 'featureSpace');    
end

