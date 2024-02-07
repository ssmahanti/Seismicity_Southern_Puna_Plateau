#Script for plotting figure 12:
gmt set MAP_FRAME_TYPE plain
gmt set MAP_FRAME_WIDTH 5p
gmt set MAP_TICK_PEN_PRIMARY 0.5p
gmt set FONT_ANNOT_PRIMARY 8p,Helvetica,black
gmt set PS_PAGE_ORIENTATION LANDSCAPE
gmt set FORMAT_GEO_MAP=D


eventpath_hypodd="/Users/sankha/Desktop/research/Spuna_plateau/hypodd/output"
stationpath="/Users/sankha/Desktop/research/Spuna_plateau/station"
plotdatapath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/plotdata"
grdpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/grdfiles"
cptpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/cptfiles"
modelpath="/Users/sankha/Desktop/research/Spuna_plateau/lotos/output"

#change filename as required
output1="galan_map.ps"

#cptfiles
gmt makecpt -T0/35/5 -Chot -D -I > dep.cpt
gmt makecpt -T3.2/4.1/0.1 -Cseis -D  > tomo.cpt

########################################################Map plot#######################################################
bound_map="-R-67.3/-66.5/-26.2/-25.7"
proj_map="-JM4i"
bmap="-Ba.2f.1:""::,:/a.2f.1:""::,:WeSn"

gmt psbasemap  $proj_map $bound_map $bmap -P -K > $output1
gmt grdcut $grdpath/dem_puna.grd -Gdem_tmp.grd $bound_map 
gmt grdgradient dem_tmp.grd -Nt1 -A75  -Gtemp_puna.grd
gmt grdimage dem_tmp.grd -Itemp_puna.grd -C$cptpath/white2.cpt $bound_map $proj_map  -O -K -t25>> $output1

#faults
pensize=0.3
gap=0.2
size=0.02
gmt psxy $proj_map $bound_map $plotdatapath/faults/thrust1.txt -W${pensize},black -Sf${gap}i/${size}i+l+t -Gblack -O -K>> $output1 #Thrust to left of calastre
gmt psxy $proj_map $bound_map $plotdatapath/faults/thrust2.txt -W${pensize},black -Sf${gap}i/${size}i+r+t -Gblack -O -K>> $output1 #Thrust to right of calastre
gmt psxy $proj_map $bound_map $plotdatapath/faults/strikeslip.txt -W${pensize},black   -O -K>> $output1 #acazaque fault
gmt psxy $proj_map $bound_map $plotdatapath/faults/unknown.txt -W${pensize},black,.-   -O -K>> $output1 #unknown faults
gmt psxy $proj_map $bound_map $plotdatapath/faults/nm.txt -W${pensize},black,-   -O -K>> $output1 #normal faults
gmt psxy $proj_map $bound_map $plotdatapath/faults/thrust3.txt -W${pensize},black -Sf${gap}i/${size}i+l+t -Gblack -O -K>> $output1 #unknown faults
gmt psxy $proj_map $bound_map $plotdatapath/faults/thrust4.txt -W${pensize},black -Sf${gap}i/${size}i+r+t -Gblack -O -K>> $output1 #unknown faults

##Stations and volcanoes
awk '{print $1,$2}' $stationpath/spuna_stations.txt | gmt psxy $proj_map $bound_map -Sd0.24 -Gcyan -W0.5p,black -O -K >>$output1
awk '{print $2,$1}' $plotdatapath/holocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.35 -W0.2p,black -Gmagenta -O -K >>$output1
awk '{print $2,$1}' $plotdatapath/pliestocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.35 -W0.2p,black -Gmagenta -O -K >>$output1

#swarm events
awk '{print $8,$7,$9}' galan_swarm_events_hypodd_v5.dat | gmt psxy $proj_map $bound_map -Sc0.13 -W0.1p -Cdep.cpt -O  -K >>$output1

#white box
gmt psxy  $proj_map $bound_map -W0.7,black -Gwhite -O -K << EOF >> $output1
-67.30 -26.1
-67.30 -26.2
-67.05 -26.2
-67.05 -26.1
-67.30 -26.1
EOF

#cross-section line
echo -67.15 -25.93 "A" >tmp_map.txt
echo -66.65 -25.93 "B" >>tmp_map.txt
gmt psxy $proj_map $bound_map tmp_map.txt -W0.4p,magenta,-  -O -K>> $output1
gmt pstext $proj_map $bound_map tmp_map.txt -F+f10 -W0.7p,magenta -Gwhite -O -K >> $output1

#scale
gmt gmtset FONT_ANNOT_PRIMARY = 7p,Helvetica,black
gmt gmtset FONT_LABEL		= 7p
gmt psbasemap  $proj_map $bound_map  -LjBR+c27S+w10k+l+ab+f+o0.5c -P -K -O >> $output1
gmt psscale -Dx0.1/0.8+w2.8/0.3+h -Cdep.cpt -Ba5+l"Depth (km)" -O >> $output1 #color scale

