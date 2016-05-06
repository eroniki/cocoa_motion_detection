function multiObjectTracking(murat_frame,current_frame,M,imageName,img)

    global path_circle_size;
    global obj;
    global tracks;
    global nextId;
    global mean_shift_kf_tag;

    % path_circle_size = 5;
    % obj = setupSystemObjects();
    % 
    % tracks = initializeTracks(); % Create an empty array of tracks.
    % 
    % nextId = 1; % ID of the next track

    % Detect moving objects, and track them across video frames.
    % while ~isDone(obj.reader)
    %frame = readFrame();
    [centroids, bboxes, mask] = detectObjects(murat_frame.maskCumulative);
    predictNewLocationsOfTracks();
    [assignments, unassignedTracks, unassignedDetections] = ...
        detectionToTrackAssignment(centroids,img);

    updateAssignedTracks(centroids,bboxes,assignments);
    updateUnassignedTracks(unassignedTracks);
    deleteLostTracks();
    createNewTracks(centroids,bboxes,unassignedDetections);
    
    % Add Orson's transformation function to transform paths
    for iii=1:length(tracks)
        tracks(iii).paths(:,1:2) = point_warping(M,tracks(iii).paths(:,1:2));
    end

    displayTrackingResults(current_frame,mask,imageName);
end