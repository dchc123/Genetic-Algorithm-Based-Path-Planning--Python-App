% Read the STL file

filename = 'Paris_EiffelTower.stl';

filepath= 'STL_Files_Raw';

% Use fullfile to concatenate the file path and file name
full_filename = fullfile(filepath, filename);

tr = stlread(full_filename);

% Access the vertices from the triangulation object
vertices = tr.Points;

% Find the minimum values for each coordinate (x, y, and z)
min_values = min(vertices);

% Offset the vertices to make them positive
offset_vertices = vertices - repmat(min_values, size(vertices, 1), 1);

% Define the scaling factor
scaling_factor = 0.00095;

% Scale the vertices
scaled_vertices = offset_vertices * scaling_factor;

% Create a new triangulation object with the modified vertices
scaled_tr = triangulation(tr.ConnectivityList, scaled_vertices);

savepath= 'STL_Files_Adjusted';

% Use fullfile to concatenate the file path and file name
full_filename = fullfile(savepath, filename);

% Write the modified model to a new STL file (optional)
stlwrite(scaled_tr, full_filename);

figure(1)
surf=trisurf(tr);

xlabel('X position');
ylabel('Y position');
zlabel('Z position');
shading interp;
colormap pink;
daspect([1 1 1]);
hold on

figure(2)
surf=trisurf(scaled_tr);

xlabel('X position');
ylabel('Y position');
zlabel('Z position');
shading interp;
colormap pink;
daspect([1 1 1]);
hold on
