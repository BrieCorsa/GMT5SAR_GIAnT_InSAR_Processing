#!/bin/csh

# This code was written by Kriztina Kelevitz and Brie Corsa
# To reference, please refer to: 

# 1. Kelevitz, K., Tiampo, K., Corsa, B. Improved Real-Time Natural Hazard Monitoring Automated DInSAR Time Series. 
# Remote Sensing 2021, 13(5), 867. https://doi.org/10.3390/rs13050867
# 2. Corsa, B., Barba-Sevilla, M., Tiampo, K., Meertens, C. Integration of DInSAR time series and GNSS Data for continuous volcanic 
# deformation monitoring and eruption early warning applications. Remote Sens. 2022, 14, 784. https://doi.org/10.3390/rs14030784

set master = 
#set master = YYYYMMDD_YYYYMMDD

ls -d 20*20* > intflist

foreach directory ("`cat intflist`")

	cd $directory

	echo $directory

	cp ../$master/unwrap_ll.grd reference_unw.grd
	cp ../$master/corr_ll.grd reference_corr.grd

	gmt grdcut unwrap_ll.grd -Gunwrap_ll_cut.grd -Rreference_unw.grd
        gmt grdcut corr_ll.grd -Gcorr_ll_cut.grd -Rreference_unw.grd	

        nccopy -k classic unwrap_ll_cut.grd unwrap_ll_c_cut.grd
        nccopy -k classic corr_ll_cut.grd corr_ll_c_cut.grd


	cd ..

end
