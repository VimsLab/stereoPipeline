%This is a script to run the entire stereo pipeline, it is broken into
%cells so that you may 

%start with blank slate
close all; clear all; clc;

% this reads in the images, and calibration file. This version of pipeline
% expects the calibration file as output from callab (format hh)
file1 = 'E:\portable3DSystem\pairs\resized\left\0001.png';
file2 = 'E:\portable3DSystem\pairs\resized\right\0001.png';
cal_file = 'E:\portable3DSystem\calibration\resized\camera_calibration_callab_hh.par';

tic %start timing
%read in the images
I1 = uint8(rgb2gray(imread(file1)));
I2 = uint8(rgb2gray(imread(file2)));
I1_c = uint8(imread(file1));
I2_c = uint8(imread(file2));
I1_uc = I1_c;
I2_uc = I2_c;

%parse calibration file
calib_params =  readCalibFile( cal_file );

%you may also load parameters from a .mat file like so:
%load('C:\Users\Scott\Documents\MATLAB\stereoPipeline\data\OdenPortableParams');


%%

%%%%%%%%%%%%Rectification -- Only Do this Once!%%%%%%%%%%%%%%%%%%
rect_params = calculateRectParams(I1, I2);


params.calib_params = calib_params;
params.rect_params = rect_params; 
save('E:\PSITRES\testingsubsets\3Dtests\oden\stereoParams.mat', 'params');

%%%%%%%%%%

%%
%if needed reload the parameters
%load('./data/params_for_stereo.mat');

[pts3d colors] = computeStereo3D(I1_uc, I2_uc, params);
toc %end timing display results

%%
%write the pointcloud to a ply file
makePly( pts3d, colors, 'E:\portable3DSystem\pairs\resized\models\00000');


