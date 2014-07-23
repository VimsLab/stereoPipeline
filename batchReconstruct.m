% this script is used to reconstruct a batch of stereo images
% it assumes a left and right directory with watching file names as well as
% a file containing a params struct. 

clear 
clc

leftDir = 'E:\portable3DSystem\pairs\resized\left\'; % left images
rightDir = 'E:\portable3DSystem\pairs\resized\right\'; % right images
paramsLoc = 'E:\portable3DSystem\pairs\resized\OdenPortableParams.mat'; %location of the saved params
modelDir = 'E:\portable3DSystem\pairs\resized\models\';% location to write the ply files

%loading params and getting list of files
load(paramsLoc);
leftFiles = dir(leftDir);
rightFiles = dir(rightDir);
leftFiles(1:2)=[]; % gets rid of . and ..
rightFiles(1:2)=[]; % gets rid of . and ..


if size(leftFiles,1) ~= size(rightFiles,1)
    disp('The number of files in each directory is different');
    break    
end
%the loop to reconstruct the various files
for i =1:size(leftFiles,1)
    fname = leftFiles(i).name %getting the filenam
    imleft = imread([leftDir fname]);%loading left
    imright = imread([rightDir fname]);%loading right
    [pts3d,colors] = computeStereo3D(uint8(imleft), uint8(imright), params); %reconstructing
    newfname = strrep(fname,'.png',''); %new filename
    makePly(pts3d, colors, [modelDir newfname]); %writing out the file
end