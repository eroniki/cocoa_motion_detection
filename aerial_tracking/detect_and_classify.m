function [label, score] = detect_and_classify(mdl, featureVector)
% TODO: Add explicit explanations here
[label, score] = predict(mdl,featureVector);
end

