#!/usr/bin/env python

# This code was written by Kriztina Kelevitz and Brie Corsa
# To reference, please refer to:

# 1. Kelevitz, K., Tiampo, K., Corsa, B. Improved Real-Time Natural Hazard Monitoring Automated DInSAR Time Series.
# Remote Sensing 2021, 13(5), 867. https://doi.org/10.3390/rs13050867
# 2. Corsa, B., Barba-Sevilla, M., Tiampo, K., Meertens, C. Integration of DInSAR time series and GNSS Data for continuous volcanic 
# deformation monitoring and eruption early warning applications. Remote Sens. 2022, 14, 784. https://doi.org/10.3390/rs14030784



'''Example script for creating XML files for use with the SBAS processing chain. This script is supposed to be copied to the working directory and modified as needed.'''

import tsinsar as ts
import argparse
import numpy as np

def parse():
    parser= argparse.ArgumentParser(description='Preparation of XML files for setting up the processing chain. Check tsinsar/tsxml.py for details on the parameters.')
    parser.parse_args()


parse()
g = ts.TSXML('data')
g.prepare_data_xml(['image.PRM', 'exampleimage.grd'], proc='GMT',xlim=None,ylim=None,rxlim=[500,540],rylim=[540,580],latfile='lat_orig.grd',lonfile='lon_orig.grd',hgtfile='dem_orig.grd',inc=43,cohth=0.01,demfmt='GRD',chgendian='False',masktype='',unwfmt='GRD',corfmt='GRD')
g.writexml('data.xml')


g = ts.TSXML('params')
g.prepare_sbas_xml(nvalid=30,netramp=True,atmos='ECMWF',demerr=False,uwcheck=False,regu=True,filt=0.5)
g.writexml('sbas.xml')


############################################################
# Program is part of GIAnT v1.0                            #
# Copyright 2012, by the California Institute of Technology#
# Contact: earthdef@gps.caltech.edu                        #
############################################################
