#!/bin/csh

# This code was written by Kriztina Kelevitz and Brie Corsa
# To reference/cite, please refer to:
# 1. Kelevitz, K., Tiampo, K., Corsa, B. Improved Real-Time Natural Hazard Monitoring Automated DInSAR Time Series. 
# Remote Sensing 2021, 13(5), 867. https://doi.org/10.3390/rs13050867
# 2. Corsa, B., Barba-Sevilla, M., Tiampo, K., Meertens, C. Integration of DInSAR time series and GNSS Data for continuous volcanic 
# deformation monitoring and eruption early warning applications. Remote Sens. 2022, 14, 784. https://doi.org/10.3390/rs14030784


#-----SBATCH arguments
#SBATCH -A  #ALLOCATION_NAME

echo "Beginning F2_intf_stage_2"

set i = 1

set intf_no = `wc intf.in | awk '{print $1}'`

rm -f F2_id.txt

while ($i <= $intf_no)

        sed -n $i,$i'p' intf.in > $i.input.in
        sbatch --time=24:00:00 --job-name=F2.intf.$i ./kk_intf_tops.csh $i.input.in batch_tops_stage2.config >>& F2_id.txt
        @ i = ($i + 1)
end

echo intf2 tops stage 2 submitted

set F2_intf_dependency_stage2_tmp = `paste F2_id.txt | awk '{print $4 ","}' | paste -s | sed s'/.$//'`
set F2_intf_dependency_stage2 = `echo $F2_intf_dependency_stage2_tmp | sed 's/ //g'`


#echo $F2_intf_dependency_stage2 > F2_dependency

cd ..

sbatch --time=24:00:00 --dependency=afterok:$F2_intf_dependency_stage2 022_break.csh >& merge_id_2.txt

#set merge_dependency_2 =`paste merge_id_2.txt | awk '{print $4}'`

