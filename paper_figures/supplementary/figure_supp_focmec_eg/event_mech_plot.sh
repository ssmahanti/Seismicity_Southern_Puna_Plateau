#Script to plot the map

gmt gmtset MAP_FRAME_TYPE="plain"
gmt gmtset PAPER_MEDIA = A4
gmt gmtset FONT_ANNOT_PRIMARY = 12p,Helvetica,black
gmt gmtset FONT_LABEL		= 12p

##############################event map##################################################


bound_map="-R-69.5/-65.5/-28.5/-25"
proj_map="-JM6i"

#filepaths
stationpath="/Users/sankha/Desktop/research/Spuna_plateau/station"
plotdatapath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/plotdata"
grdpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/grdfiles"
cptpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/cptfiles"

#change filename as required
output="eventmap.ps"

#cptfiles
gmt makecpt -T0/5500/50 -D -C$cptpath/natural.cpt > topo2.cpt

#############plot of basemap and topography#######################################################
bmap="-Ba1f.5:""::,:/a1f.5:""::,:WeSn"

gmt psbasemap  $proj_map $bound_map $bmap -P -K > $output
gmt grdgradient $grdpath/dem_puna_resamp.grd -Nt1 -A75 -Gtemp_puna.grd
gmt grdimage $grdpath/dem_puna_resamp.grd -Itemp_puna.grd -Ctopo2.cpt $bound_map $proj_map  -O -K -t25>> $output

##Stations and volcanoes
awk '{print $1,$2}' $stationpath/spuna_stations.txt | gmt psxy $proj_map $bound_map -Sd0.4 -Gcyan -W0.2p,black -O -K >>$output
awk '{print $2,$1}' $plotdatapath/holocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.4 -W0.2p,black -Gmagenta -O -K >>$output
awk '{print $2,$1}' $plotdatapath/pliestocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.4 -W0.2p,black -Gmagenta -O -K >>$output

#event location
echo "-67.541 -26.484" | gmt psxy $proj_map $bound_map -Sa0.95 -W0.1p -Gred -O   >>$output

gmt psconvert -Tg -A1  -E400 $output

rm *.grd *.cpt *.txt *.ps