#Script for plotting Figure 9:

gmt gmtset MAP_FRAME_TYPE="plain"
gmt gmtset PAPER_MEDIA = A3
gmt gmtset FONT_ANNOT_PRIMARY = 13p,Helvetica,black
gmt gmtset FONT_LABEL		= 15p
gmt gmtset FORMAT_GEO_MAP = D

#filepaths
eventpath_velest="/Users/sankha/Desktop/research/Spuna_plateau/velest/output"
eventpath_hypodd="/Users/sankha/Desktop/research/Spuna_plateau/hypodd/output"
stationpath="/Users/sankha/Desktop/research/Spuna_plateau/station"
plotdatapath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/plotdata"
grdpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/grdfiles"
cptpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/cptfiles"
focmecpath="/Users/sankha/Desktop/research/Spuna_plateau/focmec/output"

#change filename as required
output="eventmap_salar_v3.ps"
out_cross="cross_sec_salar_v3.ps"

#cptfiles
gmt makecpt -T0/35/5 -Chot -D -I > dep.cpt

########################################################Map plot#######################################################
bound_map="-R-68.4/-67.2/-26.6/-25.5"
proj_map="-JM6i"
bmap="-Ba.2f.1:""::,:/a.2f.1:""::,:WeSn"

gmt psbasemap  $proj_map $bound_map $bmap -P -K > $output
gmt grdcut $grdpath/dem_puna.grd -Gdem_tmp.grd $bound_map 
gmt grdgradient dem_tmp.grd -Nt1 -A85  -Gtemp_puna.grd
gmt grdimage dem_tmp.grd -Itemp_puna.grd -C$cptpath/white2.cpt $bound_map $proj_map  -O -K -t10>> $output
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
awk '{print $1,$2}' $stationpath/spuna_stations.txt | gmt psxy $proj_map $bound_map -Sd0.27 -Gcyan -W0.5p,black -O -K >>$output
awk '{print $2,$1}' $plotdatapath/holocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.35 -W0.2p,black -Gmagenta -O -K >>$output
awk '{print $2,$1}' $plotdatapath/pliestocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.35 -W0.2p,black -Gmagenta -O -K >>$output

#plot events
awk '{print $8,$7,$9}' $eventpath_hypodd/catalog_hypodd_puna_crust_v5.txt| gmt psxy $proj_map $bound_map -Sc0.20 -W0.1p -Cdep.cpt -O  -K >>$output

# Plotting focal mechanism
#weird bug in gmt
cat $focmecpath/focmec_output.txt |tail -n+1 | awk '{print $4,$3,$5,$7,$8,$9,$6,$4,$3,$1}' | gmt psmeca $proj_map -R  -Sa1.2/8/-10 -O -K -Gcoral1 -t5    >> $output

#cross-section lines
echo -67.84 -25.62 "A1" >tmp_map.txt
echo -67.48 -25.81 "B1" >>tmp_map.txt
echo ">>" >> tmp_map.txt
echo -67.97 -25.81 "A2" >>tmp_map.txt
echo -67.58 -25.95 "B2" >>tmp_map.txt
echo ">>" >> tmp_map.txt
echo -68.03 -25.94 "A3" >>tmp_map.txt
echo -67.63 -26.05 "B3" >>tmp_map.txt
echo ">>" >> tmp_map.txt
echo -68.06 -26.06 "A4" >>tmp_map.txt
echo -67.65 -26.14 "B4" >>tmp_map.txt
echo ">>" >> tmp_map.txt
echo -68.08 -26.18 "A5" >>tmp_map.txt
echo -67.67 -26.22 "B5" >>tmp_map.txt
echo ">>" >> tmp_map.txt
echo -68.12 -26.34 "A6" >>tmp_map.txt
echo -67.71 -26.38 "B6" >>tmp_map.txt

gmt psxy $proj_map $bound_map tmp_map.txt -W1p,magenta,-   -O -K>> $output
gmt pstext $proj_map $bound_map tmp_map.txt -F+f15 -W0.7p,magenta -Gwhite -O -K >> $output

