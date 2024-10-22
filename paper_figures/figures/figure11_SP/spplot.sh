#Script for plotting figure 11:

gmt gmtset MAP_FRAME_TYPE="plain"
gmt gmtset PAPER_MEDIA = A3
gmt gmtset FONT_ANNOT_PRIMARY = 12p,Helvetica,black
gmt gmtset FONT		= 15p
gmt gmtset FORMAT_GEO_MAP = D

#filepaths
eventpath_velest="/Users/sankha/Desktop/research/Spuna_plateau/velest/output"
eventpath_hypodd="/Users/sankha/Desktop/research/Spuna_plateau/hypodd/output"
stationpath="/Users/sankha/Desktop/research/Spuna_plateau/station"
plotdatapath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/plotdata"
grdpath="/Users/sankha/Desktop/research/grdfiles"
cptpath="/Users/sankha/Desktop/research/cptfiles"
focmecpath="/Users/sankha/Desktop/research/Spuna_plateau/focmec/output"

#change filename as required
output="eventmap_sp_v2.ps"
out_cross="cross_sec_sp_v2.ps"

#cptfiles
gmt makecpt -T0/35/5 -Chot -D -I > dep.cpt

########################################################Map plot#######################################################
bound_map="-R-67.1/-65.5/-27.7/-26.4"
proj_map="-JM6i"
bmap="-Ba.4f.2:""::,:/a.4f.2:""::,:WeSn"

gmt psbasemap  $proj_map $bound_map $bmap  -P -K > $output
gmt grdcut $grdpath/dem_puna.grd -Gdem_tmp.grd $bound_map 
gmt grdgradient dem_tmp.grd -Nt1 -A85  -Gtemp_puna.grd
gmt grdimage dem_tmp.grd -Itemp_puna.grd -C$cptpath/white2.cpt $bound_map $proj_map  -O -K >> $output

#faults
pensize=0.3
gap=0.2
size=0.02
gmt psxy $proj_map $bound_map $plotdatapath/faults/thrust1.txt -W${pensize},black -Sf${gap}i/${size}i+l+t -Gblack -O -K>> $output #Thrust to left of calastre
gmt psxy $proj_map $bound_map $plotdatapath/faults/thrust2.txt -W${pensize},black -Sf${gap}i/${size}i+r+t -Gblack -O -K>> $output #Thrust to right of calastre
gmt psxy $proj_map $bound_map $plotdatapath/faults/strikeslip.txt -W${pensize},black,-   -O -K>> $output #acazaque fault
gmt psxy $proj_map $bound_map $plotdatapath/faults/unknown.txt -W${pensize},black,.-   -O -K>> $output #unknown faults
gmt psxy $proj_map $bound_map $plotdatapath/faults/nm.txt -W${pensize},black,-   -O -K>> $output #normal faults
gmt psxy $proj_map $bound_map $plotdatapath/faults/thrust3.txt -W${pensize},black -Sf${gap}i/${size}i+l+t -Gblack -O -K>> $output #unknown faults
gmt psxy $proj_map $bound_map $plotdatapath/faults/thrust4.txt -W${pensize},black -Sf${gap}i/${size}i+r+t -Gblack -O -K>> $output #unknown faults

##Stations and volcanoes
awk '{print $1,$2}' $stationpath/spuna_stations.txt | gmt psxy $proj_map $bound_map -Sd0.25 -Gcyan -W0.5p,black -O -K >>$output
awk '{print $2,$1}' $plotdatapath/holocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.33 -W0.2p,black -Gmagenta -O -K >>$output
awk '{print $2,$1}' $plotdatapath/pliestocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.33 -W0.2p,black -Gmagenta -O -K >>$output

