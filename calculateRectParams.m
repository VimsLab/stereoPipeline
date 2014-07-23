%this function is used to create a rectification parameters object. it uses
%surf features to calculate a rectifying homography. this approaches is
%uncalibrated and requires a fair amount of texture. I1 and I2 are the
%stereo pair to use. 
function [rect_params] = calculateRectParams(im1, im2 )

if size(im1,3) == 3;
    I1 = rgb2gray(im1);
else
    I1 = im1;
end
if size(im2,3) == 3
    I2 = rgb2gray(im2);
else
    I2 = im2;
end


%detect feature points
blobs1 = detectSURFFeatures(I1, 'MetricThreshold', 2000);
blobs2 = detectSURFFeatures(I2, 'MetricThreshold', 2000);
%extract features
[features1, validBlobs1] = extractFeatures(I1, blobs1);
[features2, validBlobs2] = extractFeatures(I2, blobs2);
%match features using SAD
indexPairs = matchFeatures(features1, features2, 'Metric', 'SAD', ...
    'MatchThreshold', 100);
%extract matched points
matchedPoints1 = validBlobs1.Location(indexPairs(:,1),:);
matchedPoints2 = validBlobs2.Location(indexPairs(:,2),:);
%remove outliers using geometric constraint
gte = vision.GeometricTransformEstimator('PixelDistanceThreshold', 50);
[~, geometricInliers] = step(gte, matchedPoints1, matchedPoints2);
refinedPoints1 = matchedPoints1(geometricInliers, :);
refinedPoints2 = matchedPoints2(geometricInliers, :);
%remove outliers using epipolar constraint
[fMatrix, epipolarInliers, status] = estimateFundamentalMatrix(...
    refinedPoints1, refinedPoints2, 'Method', 'RANSAC', ...
    'NumTrials', 10000, 'DistanceThreshold', 0.1, 'Confidence', 99.99);
if status ~= 0 || isEpipoleInImage(fMatrix, size(I1)) ...
        || isEpipoleInImage(fMatrix', size(I2))
    error(['For the rectification to succeed, the images must have enough '...
        'corresponding points and the epipoles must be outside the images.']);
end
inlierPoints1 = refinedPoints1(epipolarInliers, :);
inlierPoints2 = refinedPoints2(epipolarInliers, :);
%calculate the rectification
[t1, t2] = estimateUncalibratedRectification(fMatrix, ...
    inlierPoints1, inlierPoints2, size(I2));
tform1 = projective2d(t1);
tform2 = projective2d(t2);
% Compute the transformed location of image corners.
numRows = size(I1, 1);
numCols = size(I1, 2);
inPts = [1, 1; 1, numRows; numCols, numRows; numCols, 1];
outPts(1:4,1:2) = transformPointsForward(tform1, inPts);
numRows = size(I2, 1);
numCols = size(I2, 2);
inPts = [1, 1; 1, numRows; numCols, numRows; numCols, 1];
outPts(5:8,1:2) = transformPointsForward(tform2, inPts);
%--------------------------------------------------------------------------
% Compute the common rectangular area of the transformed images.
xSort   = sort(outPts(:,1));
ySort   = sort(outPts(:,2));
xLim(1) = ceil(xSort(1)) - 0.5;
xLim(2) = floor(xSort(end)) + 0.5;
yLim(1) = ceil(ySort(1)) - 0.5;
yLim(2) = floor(ySort(end)) + 0.5;
width   = round(xLim(2) - xLim(1) - 1);
height  = round(yLim(2) - yLim(1) - 1);
outputView = imref2d([height, width], xLim, yLim);
im1ref = imref2d(size(I1));
im2ref = imref2d(size(I2));

%--------------------------------------------------------------------------
% Generate a composite made by the common rectangular area of the
% transformed images.
[imageTransformed1, tref1] = imwarp(I1, im1ref, tform1, 'OutputView', outputView);
[imageTransformed2, tref2] = imwarp(I2, im2ref, tform2, 'OutputView', outputView);
Irectified = [];
Irectified(:,:,1) = uint8(imageTransformed1);
Irectified(:,:,2) = uint8(imageTransformed2);
Irectified(:,:,3) = uint8(imageTransformed2);
size(Irectified)
figure, imshow(uint8(Irectified));
title('Rectified Stereo Images (Red - Left Image, Cyan - Right Image)');

rect_params.tform1 = tform1;
rect_params.tform2 = tform2;
rect_params.outputView = outputView;
rect_params.tref1 = tref1;
rect_params.tref2 = tref2;

end

