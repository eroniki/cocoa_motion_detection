img = reshape(1:20,5,4)';
gs.y=2;
gs.x=2;

thresh=20;

[h,w]=size(img);
pad.y=rem(h,gs.y);
pad.x=rem(w,gs.x);
%pad the matrix with zeros
img(h+1:h+pad.y,:)=0;
img(:,w+1:w+pad.x)=0;
[h,w]=size(img);
quo.y=floor(h/gs.y);
quo.x=floor(w/gs.x);
grid_d.y=gs.y*ones(1,quo.y);
grid_d.x=gs.x*ones(1,quo.x);
C = mat2cell(img, grid_d.y,grid_d.x);
%celldisp(C)
imgsubsum=cellfun(@divider_helper,C);
ind=find(imgsubsum>=thresh);
[I,J] = ind2sub(size(imgsubsum),ind);
mask=zeros(h,w);
for i=1:numel(I)
   ind.y=I(i);
   ind.x=J(i);
   mask(1+((ind.y-1)*gs.y):ind.y*gs.y,1+((ind.x-1)*gs.x):ind.x*gs.x)=1; 
end






