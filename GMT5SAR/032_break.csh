#!/bin/csh


# This code was written by Kriztina Kelevitz and Brie Corsa
# To reference/cite, please refer to:
# 1. Kelevitz, K., Tiampo, K., Corsa, B. Improved Real-Time Natural Hazard Monitoring Automated DInSAR Time Series. 
# Remote Sensing 2021, 13(5), 867. https://doi.org/10.3390/rs13050867
# 2. Corsa, B., Barba-Sevilla, M., Tiampo, K., Meertens, C. Integration of DInSAR time series and GNSS Data for continuous volcanic 
# deformation monitoring and eruption early warning applications. Remote Sens. 2022, 14, 784. https://doi.org/10.3390/rs14030784


#-----SBATCH arguments
#SBATCH -A #ALLOCATION_NAME

echo F3 finished > F3_finish

if ( -f F1_finish ) then
	if ( -f F2_finish ) then
		if ( -f F3_finish) then

		sbatch --time=24:00:00 ./04_merge_unwrap_parallel.csh

		endif
	endif
endif


