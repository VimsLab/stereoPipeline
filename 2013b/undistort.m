%This function is used to correct for radial distortion in the images

function undistorted = undistort(distorted,A,k1,k2)

% starting out, we temporarily suppose the original distorted image
% points as undistorted, distort them and compute the residuals,
% which shall be subtracted from the temporal undistorted in order
% their distorted to equal the original distorted image points.

und_tmp = distorted;

% inits
distortion_error = [1;1]; i=1; optim_done=0;
ii = 0;
while (~optim_done && ii < 4)
    
    u = und_tmp(1) - A(1,3);
    v = und_tmp(2) - A(2,3);
    y = v/A(2,2);
    x2 = ( (u-A(1,2)*y) / A(1,1) )^2;
    y2 = y^2;
    dis_tmp = und_tmp + [k1*u.*(x2+y2) + k2*u.*(x2+y2).^2; ...
        k1*v.*(x2+y2) + k2*v.*(x2+y2).^2];
    distortion_error(:,i) = dis_tmp - distorted;
    und_tmp = und_tmp - distortion_error(:,i);
    
    if (sum(distortion_error(:,i).^2)<1e-2) % dis_error < 1e-1 pixels
        
        optim_done=1;
        res_dis_error=sqrt(sum(distortion_error(:,i).^2));
    else
        ii=ii+1; % 4 iterations should suffice
    end
end
undistorted = und_tmp;
