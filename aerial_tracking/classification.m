function [frame_struct] = classification(boundingBox, mdl_target_background, mdl_car_truck, params, visualize)
% TODO: Add explicit explanations here
frame_struct = struct();

frame_struct.maskCumulative = zeros(params.h, params.w, 'uint8');
target_k=1;
for k=1:length(boundingBox)
    bb = [];
    bb = [bb; int16(boundingBox(k).BoundingBox);];

    if bb(4)~=params.gs.x && bb(3) ~= params.gs.y && (bb(4) < params.gs.x * 5 || bb(3) < params.gs.y *5)
        rectangle('Position', [bb(1),bb(2),bb(3),bb(4)],...
            'EdgeColor','r','LineWidth',2 );
        roi = params.current_frame(max(0, bb(2)-5):min(bb(2)+bb(4)+5, params.w), max(bb(1)-5,0):min(bb(1)+bb(3)+5), :);
        target(k).RGB = imresize(roi, [50, 50]);
        % Feature representation
        [target(k).features, target(k).hogVisualization] = extractHOGFeatures(target(k).RGB);
    %                 surfpoints = detectSURFFeatures(target(k).RGB);
    %                 surfpoints = surfpoints.selectStrongest(10);
    %                 [f1, ~] = extractFeatures(target(k).RGB, surfpoints);
    %                 target(k).features = [target(k).features, f1(:)'];
    %                 missing = 1540 - numel(target(k).features);
    %                 target(k).features = padarray(target(k).features, [0 missing], 'post');
        [label_target_background, s_target_background] = detect_and_classify(mdl_target_background, target(k).features);

        if strcmp(char(label_target_background), 'target')
            [label_car_truck, score_car_truck] = detect_and_classify(mdl_car_truck, target(k).features);


            frame_struct.maskCumulative(max(0, bb(2)-5):min(bb(2)+bb(4)+5, params.w), max(bb(1)-5,0):min(bb(1)+bb(3)+5)) = 255;
            frame_struct.target(target_k).id = 'target';
            frame_struct.target(target_k).confidence = score_car_truck;
            mask = zeros(params.h, params.w,'uint8');
            mask(max(0, bb(2)-5):min(bb(2)+bb(4)+5, params.w), max(bb(1)-5,0):min(bb(1)+bb(3)+5)) = 255;
            frame_struct.target(target_k).targetMask = mask;
            target_k = target_k + 1;
        end

        if(visualize)
            figure(666); imshow(roi);
        end
    end

end

end