#white box
gmt psxy  $proj_map $bound_map -W0.7,black -Gwhite -O -K << EOF >> $output
-68.4 -26.45
-68.4 -26.6
-68.0 -26.6
-68.0 -26.45
-68.4 -26.45
EOF

#scales
gmt set MAP_LABEL_OFFSET 2p
gmt gmtset FONT_ANNOT_PRIMARY = 10p,Helvetica,black
gmt gmtset FONT_LABEL		= 10p
gmt psbasemap  $proj_map $bound_map  -LjTL+c27S+w20k+l+ab+f+o0.9c -P -K -O >> $output
gmt psscale -D0.15/1.1+w4.2/0.3+h -Cdep.cpt -Ba5+l"Depth (km)" -O >> $output

gmt psconvert -Tg -A1  -E400 $output
gmt psconvert -Tf -A1  -E400 $output

######################################end of map plot####################################################################

######################################Cross-section plot####################################################################

gmt gmtset FONT_ANNOT_PRIMARY = 8p,Helvetica,black
gmt gmtset FONT_LABEL		= 8p
gmt gmtset PAPER_MEDIA = A3
gmt gmtset TICK_PEN = 0.5p
gmt gmtset TICK_LENGTH = 0.1c
yshift=-5.7
xshift=3.7
shifttopo=-3.1
proj_cross=" -JX1.3i/0.9i"
bound_cross="-R0/40/-20/10"
bound_topo="-R0/40/0/8"
Bcross="-Ba10f10:""::,:/a10f5:"Depth\(km\)"::,:WeSn"
Bcross2="-Ba10f10:"Distance\(km\)"::,:/a10f5:"Depth\(km\)"::,:WeSn"
Bcross3="-Ba10f10:""::,:/a10f5:""::,:weSn"
Bcross4="-Ba10f10:"Distance\(km\)"::,:/a10f5:""::,:weSn"
width="-7/7" #Width of box plotting cross-section events

####################################Cross-section 1##############################################

A1="-67.84/-25.62"
B1="-67.48/-25.81"

#topogrphy
Btopo="-Ba20f10:::,:/a4f1:"elevation-km"::,:Wen"
Btopo2="-Ba30f10:"Distance-km"::,:/a10f5:"Depth-km"::,:Wen"
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
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross $Bcross -Sc0.12  -Ggold -P  -W0.2p -O -K >> $out_cross

#Event locations for the ones having focal mechanism
awk '{print $8,$9,$11}' $focmecpath/focmec_salar_orig.txt | gmt project -C$A1 -E$B1 -Fxyzpqrs -W$width -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross -Sc0.12 -P -Gcoral1 -W0.1p -K -O >> $out_cross

#Focal mechanism plot where the locations have been shifted to move the focal mechanism to different location
cat $focmecpath/focmec_salar.txt | awk '{print $0}' > eq_cross2.dat
gmt pscoupe eq_cross2.dat $proj_cross $bound_cross $Bcross -Sa0.8/6/-9 -Aa-67.84/-25.62/-67.48/-25.81/90/8/-8/0 -Gcoral1 -O -K -t20 >> $out_cross

#Markers
echo 2 -18 A1 >tmp_text.txt
echo 38 -18 "B1" >>tmp_text.txt
gmt pstext tmp_text.txt $proj_cross $bound_cross -W0.7p -Gwhite -O  -K >> $out_cross

gmt project $plotdatapath/pliestocene_volcano.txt -C$A1 -E$B1 -Fxyzpqrs -W$width  -Lw -Q -: > temp_volcano.txt
gmt project $plotdatapath/holocene_volcano.txt -C$A1 -E$B1 -Fxyzpqrs -W$width  -Lw -Q -: >> temp_volcano.txt
awk '{print $4, $3/1000}' temp_volcano.txt | gmt psxy $proj_cross $bound_cross -St0.35 -Gmagenta -W0.01,black -O -K    >> $out_cross


#############################################Cross-section 2###################################################

A2="-67.97/-25.81"
B2="-67.58/-25.95"

