%Show image pair
figure(1)
subplot(1,2,2)
imshow(current_frame);
title('current frame');
subplot(1,2,1)
imshow(previous_frame);
title('previous frame');


% mask visualization
figure(67);

imshow(mask.*current_frame);