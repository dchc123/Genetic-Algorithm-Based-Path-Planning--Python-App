function [DirVectorsXY,connectivity_sortedXY,DirVectorsXN,connectivity_sortedXN,DirVectorsNN,connectivity_sortedNN,DirVectorsNY,connectivity_sortedNY] = city_cut(points,CL, receiver, DirVectors)
%Segments city model into sections each to be selected dependent on the
%signal vector dircetion. First, cuts away model below the receiver height
%as signals will not come from below. Then splits into meshes based on
%+ve/-ve X values (X/N) and +ve/-ve Y values (Y/N). Outputted as sorted 
%connectivity lists, named connectivity_sorted'(X/N)''(Y/N)'.

    %Exclude city building mesh significantly below receiver height (Cut Z)
% point_row = find(points(:,3)<= (receiver(3)-5));    %identify points below receiver
% CL_check = ismember(CL, point_row);                 %check CL for triangles with points below receiver
% CL_check(:,4) =  sum(CL_check,2)== 3;               %identify triangles below receiver
% connectivity_sorted = CL(CL_check(:, 4) == 0, :);   %exclude triangles from CL

connectivity_sorted = CL;

    %Sort signals in +ve/-ve X direction. Segment mesh by X.
n=1;
m=1;
DirVectorsX = [];
DirVectorsN = [];
for a = 1: size(DirVectors,1)
    if DirVectors(a,1) >= 0
       DirVectorsX(n,:) = DirVectors(a,:);
       n = n+1;
    else
        DirVectorsN(m,:) = DirVectors(a,:);
        m = m+1;
    end
end

    %Remove points to left of receiver position (signal X is +ve)
point_rowX = find(points(:,1)<= (receiver(1)-5));
CL_checkX = ismember(connectivity_sorted, point_rowX);
CL_checkX(:,4) =  sum(CL_checkX,2) == 3;
connectivity_sortedX = connectivity_sorted(CL_checkX(:, 4) == 0, :);
    %Remove points to right of receiver position (signal X is -ve)
point_rowN = find(points(:,1)>= (receiver(1)+5));
CL_checkN = ismember(connectivity_sorted, point_rowN);
CL_checkN(:,4) =  sum(CL_checkN,2) == 3 ;
connectivity_sortedN = connectivity_sorted(CL_checkN(:, 4) == 0, :);

%Sort signals in +ve/-ve Y direction. Segment mesh for +ve X by Y.
i=1;
j=1;
DirVectorsXY = [];
DirVectorsXN = [];
for b = 1: size(DirVectorsX,1)
    if DirVectorsX(b,2) >= 0
       DirVectorsXY(i,:) = DirVectorsX(b,:);
       i = i+1;
    else
        DirVectorsXN(j,:) = DirVectorsX(b,:);
        j = j+1;
    end
end
%X is +ve, Y is +ve
point_rowXY = find(points(:,2)<= (receiver(2)-5));
CL_checkXY = ismember(connectivity_sortedX, point_rowXY);
CL_checkXY(:,4) =  sum(CL_checkXY,2) == 3;
connectivity_sortedXY = connectivity_sortedX(CL_checkXY(:, 4) == 0, :);
%X is +ve, Y is -ve
point_rowXN = find(points(:,2)>= (receiver(2)+5));
CL_checkXN = ismember(connectivity_sortedX, point_rowXN);
CL_checkXN(:,4) =  sum(CL_checkXN,2) == 3;
connectivity_sortedXN = connectivity_sortedX(CL_checkXN(:, 4) == 0, :);

%Sort signals in +ve/-ve Y direction. Segment mesh for -ve X by Y.
f=1;
g=1;
DirVectorsNY = [];
DirVectorsNN = [];
for d = 1: size(DirVectorsN,1)
    if DirVectorsN(d,2) >= 0
       DirVectorsNY(f,:) = DirVectorsN(d,:);
       f = f+1;
    else
        DirVectorsNN(g,:) = DirVectorsN(d,:);
        g = g+1;
    end
end
%X is -ve, Y is +ve
point_rowNY = find(points(:,2)<= (receiver(2)-5));
CL_checkNY = ismember(connectivity_sortedN, point_rowNY);
CL_checkNY(:,4) =  sum(CL_checkNY,2) == 3;
connectivity_sortedNY = connectivity_sortedN(CL_checkNY(:, 4) == 0, :);

%X is -ve, Y is -ve
point_rowNN = find(points(:,2)>= (receiver(2)+5));
CL_checkNN = ismember(connectivity_sortedN, point_rowNN);
CL_checkNN(:,4) =  sum(CL_checkNN,2) == 3;
connectivity_sortedNN = connectivity_sortedN(CL_checkNN(:, 4) == 0, :);

end

