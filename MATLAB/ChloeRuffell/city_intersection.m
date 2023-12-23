function [toggle] = city_intersection(receiver,D,points,connectivity_sorted)
%Set up and run Moller and Trumbore algorithm on every triangle on the mesh 
%to see if the specified signal is obstructed by a building.

height = size(connectivity_sorted,1);
toggle = 0;
%For every triangle in the mesh
for a = 1:height
        %Extract the point indices for triangle points
        b = connectivity_sorted(a,1);
        c = connectivity_sorted(a,2);
        d = connectivity_sorted(a,3);
        %Set point coordinates for triangle under test
        point_0 = transpose(points(b,:));
        point_1 = transpose(points(c,:));
        point_2 = transpose(points(d,:));
        
        %Run Moller and Trumbore for defined triangle
        [intersection, t] = Tri_Intersection (receiver, D, point_0, point_1, point_2);
        
        %If intersection with the tri., set the signal as having
        %intersected, break the loop and move onto the next signal. 
        if intersection == 1 && t >= 0 
            toggle = 1;
            break
        end
end
    
end

