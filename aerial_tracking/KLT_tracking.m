function [ pout ] = KLT_tracking(current_frame,value,Y,X,context,pin,other,affine)
OtherIterations=other;
AffineIterations=affine;
pout=pin;
for i=1:OtherIterations+AffineIterations;
%while norm(delta_p)>threshold && iter<n
%% calculate the error image
[wimg,flag]= warp_a(current_frame, pout,X,Y);
if flag==0;
    pout=pin;                             %% might not be ideal
    break
end
% a_I=sum(wimg(:))/numel(wimg);
%wimg=wimg/(a_I/context.average_illumination);
error_img=wimg-value;
if i>OtherIterations   
%Affine Estimation    
%% step7 in LK_20
sd_delta_p =context.Jacobian.a'*error_img;
%% step8 in LK_20
delta_p=context.Inverse_Hessian.a*sd_delta_p;
%% step9 in LK_20
pout = update_step(pout, delta_p);
else
%Translation Estimation  
%% step7 in LK_20
sd_delta_p =context.Jacobian.r'*error_img;
%% step8 in LK_20
delta_p=context.Inverse_Hessian.r*sd_delta_p;
%% step9 in LK_20
pout = update_step(pout, delta_p);        
end
end
% disimilarity=sum(sum((error_img).^2))
 norm_delta_p=norm(delta_p);
end

function warp_p = update_step(p, delta_p)
% Compute and apply the update
% Convert affine notation into usual Matrix form - NB transposed

if numel(delta_p)==6
delta_M = [ 1+delta_p(1) delta_p(3) delta_p(5); delta_p(2) 1+delta_p(4) delta_p(6); 0 0 1];
elseif numel(delta_p)==2
delta_M = [ 1 0 delta_p(1); 0 1 delta_p(2); 0 0 1];
elseif numel(delta_p)==3
co_p=cos(delta_p(1));
si_p=sin(delta_p(1));
delta_M = [co_p,-si_p,delta_p(2);si_p,co_p,delta_p(3); 0 0 1];	
end
% Invert compositional warp
delta_M = inv(delta_M);

% Current warp
warp_M = [ 1+p(1) p(3) p(5); p(2) 1+p(4) p(6); 0 0 1];
% Compose
comp_M = warp_M * delta_M;	
warp_p = comp_M(1:2,:);
warp_p(1,1) = warp_p(1,1) - 1;
warp_p(2,2) = warp_p(2,2) - 1;

end

