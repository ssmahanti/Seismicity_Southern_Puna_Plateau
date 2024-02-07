#Script to plot the earthquakes in cross-sections:

#defaults
gmt gmtset MAP_FRAME_TYPE="plain"
gmt gmtset PAPER_MEDIA = A4
gmt gmtset FONT_ANNOT_PRIMARY = 12p,Helvetica,black
gmt gmtset FONT_LABEL		= 12p

#filepaths
eventpath_velest="/Users/sankha/Desktop/research/Spuna_plateau/velest/output"
eventpath_hypodd="/Users/sankha/Desktop/research/Spuna_plateau/hypodd/output"
eventpath_mag="/Users/sankha/Desktop/research/Spuna_plateau/magnitude"

stationpath="/Users/sankha/Desktop/research/Spuna_plateau/station"
plotdatapath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/plotdata"
grdpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/grdfiles"
cptpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/cptfiles"

#change filename as required
output="eventmap.ps"
out_cross="event_cross.ps"

#cptfiles
gmt makecpt -T0/35/5 -Chot -D -I > dep.cpt

###############################################plot of mapview#######################################################
bound_map="-R-69.5/-65.3/-28.5/-25"
proj_map="-JM6i"
bmap="-Ba1f.5:""::,:/a1f.5:""::,:WeSn"

gmt psbasemap  $proj_map $bound_map $bmap -P -K > $output
gmt grdgradient $grdpath/dem_puna_resamp.grd -Nt1 -A75 -Gtemp_puna.grd
gmt grdimage $grdpath/dem_puna_resamp.grd -Itemp_puna.grd -C$cptpath/white2.cpt $bound_map $proj_map  -O -K -t25 >> $output

#faults
pensize=0.25
gap=0.2
size=0.02
gmt psxy $proj_map $bound_map $plotdatapath/faults/thrust1.txt -W${pensize},black -Sf${gap}i/${size}i+l+t -Gblack -O -K>> $output #Thrust to left of calastre
gmt psxy $proj_map $bound_map $plotdatapath/faults/thrust2.txt -W${pensize},black -Sf${gap}i/${size}i+r+t -Gblack -O -K>> $output #Thrust to right of calastre
gmt psxy $proj_map $bound_map $plotdatapath/faults/strikeslip.txt -W${pensize},black   -O -K>> $output #acazaque fault
gmt psxy $proj_map $bound_map $plotdatapath/faults/unknown.txt -W${pensize},black,.-   -O -K>> $output #unknown faults
gmt psxy $proj_map $bound_map $plotdatapath/faults/nm.txt -W${pensize},black,-   -O -K>> $output #normal faults
gmt psxy $proj_map $bound_map $plotdatapath/faults/thrust3.txt -W${pensize},black -Sf${gap}i/${size}i+l+t -Gblack -O -K>> $output #thrust faults
gmt psxy $proj_map $bound_map $plotdatapath/faults/thrust4.txt -W${pensize},black -Sf${gap}i/${size}i+r+t -Gblack -O -K>> $output #thrust faults

##Stations and volcanoes
awk '{print $1,$2}' $stationpath/spuna_stations.txt | gmt psxy $proj_map $bound_map -Sd0.28 -Gcyan -W0.4p,black -O -K >>$output
awk '{print $2,$1}' $plotdatapath/holocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.35 -W0.2p,black -Gmagenta -O -K >>$output
awk '{print $2,$1}' $plotdatapath/pliestocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.35 -W0.2p,black -Gmagenta -O -K >>$output

gmt psxy $plotdatapath/lineaments.txt $proj_map $bound_map -W0.4p,red,- -O -K >>$output

#plot events
#awk '{print $8,$7,$9}' $eventpath_velest/catalog_velest_puna_crust_v5.txt| gmt psxy $proj_map $bound_map -Sc0.15 -W0.2p -Cdep.cpt -O  -K >>$output
awk '{print $8,$7,$9}' $eventpath_hypodd/catalog_hypodd_puna_crust_v5.txt| gmt psxy $proj_map $bound_map -Sc0.15 -W0.2p -Cdep.cpt -O  -K >>$output

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

#color scale
gmt gmtset FONT_ANNOT_PRIMARY = 9p,Helvetica,black
gmt gmtset FONT_LABEL		= 9p
gmt psscale -D0.2/1.1+w4.5/0.3+h -Cdep.cpt -Ba5+l"Depth (km)" -O -K >> $output

#scale
gmt gmtset FONT_ANNOT_PRIMARY = 9p,Helvetica,black
gmt gmtset FONT_LABEL		= 9p
gmt gmtset MAP_ANNOT_OFFSET=2p
gmt gmtset MAP_LABEL_OFFSET=1p
gmt psbasemap  $proj_map $bound_map  -LjTL+c27S+w40k+l+ab+f+o0.5c -P  -O -K>> $output

