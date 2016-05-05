function [ mask_updated, ind,killed_his, grid_his] = divider2(img,gs,percent,ind_a,killed_his, ind_init, grid_his,uti)
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
%record grid history
grid_his=[grid_his,imgsubsum(ind_init)];

subsum_size=size(imgsubsum);
n=1:numel(imgsubsum);
imgsubsum=imgsubsum(:);
imgsubsum=[imgsubsum,n'];
%prevent the function from deleting sames grid over and over again
imgsubsum(killed_his,:)=[];
imgsubsum = sortrows(imgsubsum);

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
[I,J] = ind2sub(subsum_size,C);
mask_updated=NaN(h2,w2);
for i=1:numel(I)
   ind.y=I(i);
   ind.x=J(i);
   mask_updated(1+((ind.y-1)*gs.y):ind.y*gs.y,1+((ind.x-1)*gs.x):ind.x*gs.x)=1; 
end

%Get rid of the paved pixels
mask_updated(h+1:end,:)=[];
mask_updated(:,w+1:end)=[];
% record the surviving grid
ind=C;
killed_his=[killed_his;killed];
end