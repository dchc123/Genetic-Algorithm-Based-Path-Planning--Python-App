function [DirVectors] = vector_rot(InView, receiver_lat, receiver_long, city_rotation)

for g = 1 : length(InView)
    
    DUV = [InView(g,1);InView(g,2);InView(g,3)];
    
    rot_angle_one = (2*pi)- receiver_long;
    rot_angle_two = -((pi/2)-receiver_lat);
    rot_angle_three = (pi/2)-city_rotation;
    
    cos_one = cos(rot_angle_one);
    sin_one = sin(rot_angle_one);
    cos_two = cos(rot_angle_two);
    sin_two = sin(rot_angle_two);
    cos_thr = cos(rot_angle_three);
    sin_thr = sin(rot_angle_three);
    
    %Rotate around Z to align with reference x axis
    DUV_One = [((DUV(1)*cos_one)-(DUV(2)*sin_one));((DUV(1)*sin_one)+(DUV(2)*cos_one));DUV(3)];
    
    %Rotate around Y to align with xy plane
    DUV_Two = [((DUV_One(1)*cos_two)+(DUV_One(3)*sin_two));DUV_One(2);(-(DUV_One(1)*sin_two)+(DUV_One(3)*cos_two))];
    
    %Rotate around Z for city orientation
    DUV_Thr = [((DUV_Two(1)*cos_thr)-(DUV_Two(2)*sin_thr));((DUV_Two(1)*sin_thr)+(DUV_Two(2)*cos_thr));DUV_Two(3)];
      
    DirVectors(g,:) = [DUV_Thr(1);DUV_Thr(2);DUV_Thr(3)];

end

end