#cross-section lines
echo -68.7 -25.93 "A1" >tmp_map.txt
echo -65.58 -25.93 "B1" >>tmp_map.txt
echo ">>" >> tmp_map.txt
echo -68.7 -26.10 "A2" >>tmp_map.txt
echo -65.58 -26.10 "B2" >>tmp_map.txt
echo ">>" >> tmp_map.txt
echo -68.7 -26.45 "A3" >>tmp_map.txt
echo -65.58 -26.45 "B3" >>tmp_map.txt
echo ">>" >> tmp_map.txt
echo -68.7 -26.75 "A4" >>tmp_map.txt
echo -65.58 -26.75 "B4" >>tmp_map.txt
echo ">>" >> tmp_map.txt
echo -68.7 -27.05 "A5" >>tmp_map.txt
echo -65.58 -27.05 "B5" >>tmp_map.txt
echo ">>" >> tmp_map.txt
echo -68.7 -27.32 "A6" >>tmp_map.txt
echo -65.58 -27.32 "B6" >>tmp_map.txt
gmt psxy $proj_map $bound_map tmp_map.txt -W0.4p,blue,-  -O -K>> $output
gmt pstext $proj_map $bound_map tmp_map.txt -F+f10 -W0.4p,blue -Gwhite -O  >> $output

gmt psconvert -Tg -A -E300 $output
gmt psconvert -Tf -A -E300 $output
################################################end of map plot####################################################################

#################################################Cross-section plot####################################################
gmt gmtset PAPER_MEDIA = A3
gmt gmtset TICK_PEN = 0.3p
gmt gmtset TICK_LENGTH = 0.08c
yshift=-9.7
xshift=10
shifttopo=-2.7
proj_cross=" -JX3.7i/0.9i"
proj_topo=" -JX3.7i/0.7i"
bound_cross="-R0/312/-40/10"
bound_topo="-R0/312/0/8"
Bcross="-Ba30f10:"Distance\(km\)"::,:/a10f5:"Depth\(km\)"::,:Wesn"
Bcross2="-Ba30f10:"Distance\(km\)"::,:/a10f5:"Depth\(km\)"::,:WeSn"
width="-10/10" #Width of box plotting cross-section events

###############Cross-section 1#########################

A1="-68.7/-25.93"
B1="-65.58/-25.93"

#topogrphy
gmt project -C$A1 -E$B1 -G.2  -Q > topo.xy
gmt grdtrack topo.xy -G$grdpath/dem_puna_resamp.grd > topo.xz
# Padding top and bottom numbers with y value 0 to color the topography
head -1 topo.xz | awk '{print $1, $2, $3, 0}' > top
tail -1 topo.xz | awk '{print $1, $2, $3, 0}' > bottom
cat topo.xz >> top
cat bottom >> top
mv top topo.xz
rm -f bottom
awk '{print $3, $4/1000.0}' topo.xz | gmt psxy $proj_cross $bound_cross $Bcross -Y16  -K -V -G200  > $out_cross

#Background seismicity
awk '{print $8,$7,$9}' $eventpath_hypodd/catalog_hypodd_puna_crust_v5.txt | gmt project -C$A1 -E$B1 -Fxyzpqrs -W-12/12  -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross $Bcross -Sc0.11  -Gred -P  -W0.2p -O -K >> $out_cross

#Markers
echo 10 -37 A1 >tmp_text.txt
echo 303 -37 "B1" >>tmp_text.txt
gmt pstext tmp_text.txt $proj_cross $bound_cross -W0.7p -Gwhite -O  -K >> $out_cross

gmt project $plotdatapath/pliestocene_volcano.txt -C$A1 -E$B1 -Fxyzpqrs -W$width  -Lw -Q -: > temp_volcano.txt
gmt project $plotdatapath/holocene_volcano.txt -C$A1 -E$B1 -Fxyzpqrs -W$width  -Lw -Q -: >> temp_volcano.txt
awk '{print $4, $3/1000}' temp_volcano.txt | gmt psxy $proj_cross $bound_cross -St0.25 -Gmagenta -W0.01,black -O -K    >> $out_cross

##############Cross-section 2#####################################
A2="-68.7/-26.10"
B2="-65.57/-26.10"

#topogrphy
gmt project -C$A2 -E$B2 -G.2  -Q > topo.xy
gmt grdtrack topo.xy -G$grdpath/dem_puna_resamp.grd > topo.xz
head -1 topo.xz | awk '{print $1, $2, $3, 0}' > top
tail -1 topo.xz | awk '{print $1, $2, $3, 0}' > bottom
cat topo.xz >> top
cat bottom >> top
mv top topo.xz
rm -f bottom
awk '{print $3, $4/1000.0}' topo.xz | gmt psxy $proj_cross $bound_cross $Bcross -Y$shifttopo -O -K -V -G200 >> $out_cross

