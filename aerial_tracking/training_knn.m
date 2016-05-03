function mdl = training_knn(featureSpace, numNeighbors, searchMethod, distanceMetric, standardize, saveLocation)
% TODO: Add explicit explanations here
mdl = fitcknn(featureSpace.features, featureSpace.id,'NumNeighbors', numNeighbors,...
            'NSMethod', searchMethod,'Distance', distanceMetric,...
            'Standardize', standardize)
if char(saveLocation, '')
    save(saveLocation, 'mdl');
end
end

