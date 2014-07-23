%this function computes a point cloud from a set of stereo images. this is
%done using the algorithm laid out in Hartley and Zisserman's "Multiple
%view Geometry". The process requires both calibration and rectification
%parameters. Rectification parameters are obtained by the function calculateRectParams.
%calibration parameters must be computed beforehand. The function takes
%img1 and img2, the input images, and params, a struct containing
%calibration and rectification parameters the structure of this is
%explained in the readme.

function [pts3d,colors] = computeStereo3D(img1, img2, params)
%img1 is unrectified left image as double
%img2 is unrectified right image as double
%params is a struct with calibration params and rectification params
%pts3d is a 3 by N vector of points
%colors is a 3 by N vector of corresponding rgb values for the 3d points

img1c = img1;
img1 = rgb2gray(img1);
img2 = rgb2gray(img2);
height = size(img1c,1);
width = size(img1c,2);

tform1 = params.rect_params.tform1;
tform2 = params.rect_params.tform2;
tref1 = params.rect_params.tref1;
tref2 = params.rect_params.tref2;
outputView = params.rect_params.outputView;
T = params.calib_params.T;
R = params.calib_params.R;
left = params.calib_params.left;
right = params.calib_params.right;
widthL = size(img1, 2);
heightL = size(img1, 1);
widthR = size(img2, 2);
heightR = size(img2, 1);

I1 = imwarp(img1, tform1, 'OutputView', outputView);
I2 = imwarp(img2, tform2, 'OutputView', outputView);

%the disparity range (for semiglobal this range must be divisible by 16
dispRange = [-14,18];

%d = disparity(I1, I2, 'DisparityRange', [-32 32], 'UniquenessThreshold', 15);
d = disparity(I1, I2, 'DisparityRange', dispRange,'UniquenessThreshold', 3);

%masking off region without overlap
premask = ones(size(img1));
warpedMask = imwarp(premask,tform1,'OutputView', outputView);
d = maskDisparity(d,warpedMask);


marker_idx = (d == -realmax('single'));


[r, c] = find(d ~= -realmax('single'));
ind = sub2ind(size(d), r, c);
v = d(ind);
d(marker_idx) = min(d(~marker_idx));

extendedDisp = dispRange + [-10 10]; %helps visualization
figure;
imshow(d, extendedDisp);
title(['disparity range ' num2str(dispRange)]);
colorbar;
pause(.5); %this helps ensure the figure displays before starting up the threadpool

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%uncomment this line if you are testing the disparity and do not wish to
%proceed with unrectification and triangulation
%return

xyLr = [c r ];
xyRr = [c-v r];

%unrectify points
[xWorldL,yWorldL] = intrinsicToWorld(tref1,xyLr(:,1),xyLr(:,2));
[xyLu, xyLv] = transformPointsInverse(tform1,xWorldL,yWorldL);
[xWorldR,yWorldR] = intrinsicToWorld(tref2,xyRr(:,1),xyRr(:,2));
[xyRu, xyRv] = transformPointsInverse(tform2,xWorldR,yWorldR);
xyL = [xyLu xyLv];
xyR = [xyRu xyRv];

numPts = length(xyL);
pts3d = zeros(numPts, 3);
colors = zeros(numPts, 3);


%uncomment this to see matches from disparity
%figure;
%showMatchedFeatures(img1, img2,xyL(1:30000:end, :),xyR(1:30000:end, :), 'montage');

disp(numPts);
%if you are using a single core machine or are otherwise unable to use the
%parallel programming toolbox switch the parfor to regular for
parfor i=1:numPts
    %if(mod(i-1, 10000) == 0)
    %   disp(i);
    %end
    L_x = xyL(i,1);
    L_y = xyL(i,2);
    R_x = xyR(i,1);
    R_y = xyR(i,2);
    
    uL = undistort([L_x L_y]' ,left.A,left.k1,left.k2);
    uR = undistort([R_x R_y]' ,right.A,right.k1,right.k2);
    
    
    p1=triangulate(uL, uR,left.A,right.A,[R' T']);
    if p1(4) ~= 0; %
        pts3d(i,:)=p1(1:3)'./p1(4);
    else
        pts3d(i,:)= p1(1:3);
    end
    
    x = round(xyL(i,1)); x = max(1, min(x, width));
    y = round(xyL(i,2)); y = max(1, min(y, height));
    r = img1c(y, x, 1);
    g = img1c(y, x, 2);
    b = img1c(y, x, 3);
    colors(i,:) = [r g b];
end
ind = any(pts3d,2);
colors = colors(ind,:);
pts3d = pts3d(ind,:);

end


