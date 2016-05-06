function displayTrackingResults(current_frame,mask,imageName)

    global obj;
    global tracks;
    
    % Convert the frame and the mask to uint8 RGB.
    frame = im2uint8(current_frame);
    mask = uint8(repmat(mask, [1, 1, 3])) .* 255;

    minVisibleCount = 8;
    if ~isempty(tracks)

        % Noisy detections tend to result in short-lived tracks.
        % Only display tracks that have been visible for more than
        % a minimum number of frames.
        reliableTrackInds = ...
            [tracks(:).totalVisibleCount] > minVisibleCount;
        reliableTracks = tracks(reliableTrackInds);

        % Display the objects. If an object has not been detected
        % in this frame, display its predicted bounding box.
        if ~isempty(reliableTracks)
            % Get bounding boxes.
            bboxes = cat(1, reliableTracks.bbox);
            paths = cat(1, reliableTracks.paths);
            % Get ids.
            ids = int32([reliableTracks(:).id]);

            % Create labels for objects indicating the ones for
            % which we display the predicted rather than the actual
            % location.
            labels = cellstr(int2str(ids'));
            circle_labels = cellstr(int2str(ids'));
            c_labels = [];
            for i=1:size(reliableTracks,2)
                for j=1:size(reliableTracks(i).paths,1)
                    c_labels = [c_labels;circle_labels(i)];
                end
            end
            predictedTrackInds = ...
                [reliableTracks(:).consecutiveInvisibleCount] > 0;
            isPredicted = cell(size(labels));
            isPredicted(predictedTrackInds) = {' predicted'};
            labels = strcat(labels, isPredicted);

            % Draw the objects on the frame.
%             frame = insertObjectAnnotation(frame, 'rectangle', ...
%                 bboxes, labels);

%             frame = insertObjectAnnotation(frame, 'circle', ...
%                 paths, c_labels);
% 
%             Draw the objects on the mask.
%             mask = insertObjectAnnotation(mask, 'rectangle', ...
%                 bboxes, labels);
        end
    end

    % Display the mask and the frame.
%     obj.maskPlayer.step(mask);
%     obj.videoPlayer.step(frame);
    paths = cat(1, reliableTracks.paths);
    if (~isempty(paths))
        shapeInserter = vision.ShapeInserter('Shape','Circles');
        %paths = [paths(:,1)' paths(:,2)'];
        paths = int32(paths);
        J = step(shapeInserter, frame, paths);
        imshow(J); 
        drawnow;
     %   im_name = ['D:\repo\Coursework\advanced_computer_vision\project\code\image_sequence\' char(imageName{1,1})];
     %   imwrite(J,im_name);
    else
%         figure(35);
%         imshow(mask);
        figure(36);
        imshow(frame);
   %     im_name = ['D:\repo\Coursework\advanced_computer_vision\project\code\image_sequence\' char(imageName{1,1})];
    %    imwrite(frame,im_name);
        %hold on;
    end
% %   figure(35);
% %   imshow(mask);
%     figure(36);
%     imshow(frame);
%     im_name = ['D:\repo\Coursework\advanced_computer_vision\project\code\image_sequence\' char(imageName{1,1})];
%     imwrite(frame,im_name);
%     %hold on;
end