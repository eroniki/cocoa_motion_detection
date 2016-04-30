function [affineLKContext, row, col, value] = InitAffineLKTracker(template,mask)
[Gx,Gy]=gradient(template);
[row,col]=find(~isnan(mask.*template)); %rol and col are both vectors
k=find(~isnan(mask.*template));           %can be optimized.
% [I,J]=ind2sub(size(template),k);
value=template(k);
a_I=sum(value(:))/numel(value);
[h,w]=size(k);
Gx=Gx(k);
Gy=Gy(k);

dW_dp=jacobian_a(col,row);
VT_dW_dp.a=sd_images(dW_dp.a,Gx,Gy,6,h,w);
VT_dW_dp.r=sd_images(dW_dp.r,Gx,Gy,3,h,w);
VT_dW_dp.t=sd_images(dW_dp.t,Gx,Gy,2,h,w);

H.a=VT_dW_dp.a'*VT_dW_dp.a;
H_inv.a=inv(H.a);
H.r=VT_dW_dp.r'*VT_dW_dp.r;
H_inv.r=inv(H.r);

H.t=VT_dW_dp.t'*VT_dW_dp.t;
H_inv.t=inv(H.t);

field1='Jacobian'; value1=VT_dW_dp;
field2='Inverse_Hessian';value2=H_inv;
field3='average_illumination';value3=a_I;
affineLKContext=struct(field1,value1,field2,value2,field3,value3);
end

