# This code was written by Kriztina Kelevitz and Brie Corsa
# To reference, please refer to:

# 1. Kelevitz, K., Tiampo, K., Corsa, B. Improved Real-Time Natural Hazard Monitoring Automated DInSAR Time Series.
# Remote Sensing 2021, 13(5), 867. https://doi.org/10.3390/rs13050867
# 2. Corsa, B., Barba-Sevilla, M., Tiampo, K., Meertens, C. Integration of DInSAR time series and GNSS Data for continuous volcanic 
# deformation monitoring and eruption early warning applications. Remote Sens. 2022, 14, 784. https://doi.org/10.3390/rs14030784



clear all
close all
format long g
% create the latitude and longitude grid file for geocoded data in giant
%20100321-20071029.unw.grd: x_min: -70.7 x_max: -70.2 x_inc: 0.000555555555556 name: longitude [degrees_east] nx: 900
%20100321-20071029.unw.grd: y_min: -36.25 y_max: -35.7666666667 y_inc: 0.000555555555517 name: latitude [degrees_north] ny: 870
%20100321-20071029.unw.grd: z_min: -31.3350830078 z_max: 10.0585575104 name: radians
 %NEW
 %data/20100203-20070126.unw.grd: x_min: -70.7 x_max: -70.2 x_inc: 0.000555555555556 name: longitude [degrees_east] nx: 900
%data/20100203-20070126.unw.grd: y_min: -36.25 y_max: -35.78 y_inc: 0.000555555555556 name: latitude [degrees_north] ny: 846

% xmin=-110.888888889;
% xmax=-107.6;
% xinc=0.00111111111115;
% ymin=43.9555555525;
% ymax=45.2444444413;
% yinc=0.00111111111103;

%% Kilauea DEM
xmin=-157.7;
xmax=-153.8;
xinc=0.000833333333333;
ymin=17.5;
ymax=21.4;
yinc=0.000833333333333;

%% ALOS T113
%xmin=-70.7997222222;
%ymax=-35.7402777778;
%xmax=-70.3902777778;
%ymin=-36.2997222222;

%% TSX T111
%xmin=-70.6997222222;
%ymax=-35.9402777778;
%xmax=-70.2702777778;
%ymin=-36.2597222222;

%% TSX T119
%xmin=-70.6697222222;
%ymax=-35.9202777778;
%xmax=-70.2702777778;
%ymin=-36.2997222222;

%% TSX T28
%xmin=-70.6997222222;
%ymax=-35.9302777778;
%xmax=-70.4063888889; 
%ymin=-36.3097222222;

xvec=xmin:xinc:xmax+xinc;
yvec=ymin:yinc:ymax+yinc;
z=zeros(length(yvec),length(xvec));

for i=1:length(xvec)
    for j=1:length(yvec)
zlat(j,i)=yvec(j);
zlon(j,i)=xvec(i);
    end
end

% ALOS T112
grdwrite2(xvec,yvec,zlat,'lat_orig.grd')
grdwrite2(xvec,yvec,zlon,'lon_orig.grd')

%grdsample lat_orig.grd -Glat.grd -Rexampleimage.grd
%grdsample lon_orig.grd -Glon.grd -Rexampleimage.grd
%grdsample dem_orig.grd -Gdem.grd -Rexampleimage.grd

% ALOS T113
%grdwrite2(xvec,yvec,zlat,'/Users/hlemevel/giant/GIAnT/LdM/ALOS/T113/geo/lat.grd')
%grdwrite2(xvec,yvec,zlon,'/Users/hlemevel/giant/GIAnT/LdM/ALOS/T113/geo/lon.grd')

%TSX T111
%grdwrite2(xvec,yvec,zlat,'/Users/hlemevel/giant/GIAnT/LdM/TSX/T111/geo/lat.grd')
%grdwrite2(xvec,yvec,zlon,'/Users/hlemevel/giant/GIAnT/LdM/TSX/T111/geo/lon.grd')

%TSX T119
%grdwrite2(xvec,yvec,zlat,'/Users/hlemevel/giant/GIAnT/LdM/TSX/T119/geo/lat.grd')
%grdwrite2(xvec,yvec,zlon,'/Users/hlemevel/giant/GIAnT/LdM/TSX/T119/geo/lon.grd')

% TSX T28
%grdwrite2(xvec,yvec,zlat,'/Users/hlemevel/giant/GIAnT/LdM/TSX/T28/geo/lat.grd')
%grdwrite2(xvec,yvec,zlon,'/Users/hlemevel/giant/GIAnT/LdM/TSX/T28/geo/lon.grd')
