clear all

%SYSTEM SET_UP:
    %Consistent variables- earth radius, New York location based on ref. point
earth_rad = 6371; %km
city_lat = 0.711160828008; %rads
city_rotation = pi*143/900; %rads

    %Changing variables - receiver position and time
height = 0.06;
time = 540;     %time set as minute in the day
receiver = [1000;2500;height*1000];

%RECEIVER POSITION:
    %Run function to correlate receiver position in city coordinate system to
    %global coordinate system
[R, receiver_lat, receiver_long] = rec_loc(receiver,city_lat, time, city_rotation, earth_rad, height);

%MODEL SAT. ORBITS:
    %Import satellite orbit data
Sat_Data = readtable('Sat_Loc.xls', 'Range', 'A3:L86');

    %Run function to plot orbits and identify satellites in view
    list = {'GPS','GLONASS','GALILEO'};
    prompt = {'Select which constellations you wish to include. More than one can be selected.'};
[indx,tf] = listdlg('ListString',list, 'PromptString',prompt, 'ListSize',...
    [400, 60], 'Name', 'Constellation Selection');
missing = [1;2;3];
for num = 1:length(indx)
    missing(ismember(missing,indx(num)),:)=[];
end
for num = 1:length(missing)
    Sat_Data(ismember(Sat_Data.Cons_,missing(num)),:)=[];
end 

[InView, names] = orbits(earth_rad, Sat_Data, R, time);

%ORIENT FOR CITY COORDINATES:
    %Orient the directional vectors relative to the receiver to correlate to
    %the city model coordinate system
[DirVectors] = vector_rot(InView, receiver_lat, receiver_long, city_rotation);

%CITY MODEL:
    %Identify which satellites with geographical line of sight are intercepted
    %by buildings and which satellites remain with LOS
F = stlread('NYC_Model.stl');
points = F.Points;
CL = F.ConnectivityList;

[DirVectorsXY,connectivity_sortedXY,DirVectorsXN,connectivity_sortedXN,...
    DirVectorsNN,connectivity_sortedNN,DirVectorsNY,connectivity_sortedNY]...
    = city_cut(points,CL, receiver,DirVectors);

[LOS] = [];
[NLOS] = [];

%need to find way to not call this if DV does not exist
if size(DirVectorsXY,1) ~= 0
    [LOSXY, NLOSXY] = city_LOS(DirVectorsXY,receiver, points, connectivity_sortedXY);
    [LOS] = [LOS;LOSXY];
    [NLOS] = [NLOS;NLOSXY];
end
if size(DirVectorsXN,1) ~= 0
    [LOSXN, NLOSXN] = city_LOS(DirVectorsXN,receiver, points, connectivity_sortedXN);
    [LOS] = [LOS;LOSXN];
    [NLOS] = [NLOS;NLOSXN];
end
if size(DirVectorsNN,1) ~= 0
    [LOSNN, NLOSNN] = city_LOS(DirVectorsNN,receiver, points, connectivity_sortedNN);
    [LOS] = [LOS;LOSNN];
    [NLOS] = [NLOS;NLOSNN];
end
if size(DirVectorsNY,1) ~= 0
    [LOSNY, NLOSNY] = city_LOS(DirVectorsNY,receiver, points, connectivity_sortedNY);
    [LOS] = [LOS;LOSNY];
    [NLOS] = [NLOS;NLOSNY];
end

figure(2)
trisurf(F);
xlabel('X position relative to ref. point, m');
ylabel('Y position relative to ref. point, m');
zlabel('Height above ground, m');
xlim([0 1285]);
ylim([0 2810]);
zlim([0 500]);
shading interp;
colormap bone;
daspect([1 1 1]);
hold on


for j = 1:size(LOS,1)
   D = [LOS(j,1);LOS(j,2);LOS(j,3)];
   test = receiver + 1500*D;
   X = [receiver(1);test(1)];
   Y = [receiver(2);test(2)];
   Z = [receiver(3);test(3)];
   scatter3 (receiver(1), receiver(2), receiver(3), 'filled', 'b');
   plot3(X,Y,Z,'g', 'LineWidth', 1.5);
   hold on 
end
   
 

for i = 1:size(NLOS,1)
    J = [NLOS(i,1);NLOS(i,2);NLOS(i,3)];
    tester = receiver + 1500*J;
    XJ = [receiver(1);tester(1)];
    YJ = [receiver(2);tester(2)];
    ZJ = [receiver(3);tester(3)];
    plot3(XJ, YJ, ZJ,'r', 'LineWidth', 1.5);
    hold on
end

print();



