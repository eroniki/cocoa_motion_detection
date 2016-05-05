function [ BB_list_sifted,center_list ] = box_center_find( BB_list,gs )
% BB_list-bounding box list. output of the regionprop('boundingbox')
BB_list_sifted=[];
center_list=[];
for k=1:length(BB_list)
oneBB=BB_list(k).BoundingBox;
    if oneBB(3)>gs.x || oneBB(4)>gs.y 
       if oneBB(3)<=5*gs.x && oneBB(4)<=5*gs.y
       BB_list_sifted=[BB_list_sifted;oneBB];
       center_list=[center_list;[oneBB(1)+oneBB(3)/2,oneBB(2)+oneBB(4)/2]];
       end
    end
end
end

