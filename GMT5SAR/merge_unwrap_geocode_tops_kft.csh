#!/bin/csh -f
#       $Id$

# This code was written by Kriztina Kelevitz and Brie Corsa
# To reference/cite, please refer to:
# 1. Kelevitz, K., Tiampo, K., Corsa, B. Improved Real-Time Natural Hazard Monitoring Automated DInSAR Time Series. 
# Remote Sensing 2021, 13(5), 867. https://doi.org/10.3390/rs13050867
# 2. Corsa, B., Barba-Sevilla, M., Tiampo, K., Meertens, C. Integration of DInSAR time series and GNSS Data for continuous volcanic 
# deformation monitoring and eruption early warning applications. Remote Sens. 2022, 14, 784. https://doi.org/10.3390/rs14030784

#
# ----- BATCH arguments
#SBATCH -A #ALLOCATION_NAME
#SBATCH --ntasks=4
#SBATCH --partition=shas
#SBATCH --time=24:00:00
#
#    Xiaohua(Eric) XU, July 7, 2016
#
# Script for merging 3 subswaths TOPS interferograms and then unwrap and geocode. 
#
  if ($#argv != 2) then
    echo ""
    echo "Usage: merge_unwrap_geocode_tops.csh inputfile config_file"
    echo ""
    echo "Note: Inputfiles should be as following:"
    echo ""
    echo "      Swath1_Path:Swath1_repeat.PRM"
    echo "      Swath2_Path:Swath2_repeat.PRM"
    echo "      Swath3_Path:Swath3_repeat.PRM"
    echo "      (Use the repeat PRM which contains the shift information.)"
    echo "      e.g. ../F1/intf/2015016_2015030/:S1A20151012_134357_F1.PRM"
    echo ""
    echo "      Make sure under each path, the processed phasefilt.grd, corr.grd and mask.grd exist."
    echo "      Also make sure the dem.grd is linked. "
    echo ""
    echo "      config_file is the same one used for processing."
    echo ""
    echo "Example: merge_unwrap_geocode_tops.csh filelist batch.config"
    echo ""
    exit 1
  endif

  if (-f tmp_phaselist) rm tmp_phaselist
  if (-f tmp_displaylist) rm tmp_displaylist
  if (-f tmp_corrlist) rm tmp_corrlist
  if (-f tmp_masklist) rm tmp_masklist
  if (-f tmp_phgrdlist) rm tmp_phgrdlist
  if (-f trans.dat) rm trans.dat
  if (-f landmask_ra.grd) rm landmask_ra.grd

  if (! -f dem.grd ) then
    echo "Please link dem.grd to current folder"
    exit 1
  endif

  # Creating inputfiles for merging
  foreach line (`awk '{print $0}' $1`)
    set pth = `echo $line | awk -F: '{print $1}'`
    set prm = `echo $line | awk -F: '{print $2}'`
    echo $pth$prm":"$pth"phasefilt.grd" >> tmp_phaselist
    echo $pth$prm":"$pth"corr.grd" >> tmp_corrlist
    echo $pth$prm":"$pth"mask.grd" >> tmp_masklist
    echo $pth$prm":"$pth"display_amp.grd" >> tmp_displaylist
    echo $pth$prm":"$pth"phase.grd" >> tmp_phgrdlist
  end 

  set pth = `awk -F: 'NR==1 {print $1}' $1`
  set stem = `awk -F: 'NR==1 {print $2}' $1 | awk -F"." '{print $1}'`
  echo $pth $stem
  cp $pth$stem".LED" .

  echo ""
  echo "Merging START"
  merge_swath tmp_phaselist phasefilt.grd $stem
  merge_swath tmp_phgrdlist phase.grd
  merge_swath tmp_corrlist corr.grd
  merge_swath tmp_masklist mask.grd
  merge_swath tmp_displaylist display_amp.grd
  echo "Merging END"
  echo ""
  
  # This step is essential, cut the DEM so it can run faster.
  if (! -f trans.dat) then
  echo "Recomputing the projection LUT..."
    gmt grd2xyz --FORMAT_FLOAT_OUT=%lf dem.grd -s | SAT_llt2rat $stem".PRM" 1 -bod > trans.dat
  endif

  # Read in parameters
  set threshold_snaphu = `grep threshold_snaphu $2 | awk '{print $3}'`
  set threshold_geocode = `grep threshold_geocode $2 | awk '{print $3}'`
  set region_cut = `grep region_cut $2 | awk '{print $3}'`
  set switch_land = `grep switch_land $2 | awk '{print $3}'`
  set defomax = `grep defomax $2 | awk '{print $3}'`

  # Unwrapping
  if ($region_cut == "") then
    set region_cut = `gmt grdinfo phasefilt.grd -I- | cut -c3-20`
  endif
  if ($threshold_snaphu != 0 ) then
    if ($switch_land == 1) then
      if (! -f landmask_ra.grd) then
        landmask.csh $region_cut
      endif
    endif

    echo ""
    echo "SNAPHU.CSH - START"
    echo "threshold_snaphu: $threshold_snaphu"
    snaphu.csh $threshold_snaphu $defomax $region_cut
    echo "SNAPHU.CSH - END"
  else
    echo ""
    echo "SKIP UNWRAP PHASE"
  endif

  # Geocoding 
  #if (-f raln.grd) rm raln.grd
  #if (-f ralt.grd) rm ralt.grd
 
  if ($threshold_geocode != 0) then
    echo ""
    echo "GEOCODE-START"
    proj_ra2ll.csh trans.dat phasefilt.grd phasefilt_ll.grd
    proj_ra2ll.csh trans.dat corr.grd corr_ll.grd
    gmt makecpt -T-3.15/3.15/0.05 -Z > phase.cpt
    set BT = `gmt grdinfo -C corr.grd | awk '{print $7}'`
    gmt makecpt -Cgray -T0/$BT/0.05 -Z > corr.cpt
    grd2kml.csh phasefilt_ll phase.cpt
    grd2kml.csh corr_ll corr.cpt

    if (-f unwrap.grd) then
      gmt grdmath unwrap.grd mask.grd MUL = unwrap_mask.grd
      proj_ra2ll.csh trans.dat unwrap.grd unwrap_ll.grd
      proj_ra2ll.csh trans.dat unwrap_mask.grd unwrap_mask_ll.grd
      set BT = `gmt grdinfo -C unwrap.grd | awk '{print $7}'`
      set BL = `gmt grdinfo -C unwrap.grd | awk '{print $6}'`
      gmt makecpt -T$BL/$BT/0.5 -Z > unwrap.cpt
      grd2kml.csh unwrap_mask_ll unwrap.cpt
      grd2kml.csh unwrap_ll unwrap.cpt
    endif
    
    echo "GEOCODE END"
  endif 

  rm tmp* *.eps *.bb
