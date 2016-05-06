function [ st, M, warped_current ] = motion_compensation(current_frame, previous_frame, params)
 %% build a mask defining tparams.he extent of tparams.he template

 mask    = NaN([params.h, params.w]);
 mask_in_loop  = NaN([params.h, params.w]);
 mo_mask   = NaN([params.h, params.w]);
 %  selected area is decided by margin
 
 %% divider comes into play.
 select_A= previous_frame(params.fov_vec.y,params.fov_vec.x);
 [Gx,Gy]=gradient(select_A);
 select_A_grad=sqrt(Gx.^2+Gy.^2);
 % Sift out tparams.he grid tparams.hat contain "gradient" information
 [sub_mask, ind]= divider(select_A_grad,params.gs,params.thresh,params.uti);
 % index tparams.hat pass tparams.he "gradient test"
 ind_init=ind;
 % initial mask
 mask(params.fov_vec.y, params.fov_vec.x)= sub_mask;
 killed_his=[];
 %visualization;
 % set up KLT parameters
 p=[0,0,0,0,0,0];
 % record tparams.he grids' cparams.hange of difference params.history
 grid_his=[];
 %% KLT
 mask_converted2  = mask_converter(mask);
 for i2=1:params.grid_sifting_time
     % Get tparams.he inital guess from KLT. If sensor data is available,
     % tparams.his part can be a lot faster.
     tic;
     [affineLKContext, roparams.w, col, value]=InitAffineLKTracker(previous_frame, mask);
     p=KLT_tracking(current_frame,value,roparams.w,col,affineLKContext,p,0,20);
     ftime = toc;
     %% calculate tparams.he covariance of eacparams.h grid
     M = [ 1+p(1) p(3) p(5); p(2) 1+p(4) p(6); 0 0 1];
     % params.warp tparams.he image params.witparams.h current estimated Affine parameters
     warped_current = warp_a_v(current_frame, p, params.dst);
     error_square=(current_frame(params.fov_vec.y, params.fov_vec.x)-warped_current(params.fov_vec.y,params.fov_vec.x)).^2;
     [mask_updated,ind_updated,killed_his,grid_his]=divider2(error_square,params.gs,params.percent,ind,killed_his, ind_init,grid_his,params.uti);
     mask_in_loop(params.fov_vec.y,params.fov_vec.x)= mask_updated;
     %% mask update
     mask=mask_in_loop;
     ind=ind_updated;
     %%v
     %visualization2;
 end
[mask_constructed] = mask_constructor(killed_his,params.uti,params.gs);
mo_mask(params.fov_vec.y, params.fov_vec.x)=mask_constructed;
%%
figure(92);
imshow(mo_mask.*current_frame); hold on;
mo_mask(isnan(mo_mask))=0;
st = regionprops(logical(mo_mask), 'BoundingBox' );
[ BB_list_sifted,center_list ] = box_center_find( st,params.gs );     
[hbb,~]=size(BB_list_sifted);
for k=1:hbb
 thisBB=BB_list_sifted(k,:);
 rectangle('Position', [ thisBB(1), thisBB(2), thisBB(3), thisBB(4)],...
        'EdgeColor','b','Linewidth',2 );
 drawnow; 
end
end

