
%this is a helper function used to mask out just the region with the
%disparity
%by default the values outside of the mask will be -realmax('single')
function [maskedDisp] = maskDisparity(disparity, mask)
maskedDisp = ones(size(disparity))*-realmax('single');  
maskIdx = find(mask);
maskedDisp(maskIdx) = disparity(maskIdx);
end