gmt psconvert -Tg -A1  -E400 $output1
gmt psconvert -Tf -A1  -E400 $output1

######################################end of map plot####################################################################

######################################Cross-section plot####################################################################
gmt gmtset FONT_ANNOT_PRIMARY 10p,Helvetica,black
gmt gmtset FONT_LABEL		= 10p

out_cross="cross_swarm_hypodd.ps"

A="-67.15/-25.93"
B="-66.65/-25.93"
Bcross="-Ba5f5:"Distance\(km\)"::,:/a5f5:"Depth\(km\)"::,:WeSn"
proj_cross=" -JX4i/2i"
bound_cross="-R0/40/-10/8"
width="-20/20" #Width of box plotting cross-section events

cat galan_swarm_events_hypodd_v5.dat| awk '{print $8,$7,$9}'| gmt project -C$A -E$B -Fxyzpqrs -W$width  -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross $Bcross -Sc0.18  -Gred  -P  -W0.1p -K  > $out_cross

gmt project -C$A -E$B -G.2  -Q > topo.xy
gmt grdtrack topo.xy -G$grdpath/dem_puna_resamp.grd > topo.xz
head -1 topo.xz | awk '{print $1, $2, $3, 0}' > top
tail -1 topo.xz | awk '{print $1, $2, $3, 0}' > bottom
cat topo.xz >> top
cat bottom >> top
mv top topo.xz
rm -f bottom
awk '{print $3, $4/1000.0}' topo.xz | gmt psxy $proj_cross $bound_cross $Bcross   -O -K -V  >> $out_cross

echo " 1 6.2 A" | gmt pstext $proj_cross $bound_cross -F+f10  -W0.4p -O -K >> $out_cross
echo " 39 6.2 B" | gmt pstext $proj_cross $bound_cross -F+f10  -W0.4p -O -K >> $out_cross
echo "-66.92 -25.93 5.7" | gmt project -C$A -E$B -Fxyzpqrs -W-5/5  -Lw -Q  > temp_galloc.txt
awk '{print $4, $3}' temp_galloc.txt | gmt psxy $proj_cross $bound_cross -St0.35 -Gmagenta -W0.01,black -O     >> $out_cross
	
gmt psconvert -Tg -A $out_cross -E500
gmt psconvert -Tf -A $out_cross -E500

#######################################Velmodel plot#################################################################################
gmt set MAP_FRAME_PEN 0.4p
gmt set MAP_TICK_PEN_PRIMARY 0.4p
gmt set MAP_TICK_LENGTH 2p
gmt set MAP_ANNOT_OFFSET_PRIMARY 1p
gmt set FONT 5p,Helvetica,black

proj_cross=" -JX1.4i/0.7i"
Bcross="-Ba10f5:"Distance\(km\)"::,:/a3f1:"Depth\(km\)"::,:WeSn"
bound_cross="-R0/40/-10/7"

output="cross_abs_galan.ps"
	
###################Velmodel P#####################################################

A1="-67.15/-25.93"
B1="-66.65/-25.93"

gmt psbasemap  $proj_cross $bound_cross $Bcross  -P -Y15 -K > $output
	
#Plotting velocity model	
awk '{print $1,$2,$3,$4,$5}'  $modelpath/velmodel_coord_p.dat | gmt project -C$A1 -E$B1 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_tomo.txt
awk '{print $6,-$3,$4+$5}' temp_tomo.txt  | gmt blockmean $bound_cross -I0.5/0.5 -C > temp1.xyz
gmt surface temp1.xyz -I0.04/0.04  $bound_cross -Gtemp1.grd  
gmt grd2cpt temp1.grd  -C$cptpath/temper.cpt -I  -M -S5.3/6.4/0.02 > tomo.cpt
gmt grdimage temp1.grd -Ctomo.cpt $bound_cross $proj_cross -O -K  >> $output

#Masking by semblance
awk '{print $1,$2,$3,$4}'  $modelpath/semblance_average_chk20_coord_comb.dat| gmt project -C$A1 -E$B1 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_sem.txt
awk '{ if ( $4>=0.65 ) print $5,-$3,$4}' temp_sem.txt | gmt psmask  $bound_cross -I5/1 -S1  $proj_cross  -O -K -N -Gwhite >>$output
gmt psmask   -C  -O -K  >>$output

#Plotting earthquakes
awk '{print $8,$7,$9}' galan_swarm_events_hypodd_v5.dat | gmt project -C$A1 -E$B1 -Fxyzpqrs -W-5/5  -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross $Bcross -Sc0.07  -Gred  -P  -W0.05p -O -K >> $output

