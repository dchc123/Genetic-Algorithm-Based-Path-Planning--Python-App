Final_Model_SA_Point:

This folder contains all relevant code to calculate the signal availability for a given location at a given time. 
The primary script is 'sig_av_model.m' and this will call all relevant functions and access necessary data from included files.
Time will be set in line 11 in the format of the minute of the day.
Receiver location is set in line 12, where the X and Y coordinates are in the context of the city coordinate system. 
The receiver Z coordinate is calculated from the receiver height, set in line 10.
