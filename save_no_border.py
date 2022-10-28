#!/usr/bin/env python

# This code was written by Kriztina Kelevitz and Brie Corsa
# To reference, please refer to:

# 1. Kelevitz, K., Tiampo, K., Corsa, B. Improved Real-Time Natural Hazard Monitoring Automated DInSAR Time Series.
# Remote Sensing 2021, 13(5), 867. https://doi.org/10.3390/rs13050867
# 2. Corsa, B., Barba-Sevilla, M., Tiampo, K., Meertens, C. Integration of DInSAR time series and GNSS Data for continuous volcanic 
# deformation monitoring and eruption early warning applications. Remote Sens. 2022, 14, 784. https://doi.org/10.3390/rs14030784


import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.widgets import Slider
from matplotlib.ticker import FormatStrFormatter
import sys
import h5py
import datetime as dt
import tsinsar as ts
import matplotlib.dates as mdates
import collections



hfile_t78 = h5py.File('/net/tiampostorage/volume1/BrieShare/YellowstoneProject/Kilauea/giant/Stack/NSBAS-PARAMS.h5','r')
tims_t78 = hfile_t78['tims'].value #time vector in years wrt master date
data_t78 = hfile_t78['recons'] #mm #filtered data
raw_t78 = hfile_t78['rawts'] #mm #raw data


###### Dates
dates_t78 = hfile_t78['dates'].value
t0 = dt.date.fromordinal(np.int(dates_t78[0]))
t0 = t0.year + t0.timetuple().tm_yday/(np.choose((t0.year % 4)==0,[365.0,366.0]))
tims_t78 = tims_t78+t0
updated_dates_t78 = [dt.date.fromordinal(np.int(i)) for i in dates_t78] #dates in datetime format

residual = data_t78[-1,:,:]

plt.figure()
plt.imshow(residual)
plt.colorbar()
plt.clim(-25,25)


pv = plt.figure(figsize=(8,8))
axv = pv.add_axes([0., 0., 1., 1.])    ####Full space.
img = axv.imshow(data_t78[-1,:,:])
#axv.set_xlim([0,fwid])
#axv.set_ylim([0,flen])
axv.yaxis.set_visible(False)
axv.xaxis.set_visible(False)
pv.savefig('Kilauea_test.png',bbox_inches='tight',transparent=True)

'''
plt.figure()
plt.imshow(data_t78[42,:,:])
plt.colorbar()
plt.clim(-250,250)    
 
'''
plt.show()

#for k in range(len(raw_t78)):
#    imname = './I%03d.png'%(k+1)
#    idict = collections.OrderedDict()
#    idict['residual'] = residual
#    ts.imagemany(idict,save=imname)

