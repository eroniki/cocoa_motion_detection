function [img_pyramid] = pyramidBuilder(img,nL)
%Build image pyramid
%input
%img-imput image
%nL-number of pyramid layer
%output
%img_pyramid-a cell that contains all the layers of the pyramid
img_pyramid=cell(nL+1,1);
img_pyramid{nL+1}=img;

%% visualization
figure(1);
subplot(1,nL+1,1);
imagesc(img);
title('layer0')
%% 
for i=1:nL
subsampled=impyramid(img,'reduce');
img=subsampled;
%store each layer into the cell
img_pyramid{nL-i+1}=img;
% %visualization
subplot(1,nL+1,i+1);
imagesc(img);
title(sprintf('layer%d',i));
end
end




