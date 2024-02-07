#Plotting script for Figure 3: Run separately for this study and Mulcahy et al., 2014 catalog:

GMT_COMPATIBILITY=5
gmt gmtset MAP_FRAME_TYPE="plain"
gmt gmtset PAPER_MEDIA = A4
gmt gmtset FONT_ANNOT_PRIMARY = 12p,Helvetica,black
gmt gmtset FONT_LABEL		= 12p

#filepaths
eventpath_velest="/Users/sankha/Desktop/research/Spuna_plateau/velest/output"
stationpath="/Users/sankha/Desktop/research/Spuna_plateau/station"
plotdatapath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/plotdata"
grdpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/grdfiles"
cptpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/cptfiles"

#change filename as required
output="eventmap_thisstudy.ps"

#cptfiles
gmt makecpt -T0/35/5 -Chot -D -I > dep.cpt

#############plot of basemap and topography#######################################################
bound_map="-R-69.5/-65.3/-28.5/-25"
proj_map="-JM6i"
bmap="-Ba1f.5:""::,:/a1f.5:""::,:WeSn"

gmt psbasemap  $proj_map $bound_map $bmap -P -K > $output
gmt grdgradient $grdpath/dem_puna_resamp.grd -Nt1 -A75 -Gtemp_puna.grd
gmt grdimage $grdpath/dem_puna_resamp.grd -Itemp_puna.grd -C$cptpath/white2.cpt $bound_map $proj_map  -O -K -t25 >> $output

##Stations and volcanoes
awk '{print $1,$2}' $stationpath/spuna_stations.txt | gmt psxy $proj_map $bound_map -Sd0.22 -Gcyan -W0.4p,black -O -K >>$output
awk '{print $2,$1}' $plotdatapath/holocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.3 -W0.25p,black -Gmagenta -O -K >>$output
awk '{print $2,$1}' $plotdatapath/pliestocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.3 -W0.25p,black -Gmagenta -O -K >>$output

#plot events
awk '{print $8,$7,$9}' $eventpath_velest/catalog_velest_puna_crust_v5.txt| gmt psxy $proj_map $bound_map -Sc0.15 -W0.2p -Cdep.cpt -O  -K >>$output
#gmt psxy $plotdatapath/mulcahy_catalog.txt $proj_map $bound_map -Sc0.18 -W0.2p -Cdep.cpt -O  -K -: >>$output

#white box
gmt psxy  $proj_map $bound_map -W0.7,black -Gwhite -O -K << EOF >> $output
-69.5 -28.1
-69.5 -28.5
-68.1 -28.5
-68.1 -28.1
-69.5 -28.1
EOF

#color scale
gmt gmtset FONT_ANNOT_PRIMARY = 10p,Helvetica,black
gmt gmtset FONT_LABEL		= 10p
gmt psscale -D0.2/1.1+w4.5/0.3+h -Cdep.cpt -Ba5+l"Depth (km)" -O -K >> $output

#map scale
gmt gmtset FONT_ANNOT_PRIMARY = 9p,Helvetica,black
gmt gmtset FONT_LABEL		= 9p
gmt gmtset MAP_ANNOT_OFFSET=2p
gmt gmtset MAP_LABEL_OFFSET=1p
gmt psbasemap  $proj_map $bound_map  -LjTR+c27S+w40k+l+ab+f+o0.5c -P  -O >> $output

gmt psconvert -Tg -A -E500 $output
gmt psconvert -Tf -A -E500 $output

rm *.cpt *.grd *.ps *.txt
