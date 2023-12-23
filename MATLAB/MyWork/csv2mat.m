% Specify the name of the CSV file
csv_file_name = 'London_400x550.csv';

% Load the data from the CSV file
csv_data = csvread(fullfile('2D_results', csv_file_name));

% Stack the 2D matrix on top of itself to produce a 3D matrix
stacked_data = repmat(csv_data, [1, 1, 5]);

% Create a folder for the .mat file
if ~exist('3D_results', 'dir')
    mkdir('3D_results');
end

% Save the 3D matrix as a .mat file in the "3D_results" folder
mat_file_name = fullfile('3D_results', [csv_file_name(1:end-4) '.mat']);
save(mat_file_name, 'stacked_data');

