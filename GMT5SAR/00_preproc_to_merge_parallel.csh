#!/bin/tcsh

# This code was written by Kriztina Kelevitz and Brie Corsa
# To reference/cite, please refer to:
# 1. Kelevitz, K., Tiampo, K., Corsa, B. Improved Real-Time Natural Hazard Monitoring Automated DInSAR Time Series. 
# Remote Sensing 2021, 13(5), 867. https://doi.org/10.3390/rs13050867
# 2. Corsa, B., Barba-Sevilla, M., Tiampo, K., Meertens, C. Integration of DInSAR time series and GNSS Data for continuous volcanic 
# deformation monitoring and eruption early warning applications. Remote Sens. 2022, 14, 784. https://doi.org/10.3390/rs14030784


#-----SBATCH Arguments
#SBATCH -A   #ALLOCATION_NAME

set master = $1
set allowed_days = $2

set master_next_date=`date -d "$master 1 day" +%Y%m%d`
echo master_next_date $master_next_date

set master_prev_date=`date -d "$master -1 day" +%Y%m%d`
echo master_prev_date $master_prev_date

###################### F1 processing ############################

cd F1/raw
rm -f data.in.*

echo "Beginning F1 Processing"

cp ../../../base/kk_preproc_batch_tops.csh .

set scene_no = `wc ../../list_of_acquisitions | awk '{print $1}'`

set i = 1

foreach acquisition ("`cat ../../list_of_acquisitions`")

	set filename=`ls *iw1*vh*$master*tiff | sed -e 's/\.tiff//'`
	set orbit=`ls *$master_prev_date*$master_next_date*EOF`

	echo $filename':'$orbit > data.in.$i

	set filename=`ls *iw1*vh*$acquisition*tiff | sed -e 's/\.tiff//'`

	set acquisition_next_date=`date -d "$acquisition 1 day" +%Y%m%d`
	set acquisition_prev_date=`date -d "$acquisition -1 day" +%Y%m%d`

	set orbit=`ls *$acquisition_prev_date*$acquisition_next_date*EOF`

	echo $filename':'$orbit >> data.in.$i

	@ i = ($i + 1)

end


rm -f F1_id.txt

set i = 1

