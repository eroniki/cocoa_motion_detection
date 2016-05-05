function [uti] = initilizer(fov_size,gs)
h=fov_size(1);
w=fov_size(2);
uti.imsize_before_pad=[h,w];
uti.pad_y=ceil(h/gs.y);
uti.pad_y=uti.pad_y*gs.y-h;
uti.pad_x=ceil(w/gs.x);
uti.pad_x=uti.pad_x*gs.x-w;

%pad the matrix with zeros
h2=h+uti.pad_y;
w2=w+uti.pad_x;
uti.imsize_after_pad=[h2,w2];
quo.y=floor(h2/gs.y);
quo.x=floor(w2/gs.x);
uti.grid_matrix_size=[quo.y,quo.x];


grid_d.y=gs.y*ones(1,quo.y);
grid_d.x=gs.x*ones(1,quo.x);

uti.mat2cell_y=grid_d.y;
uti.mat2cell_x=grid_d.x;

end