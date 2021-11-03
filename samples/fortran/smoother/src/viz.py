#!/usr/bin/python3

import json
import matplotlib
import numpy as np
import matplotlib.cm as cm
import matplotlib.pyplot as plt

# Load the function and the smoothed function
f = np.loadtxt('function.txt')
smoothF = np.loadtxt('smooth-function.txt')

# Reshape the functions, assuming a square grid
nelem = len(f)
nx = int(np.sqrt(nelem))
f = f.reshape((nx,nx))
smoothF = smoothF.reshape((nx,nx))

# Create the figure, showing the original function in the upper plot
# and the smoothed function in the lower plot
fig, (ax1, ax2) = plt.subplots(nrows = 2, ncols=1)
ax1.set_box_aspect(1)
ax2.set_box_aspect(1)

im = ax1.contourf(f,levels=np.arange(-1.0,1.0,0.1),cmap='gray')
im = ax2.contourf(smoothF,levels=np.arange(-1.0,1.0,0.1),cmap='gray')

fig.subplots_adjust(right=0.5)
cbar_ax = fig.add_axes([0.55, 0.125, 0.02, 0.75])
fig.colorbar(im, cax=cbar_ax)

plt.savefig("function.png",bbox_inches = 'tight',
            pad_inches = 0.1)


