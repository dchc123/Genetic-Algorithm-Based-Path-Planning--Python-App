function [InView, names] = orbits(earth_rad, Sat_Data, R, time)


% %INITIATE FIGURE: Create plot with the earth represented at the origin
    %plot earth
figure(1);    
[a,b,c] = sphere;
a = a*earth_rad; b = b*earth_rad; c = c*earth_rad;
surf(a,b,c); shading interp; colormap summer;
hold on
    %plot axis
%d = 0:35000:35000; e = [0;0]; f = [0;0];
%plot3(d,e,f,'k'); 
%plot3(e,d,f,'k'); plot3(e,f,d,'k');
    %format view
daspect([1 1 1]);
xlabel('Distance from earth centre along vernal equinox (reference axis), m');
ylabel('Distance from earth centre, m');
zlabel('Distance from earth centre, m');
hold on
    %plot receiver location
scatter3(R(1),R(2),R(3),'filled','b');
hold on

size = 1;
constellations = height(Sat_Data);
for i = 1:constellations
    
    %VARIABLES: Extract variables for one satellite
    name = Sat_Data.Sat(i);                     %Sat. Name
    alt = Sat_Data.Alt(i);                      %Altitude, km
    inc = Sat_Data.Inc(i);                      %Inclination, degrees
    ecc = Sat_Data.Ecc(i);                      %Eccentricity
    RAAN = Sat_Data.RAAN(i);                    %Right Ascension Ascending Node, hrs
    arg_peri = Sat_Data.Arg_Peri(i);            %Argument of Perihillion, degrees
    mean_anomaly = Sat_Data.Mean_Anom(i);       %Mean Anomaly, degrees
    period = 1440/(Sat_Data.Mean_Motion(i));    %Period, mins
    epoch_time = Sat_Data.Epoch_Min(i);         %Epoch osculation, min
       
    %ELLIPSE: Identify ellptical profile of satellite orbit
    r1 = alt + earth_rad;                       %Semi-major axis
    r2 = sqrt(r1^2-((r1^2)*(ecc^2)));           %Semi-minor axis
    xc = sqrt((r1^2)-(r2^2));                   %X Displacement to centre earth
    yc = 0;                                     %Y Displacement to centre earth
    t = linspace(0, 2*pi, 1440);                %Creates an array of points
    x_e = r1 * cos(t) - xc;                     %Parametric x coordinates
    y_e = r2 * sin(t) - yc;                     %Parametric y coordinates
    z_e = 0*t;                                  %Parametric z coordinates

    %PERIGEE: Apply the argument of perigee rotation
    theta_peri = (arg_peri/180)*pi;             %Arg. of Peri. in radians
    cot_p = cos(theta_peri); 
    sit_p = sin(theta_peri);
    x_p = x_e * cot_p - y_e * sit_p;            %Rotation matrix about Z
    y_p = x_e * sit_p + y_e * cot_p;
    z_p = z_e;
    
    %INCLINATION: Rotate by inclination angle around x axis   
    theta_inc = -(inc / 180) * pi;              %Inclination in radians
    cot_i = cos(theta_inc); 
    sit_i = sin(theta_inc);
    x_i = x_p;                                  %Rotation matrix about X
    y_i = y_p * cot_i - z_p * sit_i;
    z_i = - y_p * sit_i + z_p * cot_i;

    %ASCENDING NODE: Rotate about Z by the longitude of the ascending node
    theta_asc = ((RAAN * 60) / 1440)* 2 * pi;   %RAAN in radians
    cot_a = cos(theta_asc); 
    sit_a = sin(theta_asc);
    x_a = x_i * cot_a - y_i * sit_a;            %Rotation matric about Z
    y_a = x_i * sit_a + y_i * cot_a;
    z_a = z_i;

    %PLOT: Plot the satellite orbital path
    if Sat_Data.Cons_(i) == 1
        plot3(x_a, y_a, z_a,'color',[1 0.3 0.3]);
    elseif Sat_Data.Cons_(i) == 2
        plot3(x_a, y_a, z_a, 'color','b' );
    else
        plot3(x_a, y_a, z_a, 'color',[0.9 0.9 0.2] );
    end
    %[0 0.7 0.9]
    %POSITION: Find poisition of satellite on the orbital path at given time
    time_diff = time - epoch_time;
    shift = (time_diff / period) * 360;
    pos = mean_anomaly + shift;
    posi = mod(pos, 360);
    point = round((posi / 360) * 1440);
    if point>=0
        S = [x_a(point);y_a(point);z_a(point)];    
    else
        S = [x_a(1440-point);y_a(1440-point);z_a(1440-point)];   
    end
    
    %VISIBLE HEMISPHERE: Identify if satellite is blocked by earth 
    d = ((S(1)-R(1))^2 + (S(2)-R(2))^2 + (S(3)-R(3))^2)^0.5; % distance
    U = [(S(1)-R(1))/d;(S(2)-R(2))/d;(S(3)-R(3))/d];         % direction
    for j = 1:100                                            % identifies points along ray
        new_d = (j/100)*d;
        L(j,:) = S - (new_d * U);                            
        proximity = ((L(j,1)^2)+(L(j,2)^2)+(L(j,3)^2))^0.5;
        if proximity <= earth_rad
            O(j) = 1;
        else
            O(j) = 0;
        end
    end
    if sum(O) == 0                                           %No intersection
        scatter3(S(1),S(2),S(3),30, [0.1 0.8 0.1], 'filled');
        InView(size,:) = [U(1);U(2);U(3)];                  %add to InView matrix
        names(size,:) = [name];
        size = size + 1;
    else
        scatter3(S(1),S(2),S(3),25, [0.3 0.3 0.3],'filled');              %Intersects
    end  
end

end

