from numpy import genfromtxt
from mayavi import mlab
import matplotlib.pyplot as plt
from scipy.interpolate import RegularGridInterpolator

# my_data = genfromtxt(r'C:\Users\ben\OneDrive - University of Bath\5th year\FYP\Simulation Development\Working Copies\MATLAB\MyWork\results.csv', delimiter=',')
my_data = genfromtxt(r'C:\Users\bs778\OneDrive - University of Bath\5th year\FYP\Simulation Development\Working Copies\MATLAB\MyWork\results.csv', delimiter=',')


print('test')

mlab.imshow(my_data)
mlab.show()