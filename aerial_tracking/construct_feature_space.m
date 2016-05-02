function featureSpace = construct_feature_space(annotation)
% TODO: Add explicit explanations here
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
end

