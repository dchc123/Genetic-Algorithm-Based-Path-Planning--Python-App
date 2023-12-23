function [R, receiver_lat, receiver_long] = rec_loc(receiver,city_lat, time, city_rotation, earth_rad, height)
%Corresponds an x/y/z location in the city model cooridinate system to a
%global position in the orbits coordinate system.

%Convert position to kilometers from meterss
a = receiver(1)/1000;
b = receiver(2)/1000;

%Find 'c' distance
c = ((a^2)+(b^2))^0.5;

%Correspond position to adjestments to lat and long angle from reference
%point. Reference point is at 0 at 805 mins.
alpha = acos(a/c);
beta = alpha - city_rotation;
x = c*cos(beta);
y = c*sin(beta);
long_angle = (x / (2*pi*earth_rad))*2*pi;
lat_angle = (y / (2*pi*earth_rad))*2*pi;

%position city around earth based on given time
city_angle = ((time - 805)/1437)*2*pi;
if city_angle <= 0
    city_angle = (2*pi) + city_angle;
end
receiver_long = city_angle - long_angle;
receiver_lat = city_lat + lat_angle;

%Output receiver position corresponding to global coordinate system
R = (earth_rad + height).*...
    [(cos(receiver_lat)*cos(receiver_long));...
    (cos(receiver_lat)*sin(receiver_long));...
    sin(receiver_lat)];

end

