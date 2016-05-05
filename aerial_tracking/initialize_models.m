function [mdl_target_background,  mdl_car_truck, featureSapace] = initialize_models(params)
% TODO: Add explicit explanations here


if(params.isAnnotated == true)
    load([params.annotationLocation , params.annotationFileName], 'annotation');
else
    annotation = annotate_data_set(params.isVideo, params.datasetLocation, params.fileName, [params.annotationLocation, params.annotationFileName], params.trainingSkip);
    annotation = annotate_background(annotation);
    params.isAnnotated = true;
    featureSpace = construct_feature_space(annotation);
    featureSpace.features(1992,:) = [];
    feature_space = featureSpace.features;

    indBack(strcmp(featureSpace.id(:), 'background')) = 1;
    indCar(strcmp(featureSpace.id(:), 'car')) = 1;
    indTruck(strcmp(featureSpace.id(:), 'truck')) = 1;

    feature_space_car = feature_space(indCar==1,1:900);
    feature_space_truck = feature_space(indTruck==1,1:900);
    feature_space_background = feature_space(indBack==1,1:900);

    feature_space_target = [feature_space_car; feature_space_truck];

    [nTarget, ~]= size(feature_space_target);
    [nBackground, ~] = size(feature_space_background);

    labels = {};
    params.numNeighbors = 1;
    for i=1:nTarget
        labels{i} = 'target';
    end


    for j=1:2*nTarget
        labels{nTarget+j} = 'background';
    end

    feature_random_background = feature_space_background(randsample(nBackground,2*nTarget),:);

    feature_space_target = [feature_space_target; feature_random_background];

    f_.features = feature_space_target;
    f_.id = labels;
    mdl_target_background = training_knn(f_, params.numNeighbors, params.searchMethod, params.distanceMetric, params.Standardize, [params.modelLocation, params.modelFileName]);
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
    %%
    feature_space_target = [feature_space_car; feature_space_truck];
    f_.features = feature_space_target;

    [nCar, ~]= size(feature_space_car);
    [nTruck, ~] = size(feature_space_truck);

    labels = {};


    for i=1:nCar
        labels{i} = 'car';
    end


    for j=1:nTruck
        labels{nCar+j} = 'truck';
    end


    f_.id = labels;
    mdl_car_truck = training_knn(f_, params.numNeighbors, params.searchMethod, params.distanceMetric, params.Standardize, [params.modelLocation, params.modelFileName]);

    [nRows, ~] = size(feature_space_target);

    sumTarget = 0;

    for i=1:nCar
        [x,y] = predict(mdl_car_truck, feature_space_car(i,:));
        if(strcmp(x, 'car'))
            sumTarget = sumTarget + 1;
        end
    end

    for i=1:nTruck
        [x,y] = predict(mdl_car_truck, feature_space_truck(i,:));
        if(strcmp(x, 'truck'))
            sumTarget = sumTarget + 1;
        end
    end

    precision = sumTarget / nTarget *100

    params.isTrained = true;
end

if(params.isTrained == true)
    load([params.modelLocation, params.modelFileName], 'mdl');
else
        featureSpace = construct_feature_space(annotation);
    featureSpace.features(1992,:) = [];
    feature_space = featureSpace.features;

    indBack(strcmp(featureSpace.id(:), 'background')) = 1;
    indCar(strcmp(featureSpace.id(:), 'car')) = 1;
    indTruck(strcmp(featureSpace.id(:), 'truck')) = 1;

    feature_space_car = feature_space(indCar==1,1:900);
    feature_space_truck = feature_space(indTruck==1,1:900);
    feature_space_background = feature_space(indBack==1,1:900);

    feature_space_target = [feature_space_car; feature_space_truck];

    [nTarget, ~]= size(feature_space_target);
    [nBackground, ~] = size(feature_space_background);

    labels = {};
    params.numNeighbors = 1;
    for i=1:nTarget
        labels{i} = 'target';
    end


    for j=1:2*nTarget
        labels{nTarget+j} = 'background';
    end

    feature_random_background = feature_space_background(randsample(nBackground,2*nTarget),:);

    feature_space_target = [feature_space_target; feature_random_background];

    f_.features = feature_space_target;
    f_.id = labels;
    mdl_target_background = training_knn(f_, params.numNeighbors, params.searchMethod, params.distanceMetric, params.Standardize, [params.modelLocation, params.modelFileName]);
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
    %%
    feature_space_target = [feature_space_car; feature_space_truck];
    f_.features = feature_space_target;

    [nCar, ~]= size(feature_space_car);
    [nTruck, ~] = size(feature_space_truck);

    labels = {};


    for i=1:nCar
        labels{i} = 'car';
    end


    for j=1:nTruck
        labels{nCar+j} = 'truck';
    end


    f_.id = labels;
    mdl_car_truck = training_knn(f_, params.numNeighbors, params.searchMethod, params.distanceMetric, params.Standardize, [params.modelLocation, params.modelFileName]);

    [nRows, ~] = size(feature_space_target);

    sumTarget = 0;

    for i=1:nCar
        [x,y] = predict(mdl_car_truck, feature_space_car(i,:));
        if(strcmp(x, 'car'))
            sumTarget = sumTarget + 1;
        end
    end

    for i=1:nTruck
        [x,y] = predict(mdl_car_truck, feature_space_truck(i,:));
        if(strcmp(x, 'truck'))
            sumTarget = sumTarget + 1;
        end
    end

    precision = sumTarget / nTarget *100
end    

end

