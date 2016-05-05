function [mask_constructed] = mask_constructor(ind_in,uti,gs)

[I,J] = ind2sub(uti.grid_matrix_size,ind_in);
mask_constructed=NaN(uti.imsize_after_pad(1),uti.imsize_after_pad(2));
for i=1:numel(I)
   ind.y=I(i);
   ind.x=J(i);
   mask_constructed(1+((ind.y-1)*gs.y):ind.y*gs.y,1+((ind.x-1)*gs.x):ind.x*gs.x)=1; 
end
%Get rid of the paved pixels
mask_constructed(uti.imsize_before_pad(1)+1:end,:)=[];
mask_constructed(:,uti.imsize_before_pad(2)+1:end)=[];
end

