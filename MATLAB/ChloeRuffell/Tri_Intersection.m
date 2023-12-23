function [intersection,t] = Tri_Intersection (receiver, direction, point_0, point_1, point_2)
%Runs Moller and Trumbore on one triangle to check for intersection
% Input arguments:
%    receiver: receiver position
%    direction: direction of the signal from receiver to satellite
%    point_0, point_1, point_2: vertices of the triangle in the mesh

% Output arguments:
%    intersection: 1 if signal intersects with mesh

    epsilon = 0.00001;
    edge_1 = point_1 - point_0;
    edge_2 = point_2 - point_0;
    
    a  = cross(direction, edge_2);
    b  = dot(edge_1, a);
    c = receiver - point_0;
    d = cross(c, edge_1);
    
    %Barycentric coordinates of the point of intersection
    int_1 = (1 / b) * dot(c, a);
    int_2 = (1 / b) * dot(direction, d);
  
    %Distance of intersection from origin
    t = (1 /b)*dot(edge_2, d);
    
    if (b > -epsilon && b < epsilon) 
        %Case where the signal runs parallel to the triangle plane
        intersection = 0;
    elseif int_1 < 0 || int_2 < 0 || int_1 + int_2 > 1
        %Case where the signal intersection is outside of the triangle
        intersection = 0;        
    else
        %Case where the signal intersects with the triangle
        intersection = 1;
    end
end
