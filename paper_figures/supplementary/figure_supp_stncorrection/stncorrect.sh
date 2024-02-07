#Script for plotting station corrections

gmt gmtset MAP_FRAME_TYPE="plain"
gmt gmtset PAPER_MEDIA = A2
gmt gmtset FONT_ANNOT_PRIMARY = 12p,Helvetica,black
gmt gmtset FONT_LABEL		= 12p

#filepaths
eventpath_velest="/Users/sankha/Desktop/research/Spuna_plateau/velest/output"
stationpath="/Users/sankha/Desktop/research/Spuna_plateau/station"
plotdatapath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/plotdata"
grdpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/grdfiles"
cptpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/cptfiles"

#change filename as required
output="station_correction.ps"

#cptfiles
gmt makecpt -T-1/1/1 -Cpolar -D -I > dep.cpt

################################################plot for Vp#######################################################
bmap="-Ba1f.5:""::,:/a1f.5:""::,:WeSn"
bound_map="-R-69.5/-65.3/-28.5/-25"
proj_map="-JM6i"

gmt psbasemap  $proj_map $bound_map $bmap -P -K > $output
gmt grdgradient $grdpath/dem_puna_resamp.grd -Nt1 -A75 -Gtemp_puna.grd
gmt grdimage $grdpath/dem_puna_resamp.grd -Itemp_puna.grd -C$cptpath/white2.cpt $bound_map $proj_map  -O -K -t25 >> $output

##Stations and volcanoes
awk '{print $1,$2}' $stationpath/spuna_stations.txt | gmt psxy $proj_map $bound_map -Sd0.22 -Gcyan -W0.4p,black -O -K >>$output
awk '{print $2,$1}' $plotdatapath/holocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.3 -W0.2p,black -Gmagenta -O -K >>$output
awk '{print $2,$1}' $plotdatapath/pliestocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.3 -W0.2p,black -Gmagenta -O -K >>$output

#plot station corrections
awk '{ print $1,$2,$4,$4/1.5}' $eventpath_velest/stncorrection_spuna.txt| gmt psxy $proj_map $bound_map -Sc -W0.2p -Cdep.cpt -O  -K -t40 >>$output

#white box
gmt psxy  $proj_map $bound_map -W0.7,black -Gwhite -O -K << EOF >> $output
-69.5 -28.1
-69.5 -28.5
-68.1 -28.5
-68.1 -28.1
-69.5 -28.1
EOF

gmt psxy  $proj_map $bound_map -W0.7,black -Gwhite -O -K << EOF >> $output
-66.6 -28.1
-66.6 -28.5
-65.3 -28.5
-65.3 -28.1
-66.6 -28.1
EOF


#scale
echo "-69.1 -28.3 1.5 1.3"| gmt psxy $proj_map $bound_map -Sc -W0.2p -Cdep.cpt -O  -K -t40 >>$output
echo "-69.1 -28.3 "+""| gmt pstext $proj_map $bound_map -F+f30  -O  -K  >>$output

echo "-68.5 -28.3 -1.5 1.3"| gmt psxy $proj_map $bound_map -Sc -W0.2p -Cdep.cpt -O  -K -t40 >>$output
echo "-68.5 -28.35 "-""| gmt pstext $proj_map $bound_map -F+f35  -O  -K  >>$output

echo "-66.3 -28.25 0.5 0.33"| gmt psxy $proj_map $bound_map -Sc -W0.2p -Cdep.cpt -O  -K -t40 >>$output
echo "-66.3 -28.43 0.5"| gmt pstext $proj_map $bound_map -F+f12 -O  -K >>$output

echo "-66.0 -28.25 1.0 0.67"| gmt psxy $proj_map $bound_map -Sc -W0.2p -Cdep.cpt -O  -K -t40 >>$output
echo "-66.0 -28.43 1.0"| gmt pstext $proj_map $bound_map -F+f12 -O  -K >>$output

echo "-65.6 -28.25 1.5 1.0"| gmt psxy $proj_map $bound_map -Sc -W0.2p -Cdep.cpt -O  -K -t40 >>$output
echo "-65.6 -28.43 1.5"| gmt pstext $proj_map $bound_map -F+f12 -O  -K >>$output