#topogrphy
gmt project -C$A2 -E$B2 -G.2  -Q > topo.xy
gmt grdtrack topo.xy -G$grdpath/dem_puna_resamp.grd > topo.xz
# Padding top and bottom numbers with y value 0 to color the topography
head -1 topo.xz | awk '{print $1, $2, $3, 0}' > top
tail -1 topo.xz | awk '{print $1, $2, $3, 0}' > bottom
cat topo.xz >> top
cat bottom >> top
mv top topo.xz
rm -f bottom
awk '{print $3, $4/1000.0}' topo.xz | gmt psxy $proj_cross $bound_cross $Bcross -Y$shifttopo -O -K -V -G200 >> $out_cross

#Background seismicity
awk '{print $8,$7,$9}' $eventpath_hypodd/catalog_hypodd_puna_crust_v5.txt | gmt project -C$A2 -E$B2 -Fxyzpqrs -W$width -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross $Bcross -Sc0.12 -P -Ggold -W0.1p -K -O >> $out_cross

awk '{print $8,$9,$11}' $focmecpath/focmec_salar_orig.txt | gmt project -C$A2 -E$B2 -Fxyzpqrs -W$width -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross -Sc0.12 -P -Gcoral1 -W0.1p -K -O >> $out_cross

gmt pscoupe eq_cross2.dat $proj_cross $bound_cross $Bcross -Sa0.8/6/-9 -Aa-67.97/-25.81/-67.58/-25.95/90/8/-8/0 -Gcoral1 -t20  -O -K >> $out_cross


#markers
echo 2 -18 A2 >tmp_text.txt
echo 38 -18 "B2" >>tmp_text.txt
gmt pstext tmp_text.txt $proj_cross $bound_cross -W0.7p -Gwhite -O -K >> $out_cross

gmt project $plotdatapath/pliestocene_volcano.txt -C$A2 -E$B2 -Fxyzpqrs -W$width  -Lw -Q -: > temp_volcano.txt
gmt project $plotdatapath/holocene_volcano.txt -C$A2 -E$B2 -Fxyzpqrs -W$width  -Lw -Q -: >> temp_volcano.txt
awk '{print $4, -0.2+$3/1000}' temp_volcano.txt | gmt psxy $proj_cross $bound_cross -St0.35 -Gmagenta -W0.01,black  -O -K    >> $out_cross


##############################################Cross-section 3###################################################

A3="-68.03/-25.94"
B3="-67.63/-26.05"

#topogrphy
gmt project -C$A3 -E$B3 -G.2  -Q > topo.xy
gmt grdtrack topo.xy -G$grdpath/dem_puna_resamp.grd > topo.xz
# Padding top and bottom numbers with y value 0 to color the topography
head -1 topo.xz | awk '{print $1, $2, $3, 0}' > top
tail -1 topo.xz | awk '{print $1, $2, $3, 0}' > bottom
cat topo.xz >> top
cat bottom >> top
mv top topo.xz
rm -f bottom
awk '{print $3, $4/1000.0}' topo.xz | gmt psxy $proj_cross $bound_cross $Bcross2  -Y$shifttopo -O -K -V -G200 >> $out_cross

#Background seismicity
awk '{print $8,$7,$9}' $eventpath_hypodd/catalog_hypodd_puna_crust_v5.txt | gmt project -C$A3 -E$B3 -Fxyzpqrs -W$width  -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross $Bcross2 -Sc0.12 -Ggold   -P -O -W0.1p -K >> $out_cross

awk '{print $8,$9,$11}' $focmecpath/focmec_salar_orig.txt | gmt project -C$A3 -E$B3 -Fxyzpqrs -W$width -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross -Sc0.12 -P -Gcoral1 -W0.1p -K -O >> $out_cross

gmt pscoupe eq_cross2.dat $proj_cross $bound_cross $Bcross2 -Sa0.8/6/-9 -Aa-68.03/-25.94/-67.63/-26.05/90/5/-5/0  -Gcoral1 -O -K -t20>> $out_cross

#markers
echo 2 -18 A3 >tmp_text.txt
echo 38 -18 "B3" >>tmp_text.txt

