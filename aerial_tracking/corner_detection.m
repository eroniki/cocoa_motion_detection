function [ C ] = corner_detection(img,method,corner_num)
%detect amd draw corners
C = corner(img,method,corner_num);%,'QualityLevel'),0.1);
% figure;
% imshow(img);
% hold on
% plot(C(:,1), C(:,2), 'r*');
end

