#!/bin/tcsh


# This code was written by Kriztina Kelevitz and Brie Corsa
# To reference/cite, please refer to:
# 1. Kelevitz, K., Tiampo, K., Corsa, B. Improved Real-Time Natural Hazard Monitoring Automated DInSAR Time Series. 
# Remote Sensing 2021, 13(5), 867. https://doi.org/10.3390/rs13050867
# 2. Corsa, B., Barba-Sevilla, M., Tiampo, K., Meertens, C. Integration of DInSAR time series and GNSS Data for continuous volcanic 
# deformation monitoring and eruption early warning applications. Remote Sens. 2022, 14, 784. https://doi.org/10.3390/rs14030784


# -----SBATCH ARGUMENTS
#SBATCH -A  #ALLOCATION_NAME
#SBATCH --ntasks-per-node=24


set Path = $1
set Frame = $2

cp ../Sentinel_Path_$Path'_Frame_'$Frame/list_of_acquisitions .

mkdir data
cd data

ln -s ../../Sentinel_Path_$Path'_Frame_'$Frame/SAFE/*.SAFE .

cd ..

mkdir orbit
cd orbit

ln -s ../../Sentinel_Path_$Path'_Frame_'$Frame/orbits/* .

cd ..

mkdir topo
cd topo

cp ../../Sentinel_Path_$Path'_Frame_'$Frame/DEM/dem.grd .

cd ..

mkdir reframed
mkdir merge
mkdir SBAS

mkdir F1
mkdir F2
mkdir F3

cd F1
mkdir raw
mkdir SLC
mkdir intf_in
mkdir topo
cp ../topo/dem.grd ./topo
cp ../../base/batch_tops_stage1.config batch_tops_stage1.config
cp ../../base/batch_tops_stage2.config batch_tops_stage2.config


cd ..

cd F2
mkdir raw
mkdir SLC
mkdir intf_in
mkdir topo
cp ../topo/dem.grd ./topo
cp ../../base/batch_tops_stage1.config batch_tops_stage1.config
cp ../../base/batch_tops_stage2.config batch_tops_stage2.config

cd ..

cd F3
mkdir raw
mkdir SLC
mkdir intf_in
mkdir topo
cp ../topo/dem.grd ./topo
cp ../../base/batch_tops_stage1.config batch_tops_stage1.config
cp ../../base/batch_tops_stage2.config batch_tops_stage2.config

cd ..

cp ./topo/dem.grd ./merge

cd F1/raw

echo F1

rm -f data.in

foreach acquisition ("`cat ../../list_of_acquisitions`")
	
	echo $acquisition

	ln -s ../../data/S*$acquisition*/measurement/*iw1*vh*$acquisition*tiff .
	set filename=`ls *iw1*vh*$acquisition*tiff | sed -e 's/\.tiff//'`

	set acquisition_next_date=`date -d "$acquisition 1 day" +%Y%m%d`
	set acquisition_prev_date=`date -d "$acquisition -1 day" +%Y%m%d`

	ln -s ../../orbit/*$acquisition_prev_date*$acquisition_next_date*EOF .
	set orbit=`ls *EOF`

	echo $filename':'$orbit >> data.in

	rm *tiff
	rm *EOF

end

ln -s ../../data/*SAFE/measurement/*iw1*vh*tiff .
ln -s ../../data/*SAFE/annotation/*iw1*vh*xml .
ln -s ../../orbit/* .
cp ../topo/dem.grd .

preproc_batch_tops.csh data.in dem.grd 1

cp baseline_table.dat ../
cp baseline.ps ../

cd ../../F2/raw

rm -f data.in

echo F2

foreach acquisition ("`cat ../../list_of_acquisitions`")

	echo $acquisition

        ln -s ../../data/S*$acquisition*/measurement/*iw2*vh*$acquisition*tiff .
        set filename=`ls *iw2*vh*$acquisition*tiff | sed -e 's/\.tiff//'`

        set acquisition_next_date=`date -d "$acquisition 1 day" +%Y%m%d`
        set acquisition_prev_date=`date -d "$acquisition -1 day" +%Y%m%d`

        ln -s ../../orbit/*$acquisition_prev_date*$acquisition_next_date*EOF .
        set orbit=`ls *EOF`

        echo $filename':'$orbit >> data.in

        rm *tiff
        rm *EOF

end

ln -s ../../data/*SAFE/measurement/*iw2*vh*tiff .
ln -s ../../data/*SAFE/annotation/*iw2*vh*xml .
ln -s ../../orbit/* .
cp ../topo/dem.grd .

preproc_batch_tops.csh data.in dem.grd 1

cp baseline_table.dat ../
cp baseline.ps ../

cd ../../F3/raw

rm -f data.in

echo F3

foreach acquisition ("`cat ../../list_of_acquisitions`")

	echo $acquisition

        ln -s ../../data/S*$acquisition*/measurement/*iw3*vh*$acquisition*tiff .
        set filename=`ls *iw3*vh*$acquisition*tiff | sed -e 's/\.tiff//'`

        set acquisition_next_date=`date -d "$acquisition 1 day" +%Y%m%d`
        set acquisition_prev_date=`date -d "$acquisition -1 day" +%Y%m%d`

        ln -s ../../orbit/*$acquisition_prev_date*$acquisition_next_date*EOF .
        set orbit=`ls *EOF`

        echo $filename':'$orbit >> data.in

        rm *tiff
        rm *EOF

end

ln -s ../../data/*SAFE/measurement/*iw3*vh*tiff .
ln -s ../../data/*SAFE/annotation/*iw3*vh*xml .
ln -s ../../orbit/* .
cp ../topo/dem.grd .

preproc_batch_tops.csh data.in dem.grd 1

cp baseline_table.dat ../
cp baseline.ps ../


