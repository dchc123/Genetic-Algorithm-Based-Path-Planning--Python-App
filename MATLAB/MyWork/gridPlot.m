filename = 'London.stl';

filepath= 'STL_Files_Adjusted';

% Use fullfile to concatenate the file path and file name
full_filename = fullfile(filepath, filename);

F = stlread(full_filename);
points = F.Points;
CL = F.ConnectivityList;

BaseStationTotal=300;

x_start=520;
y_start=350;
height =100;

receiver_list=[];

possibleLocations=[];
BaseStations=[];
counter2=0;

x_increments=50;
y_increments=50;

for x=x_start:x_start+x_increments
    counter=0;
    for y=y_start:y_start+y_increments
         counter=counter+1;
         receiver_list(:,counter+counter2)=[x,y,height];
    end
    counter2=counter2+y_increments;
end

receiver_list(:,(x_increments*y_increments)+1:end) = [];

% Assuming 'points' is your matrix
average_value = mean(points(:, 3));

% Print the average value
fprintf('The average value of the z column is: %f\n', average_value);

% Calculate vertex neighborhoods
vertex_neighborhoods = cell(size(points, 1), 1);
for ii = 1:size(CL, 1)
    for jj = 1:size(CL, 2)
        vertex_neighborhoods{CL(ii, jj)} = unique([vertex_neighborhoods{CL(ii, jj)}; CL(ii, mod(jj, 3) + 1); CL(ii, mod(jj + 1, 3) + 1)]);
    end
end

% Calculate discrete mean curvature in degrees
mean_curvature = zeros(size(points, 1), 1);
for ii = 1:size(points, 1)
    neighbors = vertex_neighborhoods{ii};
    neighbors = neighbors(neighbors ~= ii);
    n = length(neighbors);
    sum_angles = 0;
    sum_edge_lengths = 0;
    for jj = 1:n
        v1 = points(neighbors(jj), :) - points(ii, :);
        v2 = points(neighbors(mod(jj, n) + 1), :) - points(ii, :);
        angle = atan2d(norm(cross(v1, v2)), dot(v1, v2));
        sum_angles = sum_angles + angle;
        sum_edge_lengths = sum_edge_lengths + norm(v1);
    end
    mean_curvature(ii) = (360 - sum_angles) / sum_edge_lengths;
end

% Convert the curvature threshold from degrees to the method's units
curvature_threshold_degrees = 90; % Adjust this value as needed
curvature_threshold = 2 * tand(curvature_threshold_degrees/2);

% Find corner vertices using curvature threshold
corner_vertices = find(mean_curvature > curvature_threshold);

% Offset the vertices
offset = 2; % adjust this value as needed
offset_points = points;
offset_points(corner_vertices, 3) = offset_points(corner_vertices, 3) + offset;

for i=1:length(offset_points)

    if  offset_points(i,3)>30 && offset_points(i,3)<120
        possibleLocations=[possibleLocations;offset_points(i,:)];
    end

end

random_numbers = randi([1, length(possibleLocations)], 1, BaseStationTotal);

for i=1:length(random_numbers)
    BaseStations=[BaseStations;possibleLocations(random_numbers(i),:)];
end

% Plot 1: STL file
subplot(2,2,1)
surf(points(:,1), points(:,2), points(:,3))
shading interp
colormap pink
axis equal
title('STL file')

% Plot 2: STL file with identified vertices
subplot(2,2,2)
surf(points(:,1), points(:,2), points(:,3))
shading interp
colormap pink
hold on
scatter3(points(corner_vertices,1), points(corner_vertices,2), points(corner_vertices,3), 'r.')
axis equal
title('STL file with identified vertices')

% Plot 3: STL file with selected base stations
subplot(2,2,3)
surf(points(:,1), points(:,2), points(:,3))
shading interp
colormap pink
hold on
scatter3(BaseStations(:,1), BaseStations(:,2), BaseStations(:,3), 'bo')
axis equal
title('STL file with selected base stations')

% Plot 4: STL file
subplot(2,2,4)
surf(points(:,1), points(:,2), points(:,3))
shading interp
colormap pink
axis equal
title('STL file')

suptitle('STL File Plots')
% Note: This assumes that points and corner_vertices have already been defined and are the same as in the previous code block.






