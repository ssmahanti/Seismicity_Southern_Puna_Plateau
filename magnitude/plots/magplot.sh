#Main plotting script for REAL, VELEST and HypoDD

gmt gmtset MAP_FRAME_TYPE="plain"
gmt gmtset PAPER_MEDIA = A4
gmt gmtset FONT_ANNOT_PRIMARY = 12p,Helvetica,black
gmt gmtset FONT_LABEL		= 12p
bound_map="-R-69.5/-65.5/-28.5/-25"
proj_map="-JM6i"

#filepaths
eventpath_real="/Users/sankha/Desktop/research/southern_puna/real/catalog"
eventpath_velest="/Users/sankha/Desktop/research/southern_puna/velest/output"
eventpath_hypodd="/Users/sankha/Desktop/research/southern_puna/hypodd/output"
eventpath_mag="/Users/sankha/Desktop/research/southern_puna/magnitude"

stationpath="/Users/sankha/Desktop/research/southern_puna/station"
plotdatapath="/Users/sankha/Desktop/research/southern_puna/plots/plotdata"
grdpath="/Users/sankha/Desktop/research/grdfiles"
cptpath="/Users/sankha/Desktop/research/cptfiles"

outpath="."

#change filename as required

output="$outpath/eventmap_magnitude_big.ps"


#cptfiles
gmt makecpt -T0000/5000/50 -D -Celevation > topo2.cpt
gmt makecpt -T0/35/5 -Chot -D -I > dep.cpt
gmt makecpt -T0.5/4.0/.5 -Cinferno -D -I > mag.cpt

gmt makecpt -T3.2/4.1/0.1 -Cseis -D  > tomo.cpt
gmt makecpt -T0/40/1 -Cjet -D -I > cluster.cpt

#############plot of basemap and topography#######################################################
bmap="-Ba1f.5:""::,:/a1f.5:""::,:WeSn"

gmt psbasemap  $proj_map $bound_map $bmap -P -K > $output
#gmt grdgradient $grdpath/dem_puna.grd -Nt1 -A75 -Gtemp_puna.grd
#gmt grd2cpt $grdpath/dem_puna.grd -Cnatural.cpt -S0/7000/400  -V -Z > mycpt.cpt
#gmt grdimage $grdpath/dem_puna.grd -Itemp_puna.grd -C$cptpath/white2.cpt $bound_map $proj_map  -O -K -t30 >> $output

#faults
pensize=0.25

#gmt psxy $plotdatapath/salar_de_antofella.csv $proj_map $bound_map  -W0.4p,black -Gskyblue1 -O -K >>$output
#gmt psxy $plotdatapath/hombre.csv $proj_map $bound_map  -W0.4p,black -Gskyblue1 -O -K >>$output
#gmt psxy $plotdatapath/nwse_margins.txt $proj_map $bound_map  -W0.4p,red,-.  -O -K >>$output

#Faults
gap=0.2
size=0.02
gmt psxy $proj_map $bound_map $plotdatapath/faults/thrust1.txt -W${pensize},black -Sf${gap}i/${size}i+l+t -Gblack -O -K>> $output #Thrust to left of calastre
gmt psxy $proj_map $bound_map $plotdatapath/faults/thrust2.txt -W${pensize},black -Sf${gap}i/${size}i+r+t -Gblack -O -K>> $output #Thrust to right of calastre
gmt psxy $proj_map $bound_map $plotdatapath/faults/strikeslip.txt -W${pensize},black   -O -K>> $output #acazaque fault
gmt psxy $proj_map $bound_map $plotdatapath/faults/unknown.txt -W${pensize},black,.-   -O -K>> $output #unknown faults
gmt psxy $proj_map $bound_map $plotdatapath/faults/nm.txt -W${pensize},black,-   -O -K>> $output #normal faults
gmt psxy $proj_map $bound_map $plotdatapath/faults/thrust3.txt -W${pensize},black -Sf${gap}i/${size}i+l+t -Gblack -O -K>> $output #unknown faults
gmt psxy $proj_map $bound_map $plotdatapath/faults/thrust4.txt -W${pensize},black -Sf${gap}i/${size}i+r+t -Gblack -O -K>> $output #unknown faults