gmt project $plotdatapath/pliestocene_volcano.txt -C$A3 -E$B3 -Fxyzpqrs -W$width  -Lw -Q -: > temp_volcano.txt
gmt project $plotdatapath/holocene_volcano.txt -C$A3 -E$B3 -Fxyzpqrs -W$width  -Lw -Q -: >> temp_volcano.txt
awk '{print $4, -1+$3/1000}' temp_volcano.txt | gmt psxy $proj_cross $bound_cross -St0.35 -Gmagenta -W0.01,black -O -K    >> $out_cross
gmt pstext tmp_text.txt $proj_cross $bound_cross -W0.7p -Gwhite -O -K >> $out_cross


##############################################Cross-section 4###################################################

A4="-68.06/-26.06"
B4="-67.65/-26.14"

#topogrphy
gmt project -C$A4 -E$B4 -G.2  -Q > topo.xy
gmt grdtrack topo.xy -G$grdpath/dem_puna_resamp.grd > topo.xz
# Padding top and bottom numbers with y value 0 to color the topography
head -1 topo.xz | awk '{print $1, $2, $3, 0}' > top
tail -1 topo.xz | awk '{print $1, $2, $3, 0}' > bottom
cat topo.xz >> top
cat bottom >> top
mv top topo.xz
rm -f bottom
awk '{print $3, $4/1000.0}' topo.xz | gmt psxy $proj_cross $bound_cross $Bcross3 -X$xshift -Y6.2 -O -K -V -G200 >> $out_cross

#Background seismicity
awk '{print $8,$7,$9}' $eventpath_hypodd/catalog_hypodd_puna_crust_v5.txt| gmt project -C$A4 -E$B4 -Fxyzpqrs -W$width  -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross $Bcross3 -Sc0.12  -Ggold -O -P  -W0.1p -K >> $out_cross

awk '{print $8,$9,$11}' $focmecpath/focmec_salar_orig.txt | gmt project -C$A4 -E$B4 -Fxyzpqrs -W$width -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross  -Sc0.12 -P -Gcoral1 -W0.1p -K -O >> $out_cross

gmt pscoupe eq_cross2.dat $proj_cross $bound_cross $Bcross3 -Sa0.8/6/-9 -Aa-68.06/-26.06/-67.65/-26.14/90/5/-5/0 -Gcoral1 -O -K -t20 >> $out_cross

#markers
echo 2 -18 A4 >tmp_text.txt
echo 38 -18 "B4" >>tmp_text.txt
gmt pstext tmp_text.txt $proj_cross $bound_cross -W0.7p -Gwhite -O  -K >> $out_cross

gmt project $plotdatapath/pliestocene_volcano.txt -C$A4 -E$B4 -Fxyzpqrs -W$width  -Lw -Q -: > temp_volcano.txt
gmt project $plotdatapath/holocene_volcano.txt -C$A4 -E$B4 -Fxyzpqrs -W$width  -Lw -Q -: >> temp_volcano.txt
awk '{print $4, -0.5+$3/1000}' temp_volcano.txt | gmt psxy $proj_cross $bound_cross -St0.35 -Gmagenta -W0.01,black -O -K    >> $out_cross

########################################Cross-section 5#########################################################################
A5="-68.08/-26.18"
B5="-67.67/-26.22"

#topogrphy
gmt project -C$A5 -E$B5 -G.2  -Q > topo.xy
gmt grdtrack topo.xy -G$grdpath/dem_puna_resamp.grd > topo.xz
# Padding top and bottom numbers with y value 0 to color the topography
head -1 topo.xz | awk '{print $1, $2, $3, 0}' > top
tail -1 topo.xz | awk '{print $1, $2, $3, 0}' > bottom
cat topo.xz >> top
cat bottom >> top
mv top topo.xz
rm -f bottom
awk '{print $3, $4/1000.0}' topo.xz | gmt psxy $proj_cross $bound_cross $Bcross3  -Y$shifttopo -O -K -V -G200 >> $out_cross

#Background seismicity
awk '{print $8,$7,$9}' $eventpath_hypodd/catalog_hypodd_puna_crust_v5.txt| gmt project -C$A5 -E$B5 -Fxyzpqrs -W$width  -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross $Bcross3 -Sc0.12  -Ggold -O -P  -W0.1p -K >> $out_cross