#Lineaments
gmt psxy $plotdatapath/lineaments.txt $proj_map $bound_map -W0.4p,red,- -O -K >>$output
#plot events
awk '{print $8,$7,$9}' $eventpath_hypodd/catalog_hypodd_puna_crust_v5.txt| gmt psxy $proj_map $bound_map -Sc0.18 -W0.1p -Cdep.cpt -O  -K >>$output
# Plotting focal mechanism
cat $focmecpath/focmec_output.txt |tail -n+1 | awk '{print $4,$3,$5,$7,$8,$9,$6,$4,$3,$1}' | gmt psmeca $proj_map -R -Sa1.5+f12,black+o0/-0.5 -O -K  -Gcoral1  -t5 >> $output

#white box
gmt psxy  $proj_map $bound_map -W0.7,black -Gwhite -O -K << EOF >> $output
-67.1 -27.5
-67.1 -27.7
-66.6 -27.7
-66.6 -27.5
-67.1 -27.5
EOF
#Cross-section lines
echo -66.65 -26.60 "A1" >tmp_map.txt
echo -65.58 -27.15 "B1" >>tmp_map.txt
echo ">>" >> tmp_map.txt
echo -66.85 -26.89 "A2" >>tmp_map.txt
echo -65.8 -27.5 "B2" >>tmp_map.txt
echo ">>" >> tmp_map.txt
gmt psxy $proj_map $bound_map tmp_map.txt -W1p,magenta,-   -O -K>> $output
gmt pstext $proj_map $bound_map tmp_map.txt -F+f14 -W0.7p,magenta -Gwhite -O -K >> $output

#plot scale
gmt set MAP_LABEL_OFFSET 2p
gmt gmtset FONT_ANNOT_PRIMARY = 10p,Helvetica,black
gmt gmtset FONT_LABEL		= 10p
gmt psbasemap  $proj_map $bound_map  -LjBR+c27S+w20k+l+ab+f+o0.9c -P -K -O >> $output

#Plot color scale
gmt psscale -Dx0.2/1.3+w4.2/0.3+h -Cdep.cpt -Ba5+l"Depth (km)" -O >> $output

gmt psconvert -Tg -A1  -E400 $output
gmt psconvert -Tf -A1  -E400 $output

######################################end of map plot####################################################################

######################################Cross-section plot####################################################################gmt gmtset PAPER_MEDIA = A3
gmt gmtset TICK_PEN = 0.5p
gmt gmtset TICK_LENGTH = 0.1c

#parameters
yshift=-9.7
xshift=10
shifttopo=-3.5
proj_cross=" -JX3i/1.15i"
bound_cross="-R0/120/-40/10"
bound_topo="-R0/120/0/8"
Bcross="-Ba20f10:""::,:/a10f5:"Depth\(km\)"::,:WeSn"
Bcross2="-Ba20f10:"Distance\(km\)"::,:/a10f5:"Depth\(km\)"::,:WeSn"
width="-20/20" #Width of box plotting cross-section events

####################################Cross-section 1##############################################
A1="-66.65/-26.60"
B1="-65.58/-27.15"

gmt project -C$A1 -E$B1 -G.2  -Q > topo.xy
gmt grdtrack topo.xy -G$grdpath/dem_puna_resamp.grd > topo.xz
# Padding top and bottom numbers with y value 0 to color the topography
head -1 topo.xz | awk '{print $1, $2, $3, 0}' > top
tail -1 topo.xz | awk '{print $1, $2, $3, 0}' > bottom
cat topo.xz >> top
cat bottom >> top
mv top topo.xz
rm -f bottom
awk '{print $3, $4/1000.0}' topo.xz | gmt psxy $proj_cross $bound_cross $Bcross -Y25  -K -V -G200  > $out_cross

