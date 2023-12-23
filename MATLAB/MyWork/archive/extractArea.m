
% Create a trisurf
[X,Y,Z] = peaks(25);
tri = delaunay(X,Y);
figure(1)
surface = trisurf(tri,X,Y,Z);
hold on

% Get the surface vertices
vertices = surface.Vertices;

% Get the z-coordinate of the surface at each (x,y) location
z_surface = griddata(vertices(:,1), vertices(:,2), vertices(:,3), X, Y);

z_surface_elevated = z_surface + 5;

% trisurf(tri,X,Y,z_surface_elevated)
hold on 

xmarks=[0;2]
ymarks=[0;2]
zmarks=[10;12]

marks=[xmarks,ymarks,zmarks]

f1 = scatter3(marks(:,1),marks(:,2),marks(:,3), 'filled', 'g')
f1.MarkerFaceAlpha = 0.6; 

for 


