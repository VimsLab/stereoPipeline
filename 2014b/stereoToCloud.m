function [pointCloud, colors, J1_color, J2_color] = stereoToCloud(I1, I2, disparityRange, stereoParams, ...
    min_thresh, max_thresh)
%%%%%I1, I2 is image, can be uint8, uint16, color, or grayscale
%%%%%disparityRange = [min, max]
%%%%%stereoParams are output from matlab stereoCameraCalibration 
%%%%min/max_thresh is max distance threshold of point cloud in mm
%%%%%Outputs: pointCloud nx3, colors nx3, J1_color/J2_color are rectified
%%%%%image pairs corresponding to I1/I2


%%%%%Rectify
[J1, J2] = rectifyStereoImages(I1, I2, stereoParams);

%%%%Save color in temp variable, turn to grayscale (matlab requires
%%%%grayscale for disparity functions)
J1_color = J1;
J2_color = J2;
if(size(J1,3) == 3)
    J1 = rgb2gray(J1);
    J2 = rgb2gray(J2);
end

%Calculate disparity map
disparityMap = disparity(J1, J2, 'BlockSize', 7, 'DisparityRange', disparityRange, 'Method','SemiGlobal');

%Calculate point cloud 
pointCloud = reconstructScene(disparityMap, stereoParams);

%Reshape to nx3
pointCloudReformat = reshape(pointCloud, [size(pointCloud,1)*size(pointCloud,2), 3]);

%%%%Colorize point cloud using left image pixels
if(isa(J1_color,'uint16'))
   J1_color = uint8(J1_color./256); 
end
if(size(J1_color,3) == 1)
   colors = [J1_color(:), J1_color(:), J1_color(:)];
end
if(size(J1_color,3) == 3)
    J1_1 = J1_color(:,:,1);
    J1_2 = J1_color(:,:,2);
    J1_3 = J1_color(:,:,3);
    colors = [J1_1(:) J1_2(:) J1_3(:)];
end

%Remove NaN points and points beyond distance thresh
bad_inds = (any(isnan(pointCloudReformat),2) | pointCloudReformat(:,3) >  max_thresh | ...
            pointCloudReformat(:,3) <  min_thresh);
bad_inds = find(bad_inds);
colors(bad_inds, :) = [];
pointCloudReformat(bad_inds, :) = [];
pointCloudReformat = pointCloudReformat./1000; %%%Output in meters, for meshlab
pointCloud = pointCloudReformat;

end