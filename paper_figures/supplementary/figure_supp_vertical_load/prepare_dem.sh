#This script prepares .xyz DEM files needed for vertical load comparison

#Bound the required area
bound_map="-R-68.5/-65.5/-27.0/-25.0"

grdpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/grdfiles"
gmt grdcut $grdpath/dem_puna.grd -Gdem_north.grd $bound_map #Cut by bounding box
gmt grdsample dem_north.grd -I.1m -Gdem_north_resamp.grd #Downsample
gmt grd2xyz dem_north_resamp.grd > dem_north_resamp.xyz #Convert to .xyz format