#Background seismicity
awk '{print $8,$7,$9}' $eventpath_hypodd/catalog_hypodd_puna_crust_v5.txt | gmt project -C$A1 -E$B1 -Fxyzpqrs -W$width  -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross $Bcross -Sc0.15  -Ggold -P  -W0.2p -O -K >> $out_cross
#focal mechanism
cat $focmecpath/focmec_output.txt |tail -n+1 | awk '{print $4,$3,-$5,$7,$8,$9,$6,$4,$3,$1}' > eq_cross2.dat
gmt pscoupe eq_cross2.dat $proj_cross $bound_cross $Bcross -Sa0.8/5/-8 -Aa-66.65/-26.60/-65.58/-27.15/90/20/-20/0 -Gcoral1 -O -K -t20 >> $out_cross

#Markers
echo 3 -38 A1 >tmp_text.txt
echo 117 -38 "B1" >>tmp_text.txt
gmt pstext tmp_text.txt $proj_cross $bound_cross -W0.7p -Gwhite -O  -K >> $out_cross
#Projections
gmt project $plotdatapath/pliestocene_volcano.txt -C$A1 -E$B1 -Fxyzpqrs -W$width  -Lw -Q -: > temp_volcano.txt
gmt project $plotdatapath/holocene_volcano.txt -C$A1 -E$B1 -Fxyzpqrs -W$width  -Lw -Q -: >> temp_volcano.txt
awk '{print $4, $3/1000}' temp_volcano.txt | gmt psxy $proj_cross $bound_cross -St0.35 -Gmagenta -W0.01,black -O -K    >> $out_cross
#############################################Cross-section 2###################################################

A2="-66.85/-26.89"
B2="-65.8/-27.50"

#topogrphy
gmt project -C$A2 -E$B2 -G.2  -Q > topo.xy
gmt grdtrack topo.xy -G$grdpath/dem_puna_resamp.grd > topo.xz
head -1 topo.xz | awk '{print $1, $2, $3, 0}' > top
tail -1 topo.xz | awk '{print $1, $2, $3, 0}' > bottom
cat topo.xz >> top
cat bottom >> top
mv top topo.xz
rm -f bottom
awk '{print $3, $4/1000.0}' topo.xz | gmt psxy $proj_cross $bound_cross $Bcross2 -Y$shifttopo -O -K -V -G200 >> $out_cross

#Background seismicity
awk '{print $8,$7,$9}' $eventpath_hypodd/catalog_hypodd_puna_crust_v5.txt | gmt project -C$A2 -E$B2 -Fxyzpqrs -W$width -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross $Bcross -Sc0.15 -P -Ggold -W0.1p -K -O >> $out_cross

cat $focmecpath/focmec_output.txt |tail -n+1 | awk '{print $4,$3,-$5,$7,$8,$9,$6,$4,$3,$1}' > eq_cross2.dat
gmt pscoupe eq_cross2.dat $proj_cross $bound_cross $Bcross -Sa0.8/5/-8 -Aa-66.85/-26.89/-65.8/-27.50/90/20/-20/0 -Gcoral1 -t20  -O -K >> $out_cross

#markers
echo 3 -38 A2 >tmp_text.txt
echo 117 -38 "B2" >>tmp_text.txt
gmt pstext tmp_text.txt $proj_cross $bound_cross -W0.7p -Gwhite -O -K >> $out_cross

gmt project $plotdatapath/pliestocene_volcano.txt -C$A2 -E$B2 -Fxyzpqrs -W$width  -Lw -Q -: > temp_volcano.txt
gmt project $plotdatapath/holocene_volcano.txt -C$A2 -E$B2 -Fxyzpqrs -W$width  -Lw -Q -: >> temp_volcano.txt
awk '{print $4, $3/1000}' temp_volcano.txt | gmt psxy $proj_cross $bound_cross -St0.35 -Gmagenta -W0.01,black  -O -K    >> $out_cross
################################################################################################################

echo "0 0" | gmt psxy -Sc0.001 $proj_cross $bound_cross -O   -W0.001p >> $out_cross

gmt psconvert -Tg -A -E300 $out_cross
gmt psconvert -Tf -A -E300 $out_cross

rm *.cpt *.grd *.txt
rm Aa* *.xz *.xy *.ps
