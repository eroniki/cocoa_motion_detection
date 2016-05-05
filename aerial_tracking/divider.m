function [ mask,ind_a] = divider(img,gs,thresh,uti)
h=uti.imsize_before_pad(1);
w=uti.imsize_before_pad(2);
%pad the matrix with zeros
img(h+1:h+uti.pad_y,:)=0;
img(:,w+1:w+uti.pad_x)=0;
h2=uti.imsize_after_pad(1);
w2=uti.imsize_after_pad(2);

quo.y=floor(h2/gs.y);
quo.x=floor(w2/gs.x);
C = mat2cell(img, uti.mat2cell_y,uti.mat2cell_x);
%calculate subsum of grids
imgsubsum=cellfun(@divider_helper,C);
ind_a=find(imgsubsum>=thresh);
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

