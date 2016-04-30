img=zeros(250,250);
img(100:150,100:150)=1;
figure(1)
imshow(img);

%set parameters 
gs.x=16;
gs.y=16;
thresh=3;
[Gx,Gy]=gradient(img);
img_grad=sqrt(Gx.^2+Gy.^2);
figure(2)
imshow(img_grad);
[ mask ] = divider(img_grad,gs,thresh);

figure(3);
imshow(mask);