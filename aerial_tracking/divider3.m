function [ mask_updated, ind,killed_his, grid_his] = divider3(img,gs,percent,ind_a,killed_his, ind_init, grid_his)
%The function divides input image into grid and calculate the 
%error sum within grids.
[h,w]=size(img);
pad.y=ceil(h/gs.y);
pad.y=pad.y*gs.y-h;
pad.x=ceil(w/gs.x);
pad.x=pad.x*gs.x-w;
%pad the matrix with zeros
img(h+1:h+pad.y,:)=0;
img(:,w+1:w+pad.x)=0;

[h2,w2]=size(img);
quo.y=floor(h2/gs.y);
quo.x=floor(w2/gs.x);
grid_d.y=gs.y*ones(1,quo.y);
grid_d.x=gs.x*ones(1,quo.x);
C = mat2cell(img, grid_d.y,grid_d.x);
%calculate subsum of grids
imgsubsum=cellfun(@divider_helper,C);

grid_his=[grid_his,imgsubsum(ind_init)];


imgsubsum_s=imgsubsum;
%For better visualization in the future. "mesh" seems necessary 
error_surface=zeros(h2,w2);
X=1:1:w2;

Y=h2:-1:1;
[X,Y]=meshgrid(X,Y);
n=1:numel(imgsubsum);
[I,J] = ind2sub(size(imgsubsum),n);
imgsubsum=imgsubsum(:);

for i=n
   ind.y=I(i);
   ind.x=J(i);
   error_surface(1+((ind.y-1)*gs.y):ind.y*gs.y,1+((ind.x-1)*gs.x):ind.x*gs.x)=imgsubsum(i);  
end
figure(88); clf;
mesh(X,Y,error_surface);
% 
% [~,max_diff]=max(imgsubsum(:,1));


imgsubsum=[imgsubsum,n'];



% for i=1:numel(killed_his)
%     A=find(imgsubsum(:,2)==killed_his(i));
%     imgsubsum(A,:)=[];    
% end


imgsubsum(killed_his,:)=[];




imgsubsum = sortrows(imgsubsum);




ceil(n(end)*(1-(percent/100)))
%removed_grid=imgsubsum(end-ceil(n(end)*(1-(percent/100))):end,2);

%further refine the removed_grid
removed_grid=imgsubsum(end-ceil(n(end)*(1-(percent/100))):end,:);
max_diff=max(removed_grid(:,1));
if max_diff>=10^(-3)


idx=numel(removed_grid)/2; 
removed_grid2=removed_grid;
for i=1:idx
    if removed_grid(i,1)<=(1/4)*max_diff
        removed_grid2(1,:)=[];
    else
        
        break
    end
end
else
    removed_grid2=[];
end

killed = intersect(ind_a,removed_grid2);
C = setdiff(ind_a,removed_grid2);
[I,J] = ind2sub(size(imgsubsum_s),C);
mask_updated=NaN(h2,w2);
for i=1:numel(I)
   ind.y=I(i);
   ind.x=J(i);
   mask_updated(1+((ind.y-1)*gs.y):ind.y*gs.y,1+((ind.x-1)*gs.x):ind.x*gs.x)=1; 
end

%Get rid of the paved pixels
mask_updated(h+1:end,:)=[];
mask_updated(:,w+1:end)=[];
% figure(89); clf;
% imshow(mask_updated);
ind=C;
killed_his=[killed_his;killed];

end