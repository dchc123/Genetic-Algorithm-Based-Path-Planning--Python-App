F = stlread('NYC_Model.stl');
points = F.Points;
CL = F.ConnectivityList;

x_list=points(:,1);
y_list=points(:,2);

delta = 0.1;

% [X,Y] = meshgrid(x_list(1:100),y_list(1:100));
% [X,Y] = meshgrid(1:delta:10,1:delta:20);

z_list=points(:,3);
Z = sin(X) + cos(Y);

x = [422   424   424   422   422  421   421   425   421    424];
y = [87   96   87   87   83    93    85   88    86   91];
z = [92.73  94.88  92.92  92.73  92.04  93.92  92.24  93.23  92.42  93.78];

figure(1)
stem3(x_list, y_list, z_list)
grid on
xv = linspace(min(x_list), max(x_list), length(x_list));
yv = linspace(min(y_list), max(y_list), length(y_list));
[X,Y] = meshgrid(xv, yv);
Z = griddata(x_list,y_list,z_list,X,Y);
figure(2)
surf(x_list, y_list, Z);
grid on
set(gca, 'ZLim',[0 100])
shading interp

% surf(X,Y,z_list)
% pts3d = [X(:) Y(:) z_list(:)];

% surf(X,Y,Z)
% pts3d = [X(:) Y(:) Z(:)];

% Create an empty occupancy map in 3d with the same resolution
map = occupancyMap3D(1/delta);
% Set the corresponding 3d points to represent occupancy
setOccupancy(map, pts3d, ones(size(pts3d,1), 1));
% See the map now
show(map)