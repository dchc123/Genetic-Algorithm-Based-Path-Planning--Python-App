filename = 'Stalagmites2.stl';

filepath= 'STL_Files_Adjusted';

% Use fullfile to concatenate the file path and file name
full_filename = fullfile(filepath, filename);

F = stlread(full_filename);
points = F.Points;
CL = F.ConnectivityList;

BaseStationTotal=200;
x_start=0;
y_start=0;
z_start=0;

receiver_list=[];

possibleLocations=[];
BaseStations=[];
counter2=0;

x_increments=60;
y_increments=60;
z_increments=35;

counter=0;
for x=x_start:(x_start+x_increments)-1
    for y=y_start:(y_start+y_increments)-1
        for z=z_start:(z_start+z_increments)-1
            counter=counter+1;

            position = counter;
            receiver_list(:,position)=[x,y,z];
        end
    end
end

% receiver_list(:,(x_increments*y_increments*z_increments)+1:end) = [];

% Assuming 'points' is your matrix
average_value = mean(points(:, 3));

% Print the average value
fprintf('The average value of the z column is: %f\n', average_value);

BaseStationMin=average_value*0.75;
BaseStationMax=average_value*1.25;

for i=1:length(points)
    if points(i,3)>30 && points(i,3)<120
        possibleLocations=[possibleLocations;points(i,:)];
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

results=[];
results_cell={};

parfor m=1:length(receiver_list)

%   clearvars -except receiver_list BaseStations points CL m RelativeBaseStations

    receiver=receiver_list(:,m);
    
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
    
    [length_LOS,~]=size(LOS);

    disp(['Test ' num2str(m) ' / ' num2str(length(receiver_list))])
    disp(['x= ' num2str(receiver(1)) ' y= ' num2str(receiver(2)) ' z= ' num2str(receiver(3))])
    disp(['Basestations in LOS: ' num2str(length_LOS)])
    disp(['Basestations in NLOS: ' num2str(length(NLOS))])
    disp('-------------------------')

    % store the result for this iteration in a temporary variable
    tmp_result = length_LOS;
    
    % assign the temporary result to a unique index in a cell array
    results_cell{m} = tmp_result;
end

% initialize a results array
new_results = zeros(x_increments, y_increments, z_increments);

% loop over each element in results_cell2 and assign to corresponding index in new_results
for i = 1:length(results_cell)
    % calculate the corresponding 3D index in results
    x = floor((i-1) / (y_increments*z_increments)) + x_start;
    y = mod(floor((i-1) / z_increments), y_increments) + y_start;
    z = mod(i-1, z_increments) + z_start;
    
    % assign the value from results_cell2 to the corresponding index in new_results
    new_results(x-x_start+1, y-y_start+1, z-z_start+1) = results_cell{i};
end

% Assuming 'filename', 'x_increments', and 'y_increments' are defined
filename_wo_ext = extractBefore(filename, '.stl'); % Remove the '.stl' extension

% Convert the numeric increments to strings
x_increments_str = num2str(x_increments);
y_increments_str = num2str(y_increments);
z_increments_str = num2str(z_increments);

% Construct the output_filename
output_filename = [filename_wo_ext, '_', x_increments_str, 'x', y_increments_str,'x', z_increments_str, '.mat'];

% Define the output file path and name
output_filepath = '3D_results';

% Use fullfile to concatenate the file path and file name
full_output_filename = fullfile(output_filepath, output_filename);

save(full_output_filename, 'new_results')