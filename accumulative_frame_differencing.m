function accumulativeDifference = accumulative_frame_differencing(frameSequence, p)
% TODO: Add explicit explanations here
frameNumber = numel(frameSequence);
accumulativeDifference = struct([]);
for i=1:frameNumber
    accumulativeDifference(i).image = zeros(size(frameSequence(i).image_gray));
    accumulativeDifference(i).histogram = zeros(1,256);
    if(i<p || i>(frameNumber-p))
        continue;
    else
        sumFrame = zeros(size(frameSequence(i).image_gray));
        for counter=-p+1:p
            diff = abs(frameSequence(i).image_gray - frameSequence(i+counter).image_gray);
%             imshow(diff);
            sumFrame = sumFrame + im2double(diff);
        end
        accumulativeDifference(i).image = log(sumFrame);
        accumulativeDifference(i).histogram = imhist(sumFrame);
        figure(1); imshow(accumulativeDifference(i).image); title(['frame= ', num2str(i)]);
        [counts, x] = imhist(accumulativeDifference(i).image);
        figure(2); semilogy(x,counts);
        figure(3); imhist(accumulativeDifference(i).image);
    end
end
end
