#Script for plotting focal mechanisms on the map

#Config
gmt gmtset MAP_FRAME_TYPE="plain"
gmt gmtset PAPER_MEDIA = A4
gmt gmtset FONT_ANNOT_PRIMARY = 12p,Helvetica,black
gmt gmtset FONT_LABEL		= 12p

#filepaths
eventpath_velest="/Users/sankha/Desktop/research/Spuna_plateau/velest/output"
eventpath_hypodd="/Users/sankha/Desktop/research/Spuna_plateau/hypodd/output"
stationpath="/Users/sankha/Desktop/research/Spuna_plateau/station"
plotdatapath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/plotdata"
grdpath="/Users/sankha/Desktop/research/grdfiles"
cptpath="/Users/sankha/Desktop/research/cptfiles"
focmecpath="/Users/sankha/Desktop/research/Spuna_plateau/focmec/output"

#change filename as required
output="focmecplot_CATEGORY.ps"

#cptfiles
gmt makecpt -T0/35/5 -Chot -D -I > dep.cpt

#############plot of basemap and topography#######################################################
bound_map="-R-69.5/-65.3/-28.5/-25"
proj_map="-JM6i"
bmap="-Ba1f.5:""::,:/a1f.5:""::,:WeSn"

gmt psbasemap  $proj_map $bound_map $bmap -P -K > $output
gmt grdgradient $grdpath/dem_puna_resamp.grd -Nt1 -A75 -Gtemp_puna.grd
gmt grdimage $grdpath/dem_puna_resamp.grd -Itemp_puna.grd -C$cptpath/white2.cpt $bound_map $proj_map  -O -K -t25>> $output

#faults
pensize=0.25
gap=0.2
size=0.02
gmt psxy $proj_map $bound_map $plotdatapath/faults/thrust1.txt -W${pensize},black -Sf${gap}i/${size}i+l+t -Gblack -O -K>> $output #Thrust to left of calastre
gmt psxy $proj_map $bound_map $plotdatapath/faults/thrust2.txt -W${pensize},black -Sf${gap}i/${size}i+r+t -Gblack -O -K>> $output #Thrust to right of calastre
gmt psxy $proj_map $bound_map $plotdatapath/faults/strikeslip.txt -W${pensize},black,-   -O -K>> $output #acazaque fault
gmt psxy $proj_map $bound_map $plotdatapath/faults/unknown.txt -W${pensize},black,.-   -O -K>> $output #unknown faults
gmt psxy $proj_map $bound_map $plotdatapath/faults/nm.txt -W${pensize},black,-   -O -K>> $output #normal faults
gmt psxy $proj_map $bound_map $plotdatapath/faults/thrust3.txt -W${pensize},black -Sf${gap}i/${size}i+l+t -Gblack -O -K>> $output #thrust faults
gmt psxy $proj_map $bound_map $plotdatapath/faults/thrust4.txt -W${pensize},black -Sf${gap}i/${size}i+r+t -Gblack -O -K>> $output #thrust faults

##Stations and volcanoes
awk '{print $1,$2}' $stationpath/spuna_stations.txt | gmt psxy $proj_map $bound_map -Sd0.22 -Gcyan -W0.5p,black -O -K >>$output
awk '{print $2,$1}' $plotdatapath/holocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.3 -W0.2p,black -Gmagenta -O -K >>$output
awk '{print $2,$1}' $plotdatapath/pliestocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.3 -W0.2p,black -Gmagenta -O -K >>$output

#lineaments
gmt psxy $plotdatapath/lineaments.txt $proj_map $bound_map -W0.4p,red,- -O -K >>$output

#plot events
awk '{print $8,$7,$9}' $eventpath_hypodd/catalog_hypodd_puna_crust_v5.txt| gmt psxy $proj_map $bound_map -Sc0.11 -W0.05p -Cdep.cpt -O -t10 -K >>$output


# Plotting focal mechanism
#GCMT Mechanisms
#awk '{print $1,$2,$3,$4,$5,$6,$7,$1,$2}' $plotdatapath/gcmt_focmec.dat  | gmt psmeca $proj_map -R -C0.1 -Sa0.6/8/-10 -O -K -GGRAY24  -N  >> $output
#This study: Different color for different group
cat focmec_category.csv | awk -F"," '{ if ( $13==1 ) print $2,$3,$4,$5,$6,$7,$8,$2,$3}' | gmt psmeca $proj_map -R -C0.1 -Sa1.0/8/-10 -O -K -Gred  -N  >> $output
cat focmec_category.csv | awk -F"," '{ if ( $13==2 ) print $2,$3,$4,$5,$6,$7,$8,$2,$3}' | gmt psmeca $proj_map -R -C0.1 -Sa1.0/8/-10 -O -K -Gblue -N  >> $output
cat focmec_category.csv | awk -F"," '{ if ( $13==3 ) print $2,$3,$4,$5,$6,$7,$8,$2,$3}' | gmt psmeca $proj_map -R -C0.1 -Sa1.0/8/-10 -O -K -Ggreen -N  >> $output

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
gmt gmtset FONT_ANNOT_PRIMARY = 9p,Helvetica,black
gmt gmtset FONT_LABEL		= 9p
gmt psscale -D0.2/1.1+w4.5/0.3+h -Cdep.cpt -Ba5+l"Depth (km)" -O -K >> $output

#scale
gmt gmtset FONT_ANNOT_PRIMARY = 9p,Helvetica,black
gmt gmtset FONT_LABEL		= 9p
gmt gmtset MAP_ANNOT_OFFSET=2p
gmt gmtset MAP_LABEL_OFFSET=1p
gmt psbasemap  $proj_map $bound_map  -LjTL+c27S+w40k+l+ab+f+o0.5c -P  -O >> $output

gmt psconvert -Tg -A1  -E400 $output
gmt psconvert -Tf -A1  -E400 $output

rm *.grd *.cpt *.txt *.ps