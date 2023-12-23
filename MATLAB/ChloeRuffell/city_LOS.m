function [LOS, NLOS] = city_LOS(DirVectors,receiver, points, connectivity_sorted)
%For each signal, check if the signal intersects with buildings in the
%model or if it has LOS

LOS_Number = 1;
NLOS_Number = 1;

%For every signal, one at a time
for n = 1 : size(DirVectors,1)
    D = DirVectors(n,:);
    %Check M&T algorithm for intersection in the mesh
    toggle = city_intersection(receiver,D,points,connectivity_sorted);
    %If no intersection (toggle=0), add signal to LOS list
    if toggle == 0
        LOS(LOS_Number,:) = D;
        LOS_Number = LOS_Number+1;
    %If intersection, add signal to NLOS list   
    else
        NLOS(NLOS_Number,:) = D;
        NLOS_Number = NLOS_Number+1;
    end
end

%Allows empty matrices to be outputted, if all LOS or NLOS
if LOS_Number == 1
    LOS = [];
elseif NLOS_Number == 1
    NLOS = [];
end

end

