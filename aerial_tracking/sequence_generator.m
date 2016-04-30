
%This script generates a block movement sequence for tracking algorithm
%testing

savedir='/Users/Orson Lin/Desktop/AC_project/simpse2';

width=30;
top_corner=[-1*width/2,-1*width/2];
sequence_number=60;
canvas_size=[300,500];

rotation_center=[250,250,250,250;150,150,150,150];
rotation_interval=2*pi/1440;
%rotation_interval=0;
translation_per_frame=[5,0];

X=[top_corner(1),top_corner(1),top_corner(1)+width,top_corner(1)+width];
Y=[top_corner(2),top_corner(2)+width,top_corner(2)+width,top_corner(2)];
%canvas = zeros(300,500);
canvas=zeros(canvas_size(1),canvas_size(2),3);
canvas(:,:,1)=255;

BW = roipoly(canvas(:,:,1),X+rotation_center(1,:),Y+rotation_center(2,:));
canvas(:,:,1)=canvas(:,:,1).*BW;

%draw background 
bg_width=70;
canvas(1:bg_width,:,:)=255;
canvas(canvas_size(1)-bg_width:end,:,:)=255;
canvas(:,1:50,:)=255;
canvas(:,1:50,:)=255;
canvas(1:100,1:100,:)=255;
% canvas(end-100:end,end-100:end,:)=255;
% figure();
% imshow(canvas);


imname= [savedir '/' sprintf('frame%d.jpg',1000+1)]; 
imwrite(canvas,imname);
BW=false(canvas_size(1),canvas_size(2));
canvas(:,:,1)=255;

for i=1:sequence_number
%warping    
warp_mat=[cos(i*rotation_interval),-1*sin(i*rotation_interval);sin(i*rotation_interval),cos(i*rotation_interval)];
old_cordi=[X;Y];
new_cordi=warp_mat*old_cordi;
new_cordi=new_cordi+rotation_center;
X=new_cordi(1,:);%+translation_per_frame(1);
Y=new_cordi(2,:);%+translation_per_frame(2);
%ROI function testing
%BW = roipoly(canvas,X,Y);
BW = roipoly(canvas(:,:,1),X,Y);
canvas(:,:,1)=canvas(:,:,1).*BW;

canvas(1:bg_width,:,:)=255;
canvas(canvas_size(1)-bg_width:end,:,:)=255;
canvas(:,1:50,:)=255;
canvas(1:100,1:100,:)=255;
% canvas(end-100:end,end-100:end,:)=255;
%% visualization
% hold off;
figure(8);
imshow(canvas);
% hold on;
% fill(X,Y,'r'); 
% title(sprintf('frame%d',i));
% drawnow;
%% Save the image
imname= [savedir '/' sprintf('frame%d.jpg',1000+i+1)]; 
imwrite(canvas,imname);

X=X-rotation_center(1,:);
Y=Y-rotation_center(2,:);
BW=false(canvas_size(1),canvas_size(2));
canvas(:,:,1)=255;
rotation_center(1,:)=rotation_center(1,:)+translation_per_frame(1);
rotation_center(2,:)=rotation_center(2,:)+translation_per_frame(2);
end