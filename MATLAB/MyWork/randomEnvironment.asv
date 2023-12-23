% Define the size of the 3D array
arraySize = [500, 500, 500];

% Define the parameters for the cuboids
numCuboids = 50;         % Number of cuboids
cuboidSize = [20, 30];  % Size of each cuboid [x, y]

% Create the 3D array and initialize with 10
array = ones(arraySize) * 10;

% Generate and place the cuboids randomly
for i = 1:numCuboids
    % Generate random positions within the array
    x = randi(arraySize(1) - cuboidSize(1) + 1);
    y = randi(arraySize(2) - cuboidSize(2) + 1);
    z = 1;  % Start from z=1

    % Assign 0 to cells within the cuboid
    array(x:x+cuboidSize(1)-1, y:y+cuboidSize(2)-1, z:arraySize(3)) = 0;
end

% Save the 3D array to a .mat file
save('cuboids2.mat', 'array');
