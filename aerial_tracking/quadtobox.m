function [wimg, flag] = quadtobox(img, M, X, Y, f_type)

if nargin<4 f_type = 'bilinear'; end

% Get all points in destination to sample
xy=[X';Y';ones(size(X'))]; 
% Transform into source
uv = M * xy;
% Remove homogeneous
uv = uv(1:2,:)';
xi = reshape(uv(:,1),numel(uv(:,1)),1);  % can be optimized
yi = reshape(uv(:,2),numel(uv(:,2)),1);
wimg = interp2(img, xi, yi, f_type);

% Check for NaN background pixels - replace them with a background of 0
idx = find(isnan(wimg));

% if numel(idx)/numel(wimg)>=10/45*1.5
% 
%     flag=0;
%     return 
% end
%     
flag=1;
if ~isempty(idx)
  	wimg(idx) = 0;
    fprintf('oops');
end
