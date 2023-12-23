% Set RNG seed for repeatable result
% rng(1,"twister");

% mapData = load("uavMapCityBlock.mat","omap");
% omap = mapData.omap;

% rng(7,"twister");
% Create an empty 3-D occupancy map. Specify the maximum width and maximum length of the map as desired. In this example, the map has an area of 200-by-200 square meters.

omap3D =  occupancyMap3D;
mapWidth = 200;
mapLength = 200;
% Specify the number of obstacles to be added.

numberOfObstacles = 10;
% Add the obstacles one after another using a while loop.
% 
% Generate the position and dimensions of the obstacle randomly using the randi function. Make sure the obstacle does not cross the map's boundaries.
% 
% Obtain the 3D grid coordinates of the obstacle using the meshgrid function.
% 
% Use the checkOccupancy (Navigation Toolbox) function to check if the obstacle intersects any other previously added obstacle. If it does, go to step 1. If it does not, move on to the next step.
% 
% Use the setOccupancy (Navigation Toolbox) function to set the occupancy values of the obstacle's location as 1.

obstacleNumber = 1;
while obstacleNumber <= numberOfObstacles
    width = randi([1 50],1);                 % The largest integer in the sample intervals for obtaining width, length and height                                                     
    length = randi([1 50],1);                % can be changed as necessary to create different occupancy maps.
    height = randi([1 150],1);
    xPosition = randi([0 mapWidth-width],1);
    yPosition = randi([0 mapLength-length],1);
    
    [xObstacle,yObstacle,zObstacle] = meshgrid(xPosition:xPosition+width,yPosition:yPosition+length,0:height);
    xyzObstacles = [xObstacle(:) yObstacle(:) zObstacle(:)];
    
    checkIntersection = false;
    for i = 1:size(xyzObstacles,1)
        if checkOccupancy(omap3D,xyzObstacles(i,:)) == 1
            checkIntersection = true;
            break
        end
    end
    if checkIntersection
        continue
    end
    
    setOccupancy(omap3D,xyzObstacles,1)
    
    obstacleNumber = obstacleNumber + 1;
end
% As a UAV must not collide with the ground during it's flight, consider the ground also as an obstacle. So, set the occupancy of the ground plane (x-y plane) as 1, indicating that it is an obstacle.

[xGround,yGround,zGround] = meshgrid(0:mapWidth,0:mapLength,0);
xyzGround = [xGround(:) yGround(:) zGround(:)];
setOccupancy(omap3D,xyzGround,1)
% Display the final occupancy map.

figure("Name","3D Occupancy Map")
show(omap3D)

% Consider unknown spaces to be unoccupied
omap3D.FreeThreshold = omap.OccupiedThreshold;

startPose = [12 22 25 pi/2];
goalPose = [150 180 35 pi/2];
figure("Name","StartAndGoal")
hMap = show(omap3D);
hold on
scatter3(hMap,startPose(1),startPose(2),startPose(3),30,"red","filled")
scatter3(hMap,goalPose(1),goalPose(2),goalPose(3),30,"green","filled")
hold off
view([-31 63])

ss = ExampleHelperUAVStateSpace("MaxRollAngle",pi/6,...
                                "AirSpeed",6,...
                                "FlightPathAngleLimit",[-0.1 0.1],...
                                "Bounds",[-20 220; -20 220; 10 100; -pi pi]);

threshold = [(goalPose-0.5)' (goalPose+0.5)'; -pi pi];

setWorkspaceGoalRegion(ss,goalPose,threshold)

sv = validatorOccupancyMap3D(ss,"Map",omap3D);
sv.ValidationDistance = 0.1;

planner = plannerRRT(ss,sv);
planner.MaxConnectionDistance = 50;
planner.GoalBias = 0.10;  
planner.MaxIterations = 400;
planner.GoalReachedFcn = @(~,x,y)(norm(x(1:3)-y(1:3)) < 5);

[pthObj,solnInfo] = plan(planner,startPose,goalPose);

if (solnInfo.IsPathFound)
    figure("Name","OriginalPath")
    % Visualize the 3-D map
    show(omap3D)
    hold on
    scatter3(startPose(1),startPose(2),startPose(3),30,"red","filled")
    scatter3(goalPose(1),goalPose(2),goalPose(3),30,"green","filled")
    
    interpolatedPathObj = copy(pthObj);
    interpolate(interpolatedPathObj,1000)
    
    % Plot the interpolated path based on UAV Dubins connections
    hReference = plot3(interpolatedPathObj.States(:,1), ...
        interpolatedPathObj.States(:,2), ...
        interpolatedPathObj.States(:,3), ...
        "LineWidth",2,"Color","g");
    
    % Plot simulated UAV trajectory based on fixed-wing guidance model
    % Compute total time of flight and add a buffer
    timeToReachGoal = 1.05*pathLength(pthObj)/ss.AirSpeed;
    waypoints = interpolatedPathObj.States;
    [xENU,yENU,zENU] = exampleHelperSimulateUAV(waypoints,ss.AirSpeed,timeToReachGoal);
    hSimulated = plot3(xENU,yENU,zENU,"LineWidth",2,"Color","r");
    legend([hReference,hSimulated],"Reference","Simulated","Location","best")
    hold off
    view([-31 63])
end

if (solnInfo.IsPathFound)
    smoothWaypointsObj = exampleHelperUAVPathSmoothing(ss,sv,pthObj);
    
    figure("Name","SmoothedPath")
    % Plot the 3-D map
    show(omap3D)
    hold on
    scatter3(startPose(1),startPose(2),startPose(3),30,"red","filled")
    scatter3(goalPose(1),goalPose(2),goalPose(3),30,"green","filled")
    
    interpolatedSmoothWaypoints = copy(smoothWaypointsObj);
    interpolate(interpolatedSmoothWaypoints,1000)
    
    % Plot smoothed path based on UAV Dubins connections
    hReference = plot3(interpolatedSmoothWaypoints.States(:,1), ...
        interpolatedSmoothWaypoints.States(:,2), ...
        interpolatedSmoothWaypoints.States(:,3), ...
        "LineWidth",2,"Color","g");
    
    % Plot simulated flight path based on fixed-wing guidance model
    waypoints = interpolatedSmoothWaypoints.States;
    timeToReachGoal = 1.05*pathLength(smoothWaypointsObj)/ss.AirSpeed;
    [xENU,yENU,zENU] = exampleHelperSimulateUAV(waypoints,ss.AirSpeed,timeToReachGoal);
    hSimulated = plot3(xENU,yENU,zENU,"LineWidth",2,"Color","r");
    
    legend([hReference,hSimulated],"SmoothedReference","Simulated","Location","best")
    hold off
    view([-31 63]);
end

