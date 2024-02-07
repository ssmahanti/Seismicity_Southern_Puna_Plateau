#This script extracts events adjacent to Achibarca and Culampaja lineaments:

gmt gmtset MAP_FRAME_TYPE="plain"
gmt gmtset PAPER_MEDIA = A4
gmt gmtset FONT_ANNOT_PRIMARY = 12p,Helvetica,black
gmt gmtset FONT_LABEL		= 12p

bound_map="-R-69.5/-65.5/-28.5/-25"
proj_map="-JM6i"

#filepaths
eventpath_hypodd="/Users/sankha/Desktop/research/Spuna_plateau/hypodd/output"
eventpath_mag="/Users/sankha/Desktop/research/Spuna_plateau/magnitude"

stationpath="/Users/sankha/Desktop/research/Spuna_plateau/station"
plotdatapath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/plotdata"
grdpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/grdfiles"
cptpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/cptfiles"

#change filename as required
output="map.ps"

#cptfiles
gmt makecpt -T0/35/5 -Chot -D -I > dep.cpt

#############plot of basemap and topography#######################################################
bmap="-Ba1f.5:""::,:/a1f.5:""::,:WeSn"

gmt psbasemap  $proj_map $bound_map $bmap -P -K > $output
gmt grdgradient $grdpath/dem_puna_resamp.grd -Nt1 -A75 -Gtemp_puna.grd
gmt grdimage $grdpath/dem_puna_resamp.grd -Itemp_puna.grd -C$cptpath/white2.cpt $bound_map $proj_map  -O -K -t30 >> $output


##Stations and volcanoes
awk '{print $1,$2}' $stationpath/spuna_stations.txt | gmt psxy $proj_map $bound_map -Sd0.28 -Gcyan -W0.4p,black -O -K >>$output
awk '{print $2,$1}' $plotdatapath/holocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.35 -W0.2p,black -Gmagenta -O -K >>$output
awk '{print $2,$1}' $plotdatapath/pliestocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.35 -W0.2p,black -Gmagenta -O -K >>$output

awk '{print $8,$7,$9}' $eventpath_hypodd/catalog_hypodd_puna_crust_v5.txt| gmt psxy $proj_map $bound_map -Sc0.15 -W0.4p -Cdep.cpt -O  -K >>$output

gmt gmtset FONT_ANNOT_PRIMARY = 10p,Helvetica,black
gmt gmtset FONT_LABEL		= 10p
gmt psscale -D0.2/1.3+w4.5/0.3+h -Cdep.cpt -Ba5+l"Depth-km" -O -K >> $output
#gmt psscale -D1/2+w5/0.3+h -Ctomo.cpt -Ba0.2+l"Vs (km/s)" -O -K  >> $output

echo -67.35 -25.7 "A1" >tmp_map.txt
echo -66.2 -26.50 "B1" >>tmp_map.txt
echo ">>" >> tmp_map.txt
echo -67.8 -26.4 "A2" >>tmp_map.txt
echo -66.8 -27.1 "B2" >>tmp_map.txt

gmt psxy $proj_map $bound_map tmp_map.txt -W1.0p,black   -O -K>> $output
gmt pstext $proj_map $bound_map tmp_map.txt -F+f15 -W0.7p -Gwhite -O  >> $output

gmt psconvert -Tg -A -E500 $output

######################################end of map plot####################################################################
########################################Select the events###############################
width="-20/20" #Width of box

#Cross-section 1: Achibarca lineament
A1="-67.35/-25.7"
B1="-66.20/-26.50"
#Background seismicity above Mc=1.1
awk '{ if ( $11 >= 1.1 ) print $8,$7,$9,$1,$2,$3}' $eventpath_mag/puna_catalog_hypodd_v5.txt | gmt project -C$A1 -E$B1 -Fxyzpqrs -W$width  -Lw -Q > events_achi.dat

#Cross-section 2: Culampaja Lineament
A2="-67.8/-26.4"
B2="-66.8/-27.1"
#Background seismicity above Mc=1.1
awk '{ if ( $11 >= 1.1 ) print $8,$7,$9,$1,$2,$3}' $eventpath_mag/puna_catalog_hypodd_v5.txt | gmt project -C$A2 -E$B2 -Fxyzpqrs -W$width -Lw -Q > events_culam.dat

#######################################################
echo "0 0" | gmt psxy -Sc0.001 $proj_cross $bound_cross -O   -W0.001p >> $out_cross
gmt psconvert -Tg -A -E500 $out_cross
gmt psconvert -Tf -A -E500 $out_cross

rm  *.xz *.xy *.cpt *.grd  Aa* 
rm *.ps 
