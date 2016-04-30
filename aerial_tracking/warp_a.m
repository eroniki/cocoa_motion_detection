function [wimg, flag] = warp_a(img, p, X, Y)
% WARP_A - Affine warp the image

if nargin<4 error('Not enough input arguments'); end

% Convert affine warp parameters into 3 x 3 warp matrix
% NB affine parameterised as [1 + p1, p3, p5; p2, 1 + p4, p6]

M = [ 1+p(1) p(3) p(5); p(2) 1+p(4) p(6); 0 0 1];
 
% M = [p; 0 0 1];
% M(1,1) = M(1,1) + 1;
% M(2,2) = M(2,2) + 1;

% Use bilinear filtering to warp image back to template
[wimg,flag]= quadtobox(img, M, X, Y, 'bilinear');
