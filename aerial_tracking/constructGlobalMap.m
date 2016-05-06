function [globalMap, cumulativeM] = constructGlobalMap(globalFrame, frame, M, globalM)
% TODO: Add explicit explanations here
    [h, w] = size(frame);
    t = M;
    M(:,3) = t(3,:)';
    M(3,:) = t(:,3)';
    
    tform = affine2d(M);
    Tinv = invert(tform);
    
    
    
    cumulativeM= Tinv.T*globalM.T;
    blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');
    cumulativeM = affine2d(cumulativeM);
    
%     [xlim(1,:), ylim(1,:)] = outputLimits(affine2d(eye(3)), [1 size(globalFrame,2)], [1 size(globalFrame,1)]);
    [xlim(1,:), ylim(1,:)] = outputLimits(cumulativeM, [1 w], [1 h]);
    
    xMin = min([1; xlim(:)]);
    xMax = max([w; xlim(:)]);

    yMin = min([1; ylim(:)]);
    yMax = max([h; ylim(:)]);

    % Width and height of panorama.
    width  = round(xMax - xMin);
    height = round(yMax - yMin);
    
    xLimits = [xMin xMax];
    yLimits = [yMin yMax];
    
    panoramaView = imref2d(size(frame), xLimits, yLimits);
    
    panoramaView2 = imref2d(size(globalFrame));
    
    % Initialize the "empty" panorama.
    globalMap = zeros([height,width], 'like', globalFrame);
    
    warpedImage = imwarp(globalFrame, affine2d(eye(3)), 'OutputView', panoramaView2);
    globalMap = step(blender, globalMap, warpedImage, warpedImage);
    
    warpedImage = imwarp(frame, cumulativeM, 'OutputView', panoramaView2);
    % Overlay the warpedImage onto the panorama.
    globalMap = step(blender, globalMap, warpedImage, warpedImage);
end

