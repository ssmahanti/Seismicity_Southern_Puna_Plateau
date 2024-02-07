#Script for plotting the regional map of southern Puna plateau

gmt gmtset MAP_FRAME_TYPE="plain"
gmt gmtset PAPER_MEDIA = A4
gmt gmtset FONT = 10p,Helvetica,black
gmt gmtset FORMAT_GEO_MAP=D

#filepaths
stationpath="/Users/sankha/Desktop/research/Spuna_plateau/station"
plotdatapath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/plotdata"
grdpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/grdfiles"
cptpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/cptfiles"

#change filename as required
output="areamap_vf.ps"

#cptfiles
gmt makecpt -T0/5500/50 -D -C$cptpath/natural.cpt > topo2.cpt

#############plot of basemap and topography#######################################################
bound_map="-R-69.5/-65.3/-28.5/-25"
proj_map="-JM6i"
bmap="-Ba1f.5:""::,:/a1f.5:""::,:WeSn"

gmt psbasemap  $proj_map $bound_map $bmap -P -K > $output
gmt grdgradient $grdpath/dem_puna_resamp.grd -Nt1 -A75 -Gtemp_puna.grd
gmt grdimage $grdpath/dem_puna_resamp.grd -Itemp_puna.grd -Ctopo2.cpt $bound_map $proj_map  -O -K -t35 >> $output

#Plot Faults
gap=0.2
size=0.02
pensize=0.5
gmt psxy $proj_map $bound_map $plotdatapath/faults/thrust1.txt -W${pensize},black -Sf${gap}i/${size}i+l+t -Gblack -O -K>> $output #Thrust to left of calastre
gmt psxy $proj_map $bound_map $plotdatapath/faults/thrust2.txt -W${pensize},black -Sf${gap}i/${size}i+r+t -Gblack -O -K>> $output #Thrust to right of calastre
gmt psxy $proj_map $bound_map $plotdatapath/faults/strikeslip.txt -W${pensize},black,-   -O -K>> $output #acazaque fault
gmt psxy $proj_map $bound_map $plotdatapath/faults/unknown.txt -W${pensize},black,.-   -O -K>> $output #unknown faults
gmt psxy $proj_map $bound_map $plotdatapath/faults/nm.txt -W${pensize},black,-  -O -K>> $output #normal faults
gmt psxy $proj_map $bound_map $plotdatapath/faults/thrust3.txt -W${pensize},black -Sf${gap}i/${size}i+l+t -Gblack -O -K>> $output #thrust faults
gmt psxy $proj_map $bound_map $plotdatapath/faults/thrust4.txt -W${pensize},black -Sf${gap}i/${size}i+r+t -Gblack -O -K>> $output #thrust faults

#Lineaments
gmt psxy $plotdatapath/lineaments.txt $proj_map $bound_map -W0.5p,red,- -O -K >>$output


#Stations and volcanoes
awk '{print $2,$1}' $plotdatapath/holocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.3 -W0.2p,black -Gmagenta -O -K >>$output
awk '{print $2,$1}' $plotdatapath/pliestocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.3 -W0.2p,black -Gmagenta -O -K >>$output
awk '{print $1,$2}' $stationpath/spuna_stations.txt | gmt psxy $proj_map $bound_map -Sd0.25 -Gcyan -W0.35p,black -O -K >>$output

#white box
gmt psxy  $proj_map $bound_map -W0.7,black -Gwhite -O -K << EOF >> $output
-66.6 -28.1
-66.6 -28.5
-65.3 -28.5
-65.3 -28.1
-66.6 -28.1
EOF

#labels
gmt psxy  $proj_map $bound_map -W${pensize},black -Sf${gap}i/${size}i+l+t -Gblack -O -K << EOF >> $output
-66.55 -28.2
-66.3 -28.2
EOF
echo "-65.8 -28.2 "Thrust Fault"" | gmt pstext $proj_map $bound_map -F+f8    -O -K >>$output
gmt psxy  $proj_map $bound_map -W${pensize},black,-  -O -K << EOF >> $output
-66.55 -28.3
-66.3 -28.3
EOF
echo "-65.8 -28.3 "Normal/ Strike-slip Fault"" | gmt pstext $proj_map $bound_map -F+f8   -O -K >>$output
gmt psxy  $proj_map $bound_map -W${pensize},black,.-   -O -K << EOF >> $output
-66.55 -28.4
-66.3 -28.4
EOF
echo "-65.8 -28.4 "Unknown Fault"" | gmt pstext $proj_map $bound_map -F+f8    -O -K >>$output

#scale
gmt gmtset FONT_ANNOT_PRIMARY = 9p,Helvetica,black
gmt gmtset FONT_LABEL		= 9p
gmt gmtset MAP_ANNOT_OFFSET=2p
gmt gmtset MAP_LABEL_OFFSET=1p
gmt psbasemap  $proj_map $bound_map  -LjTL+c27S+w40k+l+ab+f+o0.5c -P  -O >> $output

gmt psconvert -Tf -A -E500 $output
gmt psconvert -Tg -A -E500 $output

rm  *.grd *.cpt *.txt

######################################end of map plot####################################################################
