#!/bin/csh


# This code was written by Kriztina Kelevitz and Brie Corsa
# To reference/cite, please refer to:
# 1. Kelevitz, K., Tiampo, K., Corsa, B. Improved Real-Time Natural Hazard Monitoring Automated DInSAR Time Series. 
# Remote Sensing 2021, 13(5), 867. https://doi.org/10.3390/rs13050867
# 2. Corsa, B., Barba-Sevilla, M., Tiampo, K., Meertens, C. Integration of DInSAR time series and GNSS Data for continuous volcanic 
# deformation monitoring and eruption early warning applications. Remote Sens. 2022, 14, 784. https://doi.org/10.3390/rs14030784


#-----SBATCH arguments
#SBATCH -A #ALLOCATION_NAME

set Path = $1
set Frame = $2

set master = $3
set allowed_days = $4



sbatch 00_select_master.csh $Path $Frame >& 00_id.txt

set select_master_dependency = `paste 00_id.txt | awk '{print $4}'`

sbatch --dependency=afterok:$select_master_dependency 00_preproc_to_merge_parallel.csh $master $allowed_days 


