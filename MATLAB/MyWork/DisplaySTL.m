F = stlread('STL_Files_Adjusted\NYC.stl');
points = F.Points;
CL = F.ConnectivityList;

figure(1)
surf = trisurf(F);

xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
shading interp;
colormap pink;
daspect([1 1 1]);
hold on

% Define two corner points of the rectangle
p1 = [500, 1400];
p2 = [900, 1900];

% Calculate the remaining vertices of the rectangle
x = [p1(1), p2(1), p2(1), p1(1)];
y = [p1(2), p1(2), p2(2), p2(2)];
z = [125, 125, 125, 125];

% Add a translucent rectangle at a height of 100 units
patch(x, y, z, 'r', 'FaceAlpha', 0.5);

% % Identify corner vertices and offset the points
% [curvature_threshold_degrees, offset] = deal(45, 3);
% [corner_vertices, offset_points] = identify_corners(points, CL, curvature_threshold_degrees, offset);
% 
% % Plot the offset points as a scatter plot
% scatter3(points(corner_vertices, 1), points(corner_vertices, 2), points(corner_vertices, 3), 'Marker', 'x', 'MarkerEdgeColor', 'r', 'SizeData', 2)
% 
% % Randomly select corner points for the base station locations
% BaseStationTotal = 500;
% possibleLocations = [];
% BaseStations = [];
% 
% for i=1:length(offset_points)
%     if offset_points(i, 3) > 30 && offset_points(i, 3) < 120
%         possibleLocations = [possibleLocations; offset_points(i, :)];
%     end
% end
% 
% random_numbers = randi([1, length(possibleLocations)], 1, BaseStationTotal);
% 
% for i=1:length(random_numbers)
%     BaseStations = [BaseStations; possibleLocations(random_numbers(i), :)];
% end
% 
% figure(2)
% surf = trisurf(F);
% 
% xlabel('X (m)');
% ylabel('Y (m)');
% zlabel('Z (m)');
% shading interp;
% colormap pink;
% daspect([1 1 1]);
% hold on
% 
% scatter3(BaseStations(:, 1), BaseStations(:, 2), BaseStations(:, 3), 'Marker', 'x', 'MarkerEdgeColor', 'g', 'SizeData', 2)