##Stations and volcanoes
awk '{print $1,$2}' $stationpath/all_station.txt | gmt psxy $proj_map $bound_map -Sd0.22 -Gcyan -W0.4p,black -O -K >>$output
awk '{print $2,$1}' $plotdatapath/holocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.3 -W0.2p,black -Gmagenta -O -K >>$output
awk '{print $2,$1}' $plotdatapath/pliestocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.3 -W0.2p,black -Gmagenta -O -K >>$output

#plot events
#awk '{print $8,$7,$9}' $eventpath_real/catalog_sa.txt| gmt psxy $proj_map $bound_map -Sc0.15 -W0.5p -Cdep.cpt -O  -K >>$output
#awk '{print $8,$7,$9}' $eventpath_velest/catalog_velest_n1.txt| gmt psxy $proj_map $bound_map -Sc0.15 -W0.2p -Cdep.cpt -O  -K >>$output
awk '{ if ($8<-67.2 && $8>-67.6 && $7>-25.9 && $7<-25.8) print $8,$7,$11}' $eventpath_mag/puna_mag_hypodd.txt| gmt psxy $proj_map $bound_map -Sc0.15 -W0.2p -Cmag.cpt -O  -K >>$output
#gmt psxy $plotdatapath/mulachy_catalog.txt $proj_map $bound_map -Sc0.15 -W0.2p -Cdep.cpt -O  -K -: >>$output



#white box
gmt psxy  $proj_map $bound_map -W0.7,black -Gwhite -O -K << EOF >> $output
-69.5 -28.0
-69.5 -28.5
-68.1 -28.5
-68.1 -28.0
-69.5 -28.0
EOF

gmt psxy  $proj_map $bound_map -W0.7,black -Gwhite -O -K << EOF >> $output
-66.7 -28.0
-66.7 -28.5
-65.5 -28.5
-65.5 -28.0
-66.7 -28.0
EOF

#labels
gmt psxy  $proj_map $bound_map -W${pensize},black -Sf${gap}i/${size}i+l+t -Gblack -O -K << EOF >> $output
-66.6 -28.1
-66.3 -28.1
EOF
echo "-66 -28.1 "Thrust Fault"" | gmt pstext $proj_map $bound_map -F+f8    -O -K >>$output

gmt psxy  $proj_map $bound_map -W${pensize},black,-  -O -K << EOF >> $output
-66.6 -28.2
-66.3 -28.2
EOF
echo "-66 -28.2 "Normal Fault"" | gmt pstext $proj_map $bound_map -F+f8   -O -K >>$output

gmt psxy  $proj_map $bound_map -W${pensize},black  -Gblack -O -K << EOF >> $output
-66.6 -28.3
-66.3 -28.3
EOF
echo "-66 -28.3 "Strike-slip Fault"" | gmt pstext $proj_map $bound_map -F+f8  -K  -O  >>$output

gmt psxy  $proj_map $bound_map -W${pensize},black,.-   -O -K << EOF >> $output
-66.6 -28.4
-66.3 -28.4
EOF
echo "-66 -28.4 "Unknown Fault"" | gmt pstext $proj_map $bound_map -F+f8    -O -K >>$output
#Cross_section points
gmt gmtset FONT_ANNOT_PRIMARY = 10p,Helvetica,black
gmt gmtset FONT_LABEL		= 10p
gmt psscale -D0.25/1.3+w4.5/0.3+h -Cmag.cpt -Ba.5+l"Local Magnitude" -O >> $output
#gmt psscale -D1/2+w5/0.3+h -Ctomo.cpt -Ba0.2+l"Vs (km/s)" -O -K  >> $output

gmt psconvert -Tg -A -E500 $output

gmt psconvert -Tf -A -E500 $output

rm  *.xz *.xy *.cpt *.grd *.txt