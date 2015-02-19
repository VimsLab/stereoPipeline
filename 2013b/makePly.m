%This function will write a ply file for use with other programs such as meshlab
% given a list of 3d points and their corresponding colors
function [] = makePly( worldPoints, colors, name)
%worldPoints = nx3 matrix
%colors = n x3 matrix

fid=fopen([name '.ply'], 'w');
sz = size(worldPoints, 1);
fprintf(fid, 'ply\n');
fprintf(fid, 'format ascii 1.0\n');
fprintf(fid, 'element vertex %d\n', sz);
fprintf(fid, 'property float32 x\nproperty float32 y\nproperty float32 z\n');
fprintf(fid, 'property uchar red\nproperty uchar green\nproperty uchar blue\n');
fprintf(fid, 'element face 0\n');
fprintf(fid, 'end_header\n');
disp('Writing out Ply');
disp(sz);
for i=1:sz
    if(mod(i, 10000) == 0)
        %disp(i);
    end
    x = worldPoints(i,1);
    y = worldPoints(i,2);
    z = worldPoints(i,3);
    r = colors(i, 1);
    g = colors(i, 2);
    b = colors(i, 3);
    if(~isnan(x) && ~isnan(y) && ~isnan(z))
        fprintf(fid, '%f %f %f %d %d %d\n', x, y, z, r, g, b);
    end
end
fclose(fid);


end