gmt gmtset FONT_ANNOT_PRIMARY = 9p,Helvetica,black
gmt gmtset FONT_LABEL		= 9p
gmt gmtset MAP_ANNOT_OFFSET=2p
gmt gmtset MAP_LABEL_OFFSET=1p
gmt psbasemap  $proj_map $bound_map  -LjTR+c27S+w40k+l+ab+f+o0.5c -P  -O -K >> $output
########################################################################################################################


################################################plot for Vs#######################################################

gmt gmtset FONT_ANNOT_PRIMARY = 12p,Helvetica,black
gmt gmtset FONT_LABEL		= 12p
gmt psbasemap  $proj_map $bound_map $bmap -X17 -P -K -O >> $output
gmt grdimage $grdpath/dem_puna_resamp.grd -Itemp_puna.grd -C$cptpath/white2.cpt $bound_map $proj_map  -O -K -t25 >> $output

##Stations and volcanoes
awk '{print $1,$2}' $stationpath/spuna_stations.txt | gmt psxy $proj_map $bound_map -Sd0.22 -Gcyan -W0.4p,black -O -K >>$output
awk '{print $2,$1}' $plotdatapath/holocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.3 -W0.2p,black -Gmagenta -O -K >>$output
awk '{print $2,$1}' $plotdatapath/pliestocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.3 -W0.2p,black -Gmagenta -O -K >>$output

#plot events
gmt makecpt -T-1/1/1 -Cpolar -D -I > dep.cpt
awk '{print $1,$2,$5,$5/1.5}' $eventpath_velest/stncorrection_spuna.txt| gmt psxy $proj_map $bound_map -Sc -W0.2p -Cdep.cpt -O  -K -t40 >>$output

#white box
gmt psxy  $proj_map $bound_map -W0.7,black -Gwhite -O -K << EOF >> $output
-69.5 -28.1
-69.5 -28.5
-68.1 -28.5
-68.1 -28.1
-69.5 -28.1
EOF

gmt psxy  $proj_map $bound_map -W0.7,black -Gwhite -O -K << EOF >> $output
-66.6 -28.1
-66.6 -28.5
-65.3 -28.5
-65.3 -28.1
-66.6 -28.1
EOF

#scale
echo "-69.1 -28.3 1.5 1.3"| gmt psxy $proj_map $bound_map -Sc -W0.2p -Cdep.cpt -O  -K -t40 >>$output
echo "-69.1 -28.3 "+""| gmt pstext $proj_map $bound_map -F+f30  -O  -K  >>$output

echo "-68.5 -28.3 -1.5 1.3"| gmt psxy $proj_map $bound_map -Sc -W0.2p -Cdep.cpt -O  -K -t40 >>$output
echo "-68.5 -28.35 "-""| gmt pstext $proj_map $bound_map -F+f35  -O  -K  >>$output

echo "-66.3 -28.25 0.5 0.33"| gmt psxy $proj_map $bound_map -Sc -W0.2p -Cdep.cpt -O  -K -t40 >>$output
echo "-66.3 -28.43 0.5"| gmt pstext $proj_map $bound_map -F+f12 -O  -K >>$output

echo "-66.0 -28.25 1.0 0.67"| gmt psxy $proj_map $bound_map -Sc -W0.2p -Cdep.cpt -O  -K -t40 >>$output
echo "-66.0 -28.43 1.0"| gmt pstext $proj_map $bound_map -F+f12 -O  -K >>$output

echo "-65.6 -28.25 1.5 1.0"| gmt psxy $proj_map $bound_map -Sc -W0.2p -Cdep.cpt -O  -K -t40 >>$output
echo "-65.6 -28.43 1.5"| gmt pstext $proj_map $bound_map -F+f12 -O  -K >>$output

gmt gmtset FONT_ANNOT_PRIMARY = 9p,Helvetica,black
gmt gmtset FONT_LABEL		= 9p
gmt gmtset MAP_ANNOT_OFFSET=2p
gmt gmtset MAP_LABEL_OFFSET=1p
gmt psbasemap  $proj_map $bound_map  -LjTR+c27S+w40k+l+ab+f+o0.5c -P  -O >> $output

gmt psconvert -Tg -A -E500 $output
gmt psconvert -Tf -A -E500 $output

######################################end of map plot####################################################################



rm  *.xz *.xy *.cpt *.grd *.txt