#Plotting topography
gmt project -C$A1 -E$B1 -G.2  -Q > topo.xy
gmt grdtrack topo.xy -G$grdpath/dem_puna_resamp.grd > topo.xz
head -1 topo.xz | awk '{print $1, $2, $3, 0}' > top
tail -1 topo.xz | awk '{print $1, $2, $3, 0}' > bottom
cat topo.xz >> top
cat bottom >> top
mv top topo.xz
rm -f bottom
awk '{print $3, $4/1000.0}' topo.xz | gmt psxy $proj_cross $bound_cross $Bcross   -O -K -V  >> $output

#Plotting volcano
awk '{print $2,$1,$3}' $plotdatapath/holocene_volcano.txt > temp_volcano.txt
awk '{print $2,$1,$3}' $plotdatapath/pliestocene_volcano.txt >> temp_volcano.txt
gmt project temp_volcano.txt -C$A1 -E$B1 -W-5/5 -Fxyzpqrs -Lw -Q  > temp_galloc.txt
awk '{print $4, $3/1000.0}' temp_galloc.txt | gmt psxy $proj_cross $bound_cross -St0.15 -Gmagenta -W0.01,black -O -K    >> $output

#Plotting scale and marker
gmt psscale -Dx3.8/0.1+w1.2/0.2+e -Ctomo.cpt -Ba0.3+l"Vp(km/s)" -G5.3/6.38 -O -K  >> $output
echo " 1 5.7 A" | gmt pstext $proj_cross $bound_cross -F+f5  -W0.4p -O -K >> $output
echo " 39 5.7 B" | gmt pstext $proj_cross $bound_cross -F+f5  -W0.4p -O -K >> $output

###################Velmodel S#####################################################

gmt psbasemap  $proj_cross $bound_cross $Bcross  -P -Y-2.4 -O -K >> $output
	
#Plotting velocity model	
awk '{print $1,$2,$3,$4,$5}'   $modelpath/velmodel_coord_s.dat | gmt project -C$A1 -E$B1 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_tomo.txt
awk '{print $6,-$3,$4+$5}' temp_tomo.txt  | gmt blockmean $bound_cross -I0.5/0.5 -C > temp1.xyz
gmt surface temp1.xyz -I0.04/0.04  $bound_cross -Gtemp1.grd  
gmt grd2cpt temp1.grd  -C$cptpath/temper.cpt -I  -M -S3.15/3.80/0.02 > tomo.cpt
gmt grdimage temp1.grd -Ctomo.cpt $bound_cross $proj_cross -O -K  >> $output

#Masking by semblance
awk '{print $1,$2,$3,$4}'   $modelpath/semblance_average_chk20_coord_comb.dat | gmt project -C$A1 -E$B1 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_sem.txt
awk '{ if ( $4>=0.65 ) print $5,-$3,$4}' temp_sem.txt | gmt psmask  $bound_cross -I5/1 -S1  $proj_cross  -O -K -N -Gwhite >>$output
gmt psmask   -C  -O -K  >>$output

#Plotting earthquakes
awk '{print $8,$7,$9}' galan_swarm_events_hypodd_v5.dat | gmt project -C$A1 -E$B1 -Fxyzpqrs -W-5/5  -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross $Bcross -Sc0.07  -Gred  -P  -W0.05p -O -K >> $output

#Plotting topography
gmt project -C$A1 -E$B1 -G.2  -Q > topo.xy
gmt grdtrack topo.xy -G$grdpath/dem_puna_resamp.grd > topo.xz
head -1 topo.xz | awk '{print $1, $2, $3, 0}' > top
tail -1 topo.xz | awk '{print $1, $2, $3, 0}' > bottom
cat topo.xz >> top
cat bottom >> top
mv top topo.xz
rm -f bottom
awk '{print $3, $4/1000.0}' topo.xz | gmt psxy $proj_cross $bound_cross $Bcross   -O -K -V  >> $output

#Plotting volcano
awk '{print $2,$1,$3}' $plotdatapath/holocene_volcano.txt > temp_volcano.txt
awk '{print $2,$1,$3}' $plotdatapath/pliestocene_volcano.txt >> temp_volcano.txt
gmt project temp_volcano.txt -C$A1 -E$B1 -W-5/5 -Fxyzpqrs -Lw -Q  > temp_galloc.txt
awk '{print $4, $3/1000.0}' temp_galloc.txt | gmt psxy $proj_cross $bound_cross -St0.15 -Gmagenta -W0.01,black -O -K    >> $output

#Plotting scale and marker
gmt psscale -Dx3.8/0.1+w1.2/0.2+e -Ctomo.cpt -Ba0.2+l"Vs(km/s)" -G3.15/3.75 -O -K  >> $output
echo " 1 5.7 A" | gmt pstext $proj_cross $bound_cross -F+f5  -W0.4p -O -K >> $output
echo " 39 5.7 B" | gmt pstext $proj_cross $bound_cross -F+f5  -W0.4p -O  >> $output

gmt psconvert -A1 -Tg -E400 $output
gmt psconvert -A1 -Tf -E400 $output

rm *.ps *.cpt *.txt *.xz *.xy *.xyz *.grd