function [intersection, t] = Tri_Intersection(receiver, direction, point_0, point_1, point_2)
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
    
    P = cross(direction, edge_2);
    det = dot(edge_1, P);
    
    if (abs(det) < epsilon) 
        %Case where the signal runs parallel to the triangle plane
        intersection = 0;
        t = NaN;
        return;
    end

    inv_det = 1 / det;
    T = receiver - point_0;
    u = dot(T, P) * inv_det;

    if (u < 0 || u > 1)
        %Case where the signal intersection is outside of the triangle
        intersection = 0;
        t = NaN;
        return;
    end
    
    Q = cross(T, edge_1);
    v = dot(direction, Q) * inv_det;
    
    if (v < 0 || u + v > 1)
        %Case where the signal intersection is outside of the triangle
        intersection = 0;
        t = NaN;
        return;
    end
    
    t = dot(edge_2, Q) * inv_det;

    if (t < epsilon || t > 1) % changed this line
        %Case where the signal intersection is before the receiver or after the end of the direction vector
        intersection = 0;
    else
        %Case where the signal intersects with the triangle
        intersection = 1;
    end
end
