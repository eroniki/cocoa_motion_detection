clc;

feature_space = featureSpace.features;

indCar;
indBack;
indTruck;

indBack(strcmp(featureSpace.id(:), 'background')) = 1;
indCar(strcmp(featureSpace.id(:), 'car')) = 1;
indTruck(strcmp(featureSpace.id(:), 'truck')) = 1;

feature_space_car = feature_space(indCar==1,:);
feature_space_truck = feature_space(indTruck==1,:);
feature_space_background = feature_space(indBack==1,:);

feature_space_target = [feature_space_car; feature_space_truck];

[nTarget, ~]= size(feature_space_target);
[nBackground, ~] = size(feature_space_background);

labels = {};
params.numNeighbors = 3;
for i=1:nTarget
    labels{i} = 'target';
end


for j=1:3*nTarget
    labels{nTarget+j} = 'background';
end

feature_random_background = feature_space_background(randsample(nBackground,3*nTarget),:);

feature_space_target = [feature_space_target; feature_random_background];

f_.features = feature_space_target;
f_.id = labels;
mdl_target_background = training_knn(f_, params.numNeighbors, params.searchMethod, params.distanceMetric, params.Standardize, [params.modelLocation, params.modelFileName]);
mdl = mdl_target_background;
[nRows, ~] = size(feature_space_target);

sumTarget = 0;

for i=1:106
    [x,y] = predict(mdl_target_background, feature_space_car(i,:));
    if(strcmp(x, 'target'))
        sumTarget = sumTarget + 1;
    end
end

for i=1:35
    [x,y] = predict(mdl_target_background, feature_space_truck(i,:));
    if(strcmp(x, 'target'))
        sumTarget = sumTarget + 1;
    end
end

precision = sumTarget / nTarget *100