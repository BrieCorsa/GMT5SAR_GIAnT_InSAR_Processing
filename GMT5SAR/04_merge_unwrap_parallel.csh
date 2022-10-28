#!/bin/csh


# This code was written by Kriztina Kelevitz and Brie Corsa
# To reference/cite, please refer to:
# 1. Kelevitz, K., Tiampo, K., Corsa, B. Improved Real-Time Natural Hazard Monitoring Automated DInSAR Time Series. 
# Remote Sensing 2021, 13(5), 867. https://doi.org/10.3390/rs13050867
# 2. Corsa, B., Barba-Sevilla, M., Tiampo, K., Meertens, C. Integration of DInSAR time series and GNSS Data for continuous volcanic 
# deformation monitoring and eruption early warning applications. Remote Sens. 2022, 14, 784. https://doi.org/10.3390/rs14030784


# ----- BATCH arguments
#SBATCH -A #ALLOCATION_NAME
#SBATCH --ntasks=4
#SBATCH --partition=shas

cd merge

cp ../../base/batch_tops.config .

set master = `grep master_i ../F1/batch_tops_stage1.config | awk '{print substr($3,4,8)}'`
echo $master

sed -i '/master_image/c\master_image = S1A'$master'_ALL_F1' batch_tops.config


ls -d ../F1/intf_all/* > F1_directory_list
ls -d ../F2/intf_all/* > F2_directory_list
ls -d ../F3/intf_all/* > F3_directory_list

rm -f F1_master_slave
rm -f F2_master_slave
rm -f F3_master_slave

rm -f merge_list

foreach directory ("`cat F1_directory_list`")

        ls $directory/*PRM | sed "s|../\w*/\w*/\w*/\(\w*\)|\1|" > F1_master_slave_tmp   
        paste -sd" " F1_master_slave_tmp | awk '{print $1,$2}' >> F1_master_slave
        
end

foreach directory ("`cat F2_directory_list`")

        ls $directory/*PRM | sed "s|../\w*/\w*/\w*/\(\w*\)|\1|" > F2_master_slave_tmp
        paste -sd" " F2_master_slave_tmp | awk '{print $1,$2}' >> F2_master_slave
end

foreach directory ("`cat F3_directory_list`")

        ls $directory/*PRM | sed "s|../\w*/\w*/\w*/\(\w*\)|\1|" > F3_master_slave_tmp
        paste -sd" " F3_master_slave_tmp | awk '{print $1,$2}' >> F3_master_slave
end

paste F1_directory_list F1_master_slave F2_directory_list F2_master_slave F3_directory_list F3_master_slave > tmp

foreach line ("`cat tmp`")

        set F1dir = `echo $line | awk '{print $1}'`
        set F1file1 = `echo $line | awk '{print $2}'`
        set F1file2 = `echo $line | awk '{print $3}'`

        set F2dir = `echo $line | awk '{print $4}'`
        set F2file1 = `echo $line | awk '{print $5}'`
        set F2file2 = `echo $line | awk '{print $6}'`

        set F3dir = `echo $line | awk '{print $7}'`
        set F3file1 = `echo $line | awk '{print $8}'`
        set F3file2 = `echo $line | awk '{print $9}'`

        echo $F1dir'/:'$F1file1':'$F1file2','$F2dir'/:'$F2file1':'$F2file2','$F3dir'/:'$F3file1':'$F3file2 >> merge_list
end

set for_grdinfo = `head -1 F1_directory_list`

rm tmp
rm *tmp
rm *_master_slave
rm *_directory_list

cp ../../base/merge_batch.csh .
cp ../../base/update* .

cp ../topo/dem.grd .

set merge_no = `wc merge_list | awk '{print $1}'`

set i = 1

while ($i <= $merge_no)

	sed -n $i,$i'p' merge_list > $i.merge.input

	sbatch --ntasks=4 --time=24:00:00 --job-name=$i.merge ./merge_batch.csh $i.merge.input batch_tops.config
	@ i = ($i + 1)

end

