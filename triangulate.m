%this function was oringinally written by DLR in conjunction with their
%calibration software. it is a bit slow and in need of optimization. It is
%additionally good to note that there is an error threshold in this
%function, set this threshold based on your data. Points with greater error
%will be initialized to [0,0,0,0]
function point_camera = triangulate(und_upper, und_lower, A, A_stereo, T_cam1_cam2)

%error threshold in mm
errThresh = 100;

% get normalized coordinates for camera #1
u = und_upper(1) - A(1,3);
v = und_upper(2) - A(2,3);
y_upper = v/A(2,2);
x_upper = ( (u-A(1,2)*y_upper) / A(1,1) );

% get normalized coordinates for camera #2
u = und_lower(1) - A_stereo(1,3);
v = und_lower(2) - A_stereo(2,3);
y_lower = v/A_stereo(2,2);
x_lower = ( (u-A_stereo(1,2)*y_lower) / A_stereo(1,1) );

% linear least squares solution for triangulation
% with the rigid body motion constraint T_cam1_cam2
% (in the form: M * x = m)
%
M = [[x_upper;y_upper;1] -T_cam1_cam2(1:3,1:3)*[x_lower;y_lower;1]];
m = T_cam1_cam2(1:3,4);
% SVD solution
[U,S,V]=svd(M);
m_=U'*m;
s = size(S);
m_(1:s(2))./sum(S)';
sol = V*ans;

%distance_to_camera = sum(sol)/2
distance_to_camera_1 = sqrt(sum(([x_upper;y_upper;1]*sol(1)).^2));
distance_to_camera_2 = sqrt(sum(([x_lower;y_lower;1]*sol(2)).^2));

% [[x_upper;y_upper;1]*sol(1);1]
% T_cam1_cam2*([[x_lower;y_lower;1]*sol(2);1])

% admittedly this solution ain't any optimal but approximated...
point_camera = ( [[x_upper;y_upper;1]*sol(1)] + ...
    T_cam1_cam2*([[x_lower;y_lower;1]*sol(2);1]) ) / 2;
point_camera(4)=1;

error = ([[x_upper;y_upper;1]*sol(1)] -...
    (T_cam1_cam2*([[x_lower;y_lower;1]*sol(2);1])));
euclidean_error = sqrt(sum(error(1:3).^2));
if euclidean_error>errThresh
    %disp('Left and right rays do not really cut (within ten centimeter)');
    point_camera = [0,0,0,0];
end