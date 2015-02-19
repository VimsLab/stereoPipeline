%%%%This script reconstructs a 3D point cloud given 2 stereo images
%%%%and then writes the result to a ply file

close all; clear all; clc;

I1 = imread('./test_images/5003/000000008.pgm');
I2 = imread('./test_images/5270/000000008.pgm');
disparityRange = [-164 -100];
load('test_stereo_params/infraredStereoParams.mat'); %obtained from Matlab2014b stereoCameraCalibrator
min_thresh = 1000; %mm, closest 3D point to allow
max_thresh = 3000; %mm, furthest 3D point to allow
[pointCloud, colors, J1, J2] = stereoToCloud(I1, I2, disparityRange, stereoParams, ...
    min_thresh, max_thresh);

%write the pointcloud to a ply file
makePly( pointCloud, colors, './test_results/test_infrared3d');


