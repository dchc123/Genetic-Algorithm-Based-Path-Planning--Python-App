F = stlread('STL_Files_Adjusted\Chicago_City.stl');
points = F.Points;
CL = F.ConnectivityList;

BaseStationTotal=250;
receiver = [600;500;200];

possibleLocations=[];
BaseStations=[];

% Assuming 'points' is your matrix
average_value = mean(points(:, 3));

% Print the average value
fprintf('The average value of the z column is: %f\n', average_value);

% Identify corner vertices and offset the points
[curvature_threshold_degrees, offset] = deal(90, 5);
[corner_vertices, offset_points] = identify_corners(points, CL, curvature_threshold_degrees, offset);

for i=1:length(offset_points)

    if  offset_points(i,3)>30 && offset_points(i,3)<120
        possibleLocations=[possibleLocations;offset_points(i,:)];
    end

end

random_numbers = randi([1, length(possibleLocations)], 1, BaseStationTotal);

for i=1:length(random_numbers)
    BaseStations=[BaseStations;possibleLocations(random_numbers(i),:)];
end

RelativeBaseStations=[];

for i = 1:size(BaseStations,1)
    New_Point=BaseStations(i,:)-transpose(receiver);
    RelativeBaseStations = [RelativeBaseStations;New_Point];
end

[DirVectorsXY,connectivity_sortedXY,DirVectorsXN,connectivity_sortedXN,...
    DirVectorsNN,connectivity_sortedNN,DirVectorsNY,connectivity_sortedNY]...
    = city_cut(points,CL, receiver,RelativeBaseStations);


[LOS] = [];
[NLOS] = [];

%need to find way to not call this if DV does not exist
if size(DirVectorsXY,1) ~= 0
    [LOSXY, NLOSXY] = city_LOS(DirVectorsXY,receiver, points, connectivity_sortedXY);
    [LOS] = [LOS;LOSXY];
    [NLOS] = [NLOS;NLOSXY];
end
if size(DirVectorsXN,1) ~= 0
    [LOSXN, NLOSXN] = city_LOS(DirVectorsXN,receiver, points, connectivity_sortedXN);
    [LOS] = [LOS;LOSXN];
    [NLOS] = [NLOS;NLOSXN];
end
if size(DirVectorsNN,1) ~= 0
    [LOSNN, NLOSNN] = city_LOS(DirVectorsNN,receiver, points, connectivity_sortedNN);
    [LOS] = [LOS;LOSNN];
    [NLOS] = [NLOS;NLOSNN];
end
if size(DirVectorsNY,1) ~= 0
    [LOSNY, NLOSNY] = city_LOS(DirVectorsNY,receiver, points, connectivity_sortedNY);
    [LOS] = [LOS;LOSNY];
    [NLOS] = [NLOS;NLOSNY];
end

figure(1)
surf=trisurf(F);

xlabel('X position');
ylabel('Y position');
zlabel('Z position');
% xlim([0 1285]);
% ylim([0 2810]);
% zlim([0 1000]);
shading interp;
colormap bone;
daspect([1 1 1]);
hold on
scatter3(receiver(1),receiver(2),receiver(3), 'filled');
hold on

basestation=[];

for j = 1:size(LOS,1)
    
   basestation=transpose(receiver)+LOS(j,:); 

   pts = [transpose(receiver); basestation];
   plot3(pts(:,1), pts(:,2), pts(:,3), 'g','LineWidth', 1.5)
   hold on 

end
   
for i = 1:size(NLOS,1)
    
   basestation=transpose(receiver)+NLOS(i,:); 
   pts = [transpose(receiver); basestation];
   plot3(pts(:,1), pts(:,2), pts(:,3), 'r','LineWidth', 1.5)
   hold on 

end

figure(2)
surf=trisurf(F);

xlabel('X position');
ylabel('Y position');
zlabel('Z position');
% xlim([0 1285]);
% ylim([0 2810]);
% zlim([0 1000]);
shading interp;
colormap bone;
daspect([1 1 1]);
hold on
scatter3(receiver(1),receiver(2),receiver(3), 'filled');
hold on

basestation=[];

for j = 1:size(LOS,1)
    
   basestation=transpose(receiver)+LOS(j,:); 

   pts = [transpose(receiver); basestation];
   plot3(pts(:,1), pts(:,2), pts(:,3), 'g','LineWidth', 1.5)
   hold on 

end

[length_LOS,~]=size(LOS);

disp(['Basestations in LOS: ' num2str(length_LOS)])
disp(['Basestations in NLOS: ' num2str(length(NLOS))])