#Background seismicity
awk '{print $8,$7,$9}' $eventpath_hypodd/catalog_hypodd_puna_crust_v5.txt | gmt project -C$A2 -E$B2 -Fxyzpqrs -W-10/10 -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross $Bcross -Sc0.11 -P -Gred -W0.1p -K -O >> $out_cross

#markers
echo 10 -37 A2 >tmp_text.txt
echo 303 -37 "B2" >>tmp_text.txt
gmt pstext tmp_text.txt $proj_cross $bound_cross -W0.7p -Gwhite -O -K >> $out_cross

gmt project $plotdatapath/pliestocene_volcano.txt -C$A2 -E$B2 -Fxyzpqrs -W$width  -Lw -Q -: > temp_volcano.txt
gmt project $plotdatapath/holocene_volcano.txt -C$A2 -E$B2 -Fxyzpqrs -W$width  -Lw -Q -: >> temp_volcano.txt
awk '{print $4, -0.2+$3/1000}' temp_volcano.txt | gmt psxy $proj_cross $bound_cross -St0.25 -Gmagenta -W0.01,black  -O -K    >> $out_cross

##############Cross-section 3#####################################
A3="-68.7/-26.45"
B3="-65.57/-26.45"

#topogrphy
gmt project -C$A3 -E$B3 -G.2  -Q > topo.xy
gmt grdtrack topo.xy -G$grdpath/dem_puna_resamp.grd > topo.xz
head -1 topo.xz | awk '{print $1, $2, $3, 0}' > top
tail -1 topo.xz | awk '{print $1, $2, $3, 0}' > bottom
cat topo.xz >> top
cat bottom >> top
mv top topo.xz
rm -f bottom
awk '{print $3, $4/1000.0}' topo.xz | gmt psxy $proj_cross $bound_cross $Bcross2 -Y$shifttopo -O -K -V -G200 >> $out_cross

#Background seismicity
awk '{print $8,$7,$9}' $eventpath_hypodd/catalog_hypodd_puna_crust_v5.txt | gmt project -C$A3 -E$B3 -Fxyzpqrs -W$width  -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross $Bcross2  -Sc0.11 -Gred   -P -O -W0.1p -K >> $out_cross

#markers
echo 10 -37 A3 >tmp_text.txt
echo 302 -37 "B3" >>tmp_text.txt
gmt pstext tmp_text.txt $proj_cross $bound_cross -W0.7p -Gwhite -O -K >> $out_cross

gmt project $plotdatapath/pliestocene_volcano.txt -C$A3 -E$B3 -Fxyzpqrs -W$width  -Lw -Q -: > temp_volcano.txt
gmt project $plotdatapath/holocene_volcano.txt -C$A3 -E$B3 -Fxyzpqrs -W$width  -Lw -Q -: >> temp_volcano.txt
awk '{print $4, -1+$3/1000}' temp_volcano.txt | gmt psxy $proj_cross $bound_cross -St0.25 -Gmagenta -W0.01,black -O -K    >> $out_cross

##############Cross-section 4#####################################

A4="-68.7/-26.75"
B4="-65.57/-26.75"

Bcross="-Ba30f10:"Distance\(km\)"::,:/a10f5:"Depth\(km\)"::,:wesn"
Bcross2="-Ba30f10:"Distance\(km\)"::,:/a10f5:"Depth\(km\)"::,:weSn"

#topogrphy
gmt project -C$A4 -E$B4 -G.2  -Q > topo.xy
gmt grdtrack topo.xy -G$grdpath/dem_puna_resamp.grd > topo.xz
head -1 topo.xz | awk '{print $1, $2, $3, 0}' > top
tail -1 topo.xz | awk '{print $1, $2, $3, 0}' > bottom
cat topo.xz >> top
cat bottom >> top
mv top topo.xz
rm -f bottom
awk '{print $3, $4/1000.0}' topo.xz | gmt psxy $proj_cross $bound_cross $Bcross -X$xshift -Y5.4 -O -K -V -G200 >> $out_cross

#Background seismicity
awk '{print $8,$7,$9}' $eventpath_hypodd/catalog_hypodd_puna_crust_v5.txt| gmt project -C$A4 -E$B4 -Fxyzpqrs -W$width  -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross $Bcross -Sc0.11  -Gred -O -P  -W0.1p -K >> $out_cross

