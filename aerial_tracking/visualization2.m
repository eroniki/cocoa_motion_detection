%% mask visualization
figure(90);
imshow(mask_in_loop.*current_frame);
%imshow(mask_in_loop);
title('Current Mask');
mask_converted1  = mask_converter(mask_in_loop);
mask_converted2=mask_converted1+mask_converted2;
figure(85);
imagesc(mask_converted2);
title('Mask update history');

            %% Visualization of grid refinement 
            currentBox = M * [templateBox; ones(1,5)];
            currentBox = currentBox(1:2,:);
            overlap=warped_current*.5+previous_frame*.5;
            hold off;
            figure(99);
            imagesc(overlap);
            hold on;
            plot(currentBox(1,:), currentBox(2,:), 'g', 'linewidth', 2);
            drawnow;