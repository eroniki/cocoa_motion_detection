 function [assignments, unassignedTracks, unassignedDetections] = ...
        detectionToTrackAssignment(centroids,img)
    
    global tracks;
    global mean_shift_kf_tag;

    nTracks = length(tracks);
    nDetections = size(centroids, 1);

    % Compute the cost of assigning each detection to each track.
    cost = zeros(nTracks, nDetections);
    if strcmp(mean_shift_kf_tag,'kf')
        for i = 1:nTracks
            cost(i, :) = distance(tracks(i).kalmanFilter, centroids);
        end
    end
    [hueChannel,~,~] = rgb2hsv(img);
    %% mean shift pseudo code
    if (strcmp(mean_shift_kf_tag,'mean_shift') && nTracks ~= 0 && nDetections ~= 0)
        tracker = vision.HistogramBasedTracker;
        for i = nTracks
           for j = nDetections
               if (tracks(i).bbox(1) <= 0)
                  tracks(i).bbox(1) = 1; 
               end
               if (tracks(i).bbox(2) <= 0)
                  tracks(i).bbox(2) = 1; 
               end
               initializeObject(tracker,hueChannel,uint8(tracks(i).bbox(1,:)));
               [bbox_returned,~,score] = step(tracker,hueChannel);
               bbox_returned = [bbox_returned(1)+(round(bbox_returned(3)/2)) bbox_returned(2)+(round(bbox_returned(4)/2))]; 
               cost(i,j) = (1-score)*distance(centroids(j,:),bbox_returned);
        %       WE CAN SWAP THE DETECTION BBOX FOR THE MEAN SHIFT BBOX IF WE WANT
        %       STILL NEED TO GRAB DETECTIONS(J).BBOX AND CENTERS OF BBOXES
        %       FOR DISTANCE FUNCTION
           end
        end
    end
    % Solve the assignment problem.
    costOfNonAssignment = 10;
    [assignments, unassignedTracks, unassignedDetections] = ...
        assignDetectionsToTracks(cost, costOfNonAssignment);
end