#markers
echo 10 -37 A4 >tmp_text.txt
echo 302 -37 "B4" >>tmp_text.txt
gmt pstext tmp_text.txt $proj_cross $bound_cross -W0.7p -Gwhite -O  -K >> $out_cross

gmt project $plotdatapath/pliestocene_volcano.txt -C$A4 -E$B4 -Fxyzpqrs -W$width  -Lw -Q -: > temp_volcano.txt
gmt project $plotdatapath/holocene_volcano.txt -C$A4 -E$B4 -Fxyzpqrs -W$width  -Lw -Q -: >> temp_volcano.txt
awk '{print $4, -0.5+$3/1000}' temp_volcano.txt | gmt psxy $proj_cross $bound_cross -St0.25 -Gmagenta -W0.01,black -O -K    >> $out_cross

##############Cross-section 5#####################################

A5="-68.7/-27.05"
B5="-65.57/-27.05"

#topogrphy
gmt project -C$A5 -E$B5 -G.2  -Q > topo.xy
gmt grdtrack topo.xy -G$grdpath/dem_puna_resamp.grd > topo.xz
head -1 topo.xz | awk '{print $1, $2, $3, 0}' > top
tail -1 topo.xz | awk '{print $1, $2, $3, 0}' > bottom
cat topo.xz >> top
cat bottom >> top
mv top topo.xz
rm -f bottom
awk '{print $3, $4/1000.0}' topo.xz | gmt psxy $proj_cross $bound_cross $Bcross -Y$shifttopo -O -K -V -G200 >> $out_cross

#Background seismicity
awk '{print $8,$7,$9}' $eventpath_hypodd/catalog_hypodd_puna_crust_v5.txt | gmt project -C$A5 -E$B5 -Fxyzpqrs -W$width  -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross $Bcross -Sc0.11  -P -Gred -W0.1p -K -O >> $out_cross

#markers
echo 10 -37 A5 >tmp_text.txt
echo 302 -37 "B5" >>tmp_text.txt
gmt pstext tmp_text.txt $proj_cross $bound_cross -W0.7p -Gwhite -O -K >> $out_cross

gmt project $plotdatapath/pliestocene_volcano.txt -C$A5 -E$B5 -Fxyzpqrs -W$width  -Lw -Q -: > temp_volcano.txt
gmt project $plotdatapath/holocene_volcano.txt -C$A5 -E$B5 -Fxyzpqrs -W$width  -Lw -Q -: >> temp_volcano.txt
awk '{print $4, -1+$3/1000}' temp_volcano.txt | gmt psxy $proj_cross $bound_cross -St0.25 -Gmagenta -W0.01,black -O -K    >> $out_cross

##############Cross-section 6#####################################
A6="-68.7/-27.32"
B6="-65.57/-27.32"

#topography
gmt project -C$A6 -E$B6 -G.2  -Q > topo.xy
gmt grdtrack topo.xy -G$grdpath/dem_puna_resamp.grd > topo.xz
head -1 topo.xz | awk '{print $1, $2, $3, 0}' > top
tail -1 topo.xz | awk '{print $1, $2, $3, 0}' > bottom
cat topo.xz >> top
cat bottom >> top
mv top topo.xz
rm -f bottom
awk '{print $3, $4/1000.0}' topo.xz | gmt psxy $proj_cross $bound_cross $Bcross2 -Y$shifttopo -O -K -V -G200 >> $out_cross

#Background seismicity
awk '{print $8,$7,$9}' $eventpath_hypodd/catalog_hypodd_puna_crust_v5.txt | gmt project -C$A6 -E$B6 -Fxyzpqrs -W$width  -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross  -Sc0.11 -Gred  -P -O -W0.1p -K >> $out_cross

#markers
echo 10 -37 A6 >tmp_text.txt
echo 302 -37 "B6" >>tmp_text.txt
gmt pstext tmp_text.txt $proj_cross $bound_cross -W0.7p -Gwhite -O -K >> $out_cross

gmt project $plotdatapath/pliestocene_volcano.txt -C$A6 -E$B6 -Fxyzpqrs -W$width  -Lw -Q -: > temp_volcano.txt
gmt project $plotdatapath/holocene_volcano.txt -C$A6 -E$B6 -Fxyzpqrs -W$width  -Lw -Q -: >> temp_volcano.txt
awk '{print $4, $3/1000}' temp_volcano.txt | gmt psxy $proj_cross $bound_cross -St0.25 -Gmagenta -W0.01,black -O -K    >> $out_cross

#######################################################
echo "0 0" | gmt psxy -Sc0.001 $proj_cross $bound_cross -O   -W0.001p >> $out_cross
gmt psconvert -Tg -A -E500 $out_cross
gmt psconvert -Tf -A -E500 $out_cross

rm  *.xz *.xy *.cpt *.grd *.txt Aa*