awk '{print $8,$9,$11}' $focmecpath/focmec_salar_orig.txt | gmt project -C$A5 -E$B5 -Fxyzpqrs -W$width -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross -Sc0.12 -P -Gcoral1 -W0.1p -K -O >> $out_cross

gmt pscoupe eq_cross2.dat $proj_cross $bound_cross $Bcross3 -Sa0.8/6/-9 -Aa-68.08/-26.18/-67.67/-26.22/90/8/-8/0 -Gcoral1 -O -K -t20 >> $out_cross

#markers
echo 2 -18 A5 >tmp_text.txt
echo 38 -18 "B5" >>tmp_text.txt
gmt pstext tmp_text.txt $proj_cross $bound_cross -W0.7p -Gwhite -O  -K >> $out_cross

gmt project $plotdatapath/pliestocene_volcano.txt -C$A5 -E$B5 -Fxyzpqrs -W$width  -Lw -Q -: > temp_volcano.txt
gmt project $plotdatapath/holocene_volcano.txt -C$A5 -E$B5 -Fxyzpqrs -W$width  -Lw -Q -: >> temp_volcano.txt
awk '{print $4, -0.5+$3/1000}' temp_volcano.txt | gmt psxy $proj_cross $bound_cross -St0.35 -Gmagenta -W0.01,black -O -K    >> $out_cross

################################Cross-section 6#################################################
A6="-68.12/-26.34"
B6="-67.71/-26.38"

#topogrphy
gmt project -C$A6 -E$B6 -G.2  -Q > topo.xy
gmt grdtrack topo.xy -G$grdpath/dem_puna_resamp.grd > topo.xz
# Padding top and bottom numbers with y value 0 to color the topography
head -1 topo.xz | awk '{print $1, $2, $3, 0}' > top
tail -1 topo.xz | awk '{print $1, $2, $3, 0}' > bottom
cat topo.xz >> top
cat bottom >> top
mv top topo.xz
rm -f bottom
awk '{print $3, $4/1000.0}' topo.xz | gmt psxy $proj_cross $bound_cross $Bcross4  -Y$shifttopo -O -K -V -G200 >> $out_cross

#Background seismicity
awk '{print $8,$7,$9}' $eventpath_hypodd/catalog_hypodd_puna_crust_v5.txt| gmt project -C$A6 -E$B6 -Fxyzpqrs -W$width  -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross $Bcross4 -Sc0.12  -Ggold -O -P  -W0.1p -K >> $out_cross

awk '{print $8,$9,$11}' $focmecpath/focmec_salar_orig.txt | gmt project -C$A6 -E$B6 -Fxyzpqrs -W$width -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross  -Sc0.12 -P -Gcoral1 -W0.1p -K -O >> $out_cross

gmt pscoupe eq_cross2.dat $proj_cross $bound_cross $Bcross4 -Sa0.8/6/-9 -Aa-68.12/-26.34/-67.71/-26.38/90/8/-8/0 -Gcoral1 -O -K -t20 >> $out_cross

#markers
echo 2 -18 A6 >tmp_text.txt
echo 38 -18 "B6" >>tmp_text.txt
gmt pstext tmp_text.txt $proj_cross $bound_cross -W0.7p -Gwhite -O  -K >> $out_cross

gmt project $plotdatapath/pliestocene_volcano.txt -C$A6 -E$B6 -Fxyzpqrs -W$width  -Lw -Q -: > temp_volcano.txt
gmt project $plotdatapath/holocene_volcano.txt -C$A6 -E$B6 -Fxyzpqrs -W$width  -Lw -Q -: >> temp_volcano.txt
awk '{print $4, -0.5+$3/1000}' temp_volcano.txt | gmt psxy $proj_cross $bound_cross -St0.35 -Gmagenta -W0.01,black -O -K    >> $out_cross

#############################################################################################
echo "0 0" | gmt psxy -Sc0.001 $proj_cross $bound_cross -O   -W0.001p >> $out_cross
gmt psconvert -Tg -A -E500 $out_cross
gmt psconvert -Tf -A -E500 $out_cross
rm Aa*
rm  *.xz *.xy *.cpt *.grd *.txt *.ps 