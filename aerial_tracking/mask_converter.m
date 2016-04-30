function [ mask_converted ] = mask_converter(mask)
idx = find(isnan(mask));
if ~isempty(idx)
  	mask(idx) = 0;
end
mask_converted=mask;
end

