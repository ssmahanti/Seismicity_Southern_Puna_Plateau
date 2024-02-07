#This is a test script to check which events are selected as plateau events

gmt gmtset MAP_FRAME_TYPE="plain"
gmt gmtset PAPER_MEDIA = A4
gmt gmtset FONT_ANNOT_PRIMARY = 12p,Helvetica,black
gmt gmtset FONT_LABEL		= 12p

bound_map="-R-69.5/-65.3/-28.5/-25"
proj_map="-JM6i"

#filepaths
stationpath="/Users/sankha/Desktop/research/Spuna_plateau/station"
plotdatapath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/plotdata"
grdpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/grdfiles"
cptpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/cptfiles"

#change filename as required
output="eventmap_elev.ps"

#cptfiles
gmt makecpt -T0/35/5 -Chot -D -I > dep.cpt

#############plot of basemap and topography#######################################################
bmap="-Ba1f.5:""::,:/a1f.5:""::,:WeSn"

gmt psbasemap  $proj_map $bound_map $bmap -P -K > $output
gmt grdgradient $grdpath/dem_puna_resamp.grd -Nt1 -A75 -Gtemp_puna.grd
gmt grdimage $grdpath/dem_puna_resamp.grd -Itemp_puna.grd -C$cptpath/white2.cpt $bound_map $proj_map  -O -K -t25 >> $output

##Stations and volcanoes
awk '{print $1,$2}' $stationpath/spuna_stations.txt | gmt psxy $proj_map $bound_map -Sd0.22 -Gcyan -W0.4p,black -O -K >>$output
awk '{print $2,$1}' $plotdatapath/holocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.3 -W0.2p,black -Gmagenta -O -K >>$output
awk '{print $2,$1}' $plotdatapath/pliestocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.3 -W0.2p,black -Gmagenta -O -K >>$output

#plot events
awk '{ if ($4>3000 && $2<-66.3 && $2>-68.5 && $1>-27.0 ) print $2,$1,$3}' catalog_velest_puna_elev_v5.txt| gmt psxy $proj_map $bound_map -Sc0.15 -W0.2p -Cdep.cpt -O  -K >>$output


gmt gmtset FONT_ANNOT_PRIMARY = 9p,Helvetica,black
gmt gmtset FONT_LABEL		= 9p
gmt psscale -D0.2/1.1+w4.5/0.3+h -Cdep.cpt -Ba5+l"Depth (km)" -O >> $output

gmt psconvert -Tg -A -E500 $output
gmt psconvert -Tf -A -E500 $output

######################################end of map plot####################################################################
rm  *.xz *.xy *.cpt *.grd *.ps