while ($i <= $scene_no)

	mkdir tmp.$i

	cd tmp.$i

	ln -s ../* .

        sbatch --job-name=1prep.$i ./kk_preproc_batch_tops.csh data.in.$i dem.grd 2 >>& ../F1_id.txt
        @ i = ($i + 1)

	cd ..

end

echo prep submitted

set F1_prep_dependency_tmp = `paste F1_id.txt | awk '{print $4 ","}'| paste -s | sed s'/.$//'`
set F1_prep_dependency = `echo $F1_prep_dependency_tmp | sed 's/ //g'`

echo $F1_prep_dependency

cd ..

sed -i '/master_image/c\master_image = S1A'$master'_ALL_F1' batch_tops_stage1.config
sed -i '/master_image/c\master_image = S1A'$master'_ALL_F1' batch_tops_stage2.config

cp ../../base/select_pairs.csh .
cp ../../base/kk_intf_tops.csh .

rm -f F1_id.txt

sbatch --dependency=afterok:$F1_prep_dependency ./select_pairs.csh baseline_table.dat $allowed_days 200 >& F1_id.txt

echo select pairs submitted

set F1_baseline_dependency = `paste F1_id.txt | awk '{print $4}'`

rm -f F1_id.txt

sbatch --time=24:00:00 --dependency=afterok:$F1_baseline_dependency ./kk_intf_tops.csh one.in batch_tops_stage1.config >& F1_id.txt

echo intf1 tops stage 1 submitted

set F1_intf_dependency = `paste F1_id.txt | awk '{print $4}'`

cp ../011_F1_intf_stage2.csh .

rm -f F1_id.txt

sbatch --dependency=afterok:$F1_intf_dependency ./011_F1_intf_stage2.csh >& F1_id.txt

set F1_intf_stage_2_dependency = `paste F1_id.txt | awk '{print $4}'`

echo $F1_intf_stage_2_dependency

cd ..


##################################### F2 processing ###########################
cd F2/raw
rm -f data.in.*

echo "Beginning F2 Processing"

cp ../../../base/kk_preproc_batch_tops.csh .

set scene_no = `wc ../../list_of_acquisitions | awk '{print $1}'`

set i = 1

foreach acquisition ("`cat ../../list_of_acquisitions`")

        set filename=`ls *iw2*vh*$master*tiff | sed -e 's/\.tiff//'`
        set orbit=`ls *$master_prev_date*$master_next_date*EOF`

        echo $filename':'$orbit > data.in.$i

        set filename=`ls *iw2*vh*$acquisition*tiff | sed -e 's/\.tiff//'`

        set acquisition_next_date=`date -d "$acquisition 1 day" +%Y%m%d`
        set acquisition_prev_date=`date -d "$acquisition -1 day" +%Y%m%d`

        set orbit=`ls *$acquisition_prev_date*$acquisition_next_date*EOF`

        echo $filename':'$orbit >> data.in.$i

        @ i = ($i + 1)

end


rm -f F2_id.txt

set i = 1

while ($i <= $scene_no)

        mkdir tmp.$i

        cd tmp.$i

        ln -s ../* .

        sbatch --job-name=2prep.$i ./kk_preproc_batch_tops.csh data.in.$i dem.grd 2 >>& ../F2_id.txt
        @ i = ($i + 1)

	cd ..

end

echo prep submitted

set F2_prep_dependency_tmp = `paste F2_id.txt | awk '{print $4 ","}'| paste -s | sed s'/.$//'`
set F2_prep_dependency = `echo $F2_prep_dependency_tmp | sed 's/ //g'`

echo $F2_prep_dependency

cd ..

sed -i '/master_image/c\master_image = S1A'$master'_ALL_F2' batch_tops_stage1.config
sed -i '/master_image/c\master_image = S1A'$master'_ALL_F2' batch_tops_stage2.config

cp ../../base/select_pairs.csh .
cp ../../base/kk_intf_tops.csh .

rm -f F2_id.txt

sbatch --dependency=afterok:$F2_prep_dependency ./select_pairs.csh baseline_table.dat $allowed_days 200 >& F2_id.txt

echo select pairs submitted

set F2_baseline_dependency = `paste F2_id.txt | awk '{print $4}'`

rm -f F2_id.txt

sbatch --time=24:00:00 --dependency=afterok:$F2_baseline_dependency ./kk_intf_tops.csh one.in batch_tops_stage1.config >& F2_id.txt

echo intf2 tops stage 1 submitted

set F2_intf_dependency = `paste F2_id.txt | awk '{print $4}'`

cp ../021_F2_intf_stage2.csh .

rm -f F2_id.txt

sbatch --dependency=afterok:$F2_intf_dependency ./021_F2_intf_stage2.csh >& F2_id.txt

set F2_intf_stage_2_dependency = `paste F2_id.txt | awk '{print $4}'`

echo $F2_intf_stage_2_dependency

cd ..


########################### F3 processing ########################

cd F3/raw
rm -f data.in.*

echo "Beginning F3 Processing"

cp ../../../base/kk_preproc_batch_tops.csh .

set scene_no = `wc ../../list_of_acquisitions | awk '{print $1}'`

set i = 1

foreach acquisition ("`cat ../../list_of_acquisitions`")

        set filename=`ls *iw3*vh*$master*tiff | sed -e 's/\.tiff//'`
        set orbit=`ls *$master_prev_date*$master_next_date*EOF`

        echo $filename':'$orbit > data.in.$i

        set filename=`ls *iw3*vh*$acquisition*tiff | sed -e 's/\.tiff//'`

        set acquisition_next_date=`date -d "$acquisition 1 day" +%Y%m%d`
        set acquisition_prev_date=`date -d "$acquisition -1 day" +%Y%m%d`

        set orbit=`ls *$acquisition_prev_date*$acquisition_next_date*EOF`

        echo $filename':'$orbit >> data.in.$i

        @ i = ($i + 1)

end


rm -f F3_id.txt

set i = 1

while ($i <= $scene_no)

        mkdir tmp.$i

        cd tmp.$i

        ln -s ../* .

        sbatch --job-name=3prep.$i ./kk_preproc_batch_tops.csh data.in.$i dem.grd 2 >>& ../F3_id.txt
        @ i = ($i + 1)

	cd ..
	
end

echo prep submitted

set F3_prep_dependency_tmp = `paste F3_id.txt | awk '{print $4 ","}'| paste -s | sed s'/.$//'`
set F3_prep_dependency = `echo $F3_prep_dependency_tmp | sed 's/ //g'`

cd ..

sed -i '/master_image/c\master_image = S1A'$master'_ALL_F3' batch_tops_stage1.config
sed -i '/master_image/c\master_image = S1A'$master'_ALL_F3' batch_tops_stage2.config

cp ../../base/select_pairs.csh .
cp ../../base/kk_intf_tops.csh .

rm -f F3_id.txt

sbatch --dependency=afterok:$F3_prep_dependency ./select_pairs.csh baseline_table.dat $allowed_days 200 >& F3_id.txt

echo select pairs submitted

set F3_baseline_dependency = `paste F3_id.txt | awk '{print $4}'`

echo F3_baseline_dependency $F3_baseline_dependency

rm -f F3_id.txt

sbatch --time=24:00:00 --dependency=afterok:$F3_baseline_dependency ./kk_intf_tops.csh one.in batch_tops_stage1.config >& F3_id.txt

echo intf3 tops stage 1 submitted

set F3_intf_dependency = `paste F3_id.txt | awk '{print $4}'`

echo F3_intf_dependency $F3_intf_dependency

cp ../031_F3_intf_stage2.csh .

rm -f F3_id.txt

sbatch --dependency=afterok:$F3_intf_dependency ./031_F3_intf_stage2.csh >& F3_id.txt

set F3_intf_stage_2_dependency = `paste F3_id.txt | awk '{print $4}'`

echo F3_intf_stage_2_dependency $F3_intf_stage_2_dependency


####################### MERGE UNWRAP GEOCODE ###################

#rm -f merge_id.txt

#sbatch --dependency=afterok:$F1_intf_stage_2_dependency,$F2_intf_stage_2_dependency,$F3_intf_stage_2_dependency break.csh >& merge_id.txt

#set merge_dependency = `paste merge_id.txt | awk '{print $4}'`

#sbatch --dependency=afterok:$merge_dependency ./04_merge_unwrap_parallel.csh

