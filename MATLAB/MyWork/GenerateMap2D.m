filename = 'NYC.stl';

filepath= 'STL_Files_Adjusted';

% Use fullfile to concatenate the file path and file name
full_filename = fullfile(filepath, filename);

F = stlread(full_filename);
points = F.Points;
CL = F.ConnectivityList;

BaseStationTotal=500;

x_start=450;
y_start=1250;
height =125;

receiver_list=[];

possibleLocations=[];
BaseStations=[];
counter2=0;

x_increments=400;
y_increments=500;

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

% Identify corner vertices and offset the points
[curvature_threshold_degrees, offset] = deal(90, 3);
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

results=[];

results_cell2={};

parfor_progress(length(receiver_list));

parfor m=1:length(receiver_list)

    receiver=receiver_list(:,m);

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
    
    [length_LOS,~]=size(LOS);

    disp(['Test ' num2str(m) ' / ' num2str(length(receiver_list))])
    disp(['x= ' num2str(receiver(1)) ' y= ' num2str(receiver(2)) ' z= ' num2str(receiver(3))])
    disp(['Basestations in LOS: ' num2str(length_LOS)])
    disp(['Basestations in NLOS: ' num2str(length(NLOS))])
    disp('-------------------------')

    % store the result for this iteration in a temporary variable
    tmp_result = length_LOS;
    
    % assign the temporary result to a unique index in a cell array
    results_cell2{m} = tmp_result;

    parfor_progress();
end

parfor_progress(0);

results = reshape(results_cell2, y_increments, x_increments);

results = cell2mat(cellfun(@(x) double(x), results, 'UniformOutput', false));

% Assuming 'filename', 'x_increments', and 'y_increments' are defined
filename_wo_ext = extractBefore(filename, '.stl'); % Remove the '.stl' extension

% Convert the numeric increments to strings
x_increments_str = num2str(x_increments);
y_increments_str = num2str(y_increments);

% Construct the output_filename
output_filename = [filename_wo_ext, '_', x_increments_str, 'x', y_increments_str, '.csv'];

% Define the output file path and name
output_filepath = '2D_results';

% Use fullfile to concatenate the file path and file name
full_output_filename = fullfile(output_filepath, output_filename);

% Write the 'results' matrix to the output file
writematrix(results, full_output_filename);
