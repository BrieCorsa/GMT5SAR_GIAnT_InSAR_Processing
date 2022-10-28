######This needs to be custom written for your stacks if needed

# This code was written by Kriztina Kelevitz and Brie Corsa
# To reference, please refer to:

# 1. Kelevitz, K., Tiampo, K., Corsa, B. Improved Real-Time Natural Hazard Monitoring Automated DInSAR Time Series.
# Remote Sensing 2021, 13(5), 867. https://doi.org/10.3390/rs13050867
# 2. Corsa, B., Barba-Sevilla, M., Tiampo, K., Meertens, C. Integration of DInSAR time series and GNSS Data for continuous volcanic 
# deformation monitoring and eruption early warning applications. Remote Sens. 2022, 14, 784. https://doi.org/10.3390/rs14030784


#####Returns the path to the files.
def makefnames(dates1,dates2,sensor):
    '''Generates paths to the files needed for creating the stack.

    .. Args:

        * dates1     - Date of master 
        * dates2     - Date of slave
        * sensor     - Satellite sensor name

    .. Returns:

        * iname      - Path to the unwrapped inteferogram
        * cname      - Path to the coherence file'''
    dirname = '/net/tiampostorage/volume1/BrieShare/YellowstoneProject/Kilauea/merge'
    if sensor in ('SENTINEL-1A'):
        iname = '%s/%s_%s/unwrap_ll.grd'%(dirname,dates1,dates2)
        cname = '%s/%s_%s/corr_ll.grd'%(dirname,dates1,dates2)
    elif sensor in ('ERS'):
        iname = '%s/int_%s_%s/STACK/filt_%s-%s-sim_PRC_8rlks_c10.unw'%(dirname,dates1,dates2,dates1,dates2)
        cname = '%s/int_%s_%s/STACK/lp_filt_%s-%s-sim_PRC_8rlks_phsig.cor'%(dirname,dates1,dates2,dates1,dates2)

    else:
        print 'Unknown sensor. Check inputs.'
        sys.exit(1)

    return iname,cname

#####To use for NSBAS
#def NSBASdict():
#    '''Returns a string representation of the temporal dictionary to be used with NSBAS.'''
#    rep = [['POLY',[1],[tims[Ref]]],
#	   ['LOG'],[-2.0],[3.0]]  
#    return rep

#####To use for timefn invert / MInTS.
#def timedict():
#    '''Returns a string representation of the temporal dictionary to be used with inversions.'''
#    rep = [['ISPLINES',[3],[48]]]
#    return rep

def timedict():
    rep = [['POLY',[1],[0.0]]]
    return rep

NSBASdict = timedict
############################################################
# Program is part of GIAnT v1.0                            #
# Copyright 2012, by the California Institute of Technology#
# Contact: earthdef@gps.caltech.edu                        #
############################################################
