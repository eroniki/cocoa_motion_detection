function accumulativeDifference = accumulative_frame_differencing(frameSequence, p)
% TODO: Add explicit explanations here
frameNumber = numel(frameSequence);

for i=1:frameNumber
    if(i<p || i>frameNumber-p)
        accumulativeDifference(i).image = zeros(size(frameSequence(i).image));
        continue;
    else
        sum = zeros(size(frameSequence(i).image));
        for counter=-p:p
            sum = sum + double(frameSequence(i+p).image);
        end
        accumulativeFrameDifference(i).image = uint8(sum);
    end
end


end

