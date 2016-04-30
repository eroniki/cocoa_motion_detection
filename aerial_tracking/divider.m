function [ mask,ind_a,uti] = divider(img,gs,thresh)
%The function divides input image into grid and calculate the 
%gradient sum within the grid.
%Apparently, input variable "img" stands for gradient matrix of image 
%The second part of the function create mask for the input image
[h,w]=size(img);

pad.y=ceil(h/gs.y);
pad.y=pad.y*gs.y-h;
pad.x=ceil(w/gs.x);
pad.x=pad.x*gs.x-w;
%pad the matrix with zeros
img(h+1:h+pad.y,:)=0;
img(:,w+1:w+pad.x)=0;
uti.C=[h,w];
[h2,w2]=size(img);
quo.y=floor(h2/gs.y);
quo.x=floor(w2/gs.x);
grid_d.y=gs.y*ones(1,quo.y);
grid_d.x=gs.x*ones(1,quo.x);
C = mat2cell(img, grid_d.y,grid_d.x);
%celldisp(C)
%calculate subsum of grids
imgsubsum=cellfun(@divider_helper,C);
ind_a=find(imgsubsum>=thresh);
uti.A=size(imgsubsum);
uti.B=[h2,w2];
[I,J] = ind2sub(size(imgsubsum),ind_a);
mask=NaN(h2,w2);
for i=1:numel(I)
   ind.y=I(i);
   ind.x=J(i);
   mask(1+((ind.y-1)*gs.y):ind.y*gs.y,1+((ind.x-1)*gs.x):ind.x*gs.x)=1; 
end
%Get rid of the paved pixels
mask(h+1:end,:)=[];
mask(:,w+1:end)=[];
end

