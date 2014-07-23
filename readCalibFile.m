%this function parses a calibration file outputted from callab/calde
function [ calib_params ] = readCalibFile( filename )
fid = fopen(filename);
tline = fgetl(fid);

while(ischar(tline))
    try
    eval(tline);
    catch e
        disp(e.message);
        disp(tline);
    end
    tline = fgetl(fid);
end
fclose(fid);

calib_params.T = T;
calib_params.R = R;
calib_params.left = left;
calib_params.right = right;

end

