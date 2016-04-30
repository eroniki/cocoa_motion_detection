function dW_dp = jacobian_a(indx, indy)
% JACOBIAN_A - Compute Jacobian for affine warp
jac_x = indx;
jac_y = indy;
jac_zero = zeros(size(indx));
jac_one = ones(size(indx));
dW_dp.a = [jac_x, jac_zero, jac_y, jac_zero, jac_one, jac_zero;
         jac_zero, jac_x, jac_zero, jac_y, jac_zero, jac_one];
dW_dp.t = [jac_one, jac_zero;
           jac_zero,jac_one];

dW_dp.r = [-jac_y ,jac_one, jac_zero 
            jac_x ,jac_zero,jac_one ];
