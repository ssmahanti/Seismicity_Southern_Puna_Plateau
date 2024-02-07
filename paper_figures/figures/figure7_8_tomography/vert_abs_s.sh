#Cross-section velocity plot:S

gmt gmtset PAPER_MEDIA = A2
gmt gmtset FONT_ANNOT_PRIMARY = 6p,Helvetica,black
gmt gmtset FONT_LABEL		= 6p

proj_cross=" -JX3i/0.6i"
Bcross="-Ba50f10:""::,:/a3f1:"Depth\(km\)"::,:WeSn"
Bcross2="-Ba50f10:"Distance\(km\)"::,:/a3f1:"Depth\(km\)"::,:WeSn"
bound_cross="-R0/218/-10/7"
bound_cross2="-R0/218/-10/7"

#FILES
stationpath="/Users/sankha/Desktop/research/Spuna_plateau/station"
plotdatapath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/plotdata"
grdpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/grdfiles"
cptpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/cptfiles"
modelpath="/Users/sankha/Desktop/research/Spuna_plateau/lotos/output"
eqpath="/Users/sankha/Desktop/research/Spuna_plateau/hypodd/output"
output="velmodel_cross_v1_s.ps"

crange="3.0/3.9/0.02"

##########################CROSS-SECTION 1##################################
A1="-68.3/-25.93"
B1="-66.1/-25.93"

gmt psbasemap  $proj_cross $bound_cross $Bcross  -P -Y15 -K > $output
	
#Plotting velocity model	
awk '{print $1,$2,$3,$4,$5}'  $modelpath/velmodel_coord_s.dat | gmt project -C$A1 -E$B1 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_tomo.txt
awk '{print $6,-$3,$4+$5}' temp_tomo.txt  | gmt blockmean $bound_cross2 -I2/2 -C > temp1.xyz
gmt surface temp1.xyz -I0.05/0.05  $bound_cross2 -Gtemp1.grd  
gmt grd2cpt temp1.grd  -C$cptpath/temper.cpt -I  -M -S$crange > tomo.cpt
gmt grdimage temp1.grd -Ctomo.cpt $bound_cross $proj_cross -O -K  >> $output

#Masking by semblance
awk '{print $1,$2,$3,$4}'  $modelpath/semblance_average_chk20_coord_comb.dat | gmt project -C$A1 -E$B1 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_sem.txt
awk '{ if ( $4>=0.65 ) print $5,-$3,$4}' temp_sem.txt | gmt psmask  $bound_cross -I5/1 -S1  $proj_cross  -O -K -N -Gwhite >>$output
gmt psmask   -C  -O -K  >>$output

#Plotting earthquakes
awk '{print $8,$7,$9}' $eqpath/catalog_hypodd_puna_crust_v5.txt | gmt project -C$A1 -E$B1 -Fxyzpqrs -W-5/5  -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross $Bcross -Sc0.07  -Gred  -P  -W0.05p -O -K >> $output

#Plotting topography
gmt project -C$A1 -E$B1 -G.2  -Q > topo.xy
gmt grdtrack topo.xy -G$grdpath/dem_puna_resamp.grd > topo.xz
# Padding top and bottom numbers with y value 0 to color the topography
head -1 topo.xz | awk '{print $1, $2, $3, 0}' > top
tail -1 topo.xz | awk '{print $1, $2, $3, 0}' > bottom
cat topo.xz >> top
cat bottom >> top
mv top topo.xz
rm -f bottom
awk '{print $3, $4/1000.0}' topo.xz | gmt psxy $proj_cross $bound_cross $Bcross   -O -K -V  >> $output

#Plotting vents
awk '{print $1,$2}' $plotdatapath/puna_mafic_vents.txt | gmt project -C$A1 -E$B1 -Fxypqrs -W-5/5  -Lw -Q > temp_sa.txt
awk '{print $3,4.1}' temp_sa.txt | gmt psxy $proj_cross $bound_cross $Bcross -Ss0.15  -Gorange -P  -W0.08p -O -K >> $output
#Plotting volcano
awk '{print $2,$1,$3}' $plotdatapath/holocene_volcano.txt > temp_volcano.txt
awk '{print $2,$1,$3}' $plotdatapath/pliestocene_volcano.txt >> temp_volcano.txt
gmt project temp_volcano.txt -C$A1 -E$B1 -W-5/5 -Fxyzpqrs -Lw -Q  > temp_galloc.txt
awk '{print $4, $3/1000.0}' temp_galloc.txt | gmt psxy $proj_cross $bound_cross -St0.15 -Gmagenta -W0.01,black -O -K    >> $output

#Plotting scale and marker
echo " 5 5.2 A1" | gmt pstext $proj_cross $bound_cross -F+f5  -W0.4p -O -K >> $output
echo " 213 5.2 B1" | gmt pstext $proj_cross $bound_cross -F+f5  -W0.4p -O -K >> $output
	
##########################CROSS-SECTION 2##################################
A2="-68.3/-26.15"
B2="-66.1/-26.15"

gmt psbasemap  $proj_cross $bound_cross $Bcross -O -P -Y-2.1 -K >> $output
	
#Plotting velocity model	
awk '{print $1,$2,$3,$4,$5}'  $modelpath/velmodel_coord_s.dat | gmt project -C$A2 -E$B2 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_tomo.txt
awk '{print $6,-$3,$4+$5}' temp_tomo.txt  | gmt blockmean $bound_cross2 -I1/1 -C > temp1.xyz
gmt surface temp1.xyz -I0.05/0.05  $bound_cross2 -Gtemp1.grd  
gmt grd2cpt temp1.grd  -C$cptpath/temper.cpt -I  -M -S$crange > tomo.cpt
gmt grdimage temp1.grd -Ctomo.cpt $bound_cross $proj_cross -O -K  >> $output

#Masking by semblance
awk '{print $1,$2,$3,$4}'   $modelpath/semblance_average_chk20_coord_comb.dat | gmt project -C$A2 -E$B2 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_sem.txt
awk '{ if ( $4>=0.65 ) print $5,-$3,$4}' temp_sem.txt | gmt psmask  $bound_cross -I5/1 -S1  $proj_cross  -O -K -N -Gwhite >>$output
gmt psmask   -C  -O -K  >>$output

#Plotting earthquakes
awk '{print $8,$7,$9}' $eqpath/catalog_hypodd_puna_crust_v5.txt | gmt project -C$A2 -E$B2 -Fxyzpqrs -W-5/5  -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross $Bcross -Sc0.07  -Gred  -P  -W0.05p -O -K >> $output

#Plotting topography
gmt project -C$A2 -E$B2 -G.2  -Q > topo.xy
gmt grdtrack topo.xy -G$grdpath/dem_puna_resamp.grd > topo.xz
# Padding top and bottom numbers with y value 0 to color the topography
head -1 topo.xz | awk '{print $1, $2, $3, 0}' > top
tail -1 topo.xz | awk '{print $1, $2, $3, 0}' > bottom
cat topo.xz >> top
cat bottom >> top
mv top topo.xz
rm -f bottom
awk '{print $3, $4/1000.0}' topo.xz | gmt psxy $proj_cross $bound_cross $Bcross   -O -K -V  >> $output

#Plotting vents
awk '{print $1,$2}' $plotdatapath/puna_mafic_vents.txt | gmt project -C$A2 -E$B2 -Fxypqrs -W-5/5  -Lw -Q > temp_sa.txt
awk '{print $3,4.1}' temp_sa.txt | gmt psxy $proj_cross $bound_cross $Bcross -Ss0.15  -Gorange -P  -W0.08p -O -K >> $output
#Plotting VOLCANO
awk '{print $2,$1,$3}' $plotdatapath/holocene_volcano.txt > temp_volcano.txt
awk '{print $2,$1,$3}' $plotdatapath/pliestocene_volcano.txt >> temp_volcano.txt
gmt project temp_volcano.txt -C$A2 -E$B2  -W-5/5 -Fxyzpqrs -Lw -Q  > temp_galloc.txt
awk '{print $4, $3/1000.0}' temp_galloc.txt | gmt psxy $proj_cross $bound_cross -St0.15 -Gmagenta -W0.01,black -O -K    >> $output

#Plotting scale and marker
echo " 5 5.2 A2" | gmt pstext $proj_cross $bound_cross -F+f5  -W0.4p -O -K >> $output
echo " 213 5.2 B2" | gmt pstext $proj_cross $bound_cross -F+f5  -W0.4p -O -K >> $output

##########################CROSS-SECTION 3##################################
A3="-68.3/-26.42"
B3="-66.1/-26.42"

gmt psbasemap  $proj_cross $bound_cross $Bcross -O -P -Y-2.1 -K >> $output
	
#Plotting velocity model	
awk '{print $1,$2,$3,$4,$5}'  $modelpath/velmodel_coord_s.dat | gmt project -C$A3 -E$B3 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_tomo.txt
awk '{ print $6,-$3,$4+$5}' temp_tomo.txt  | gmt blockmean $bound_cross2 -I.5/.5 -C > temp1.xyz
gmt surface temp1.xyz -I0.05/0.05  $bound_cross2 -Gtemp1.grd  
gmt grd2cpt temp1.grd  -C$cptpath/temper.cpt -I  -M -S$crange > tomo.cpt
gmt grdimage temp1.grd -Ctomo.cpt $bound_cross $proj_cross -O -K  >> $output

#Masking by semblance
awk '{print $1,$2,$3,$4}'   $modelpath/semblance_average_chk20_coord_comb.dat | gmt project -C$A3 -E$B3 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_sem.txt
awk '{ if ( $4>=0.65 ) print $5,-$3,$4}' temp_sem.txt | gmt psmask  $bound_cross -I5/1 -S1  $proj_cross  -O -K -N -Gwhite >>$output
gmt psmask   -C  -O -K  >>$output

#Plotting earthquakes
awk '{print $8,$7,$9}' $eqpath/catalog_hypodd_puna_crust_v5.txt | gmt project -C$A3 -E$B3 -Fxyzpqrs -W-5/5  -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross $Bcross -Sc0.07  -Gred  -P  -W0.05p -O -K >> $output

#Plotting topography
gmt project -C$A3 -E$B3 -G.2  -Q > topo.xy
gmt grdtrack topo.xy -G$grdpath/dem_puna_resamp.grd > topo.xz
# Padding top and bottom numbers with y value 0 to color the topography
head -1 topo.xz | awk '{print $1, $2, $3, 0}' > top
tail -1 topo.xz | awk '{print $1, $2, $3, 0}' > bottom
cat topo.xz >> top
cat bottom >> top
mv top topo.xz
rm -f bottom
awk '{print $3, 0.2 + $4/1000.0}' topo.xz | gmt psxy $proj_cross $bound_cross $Bcross   -O -K -V  >> $output

#Plotting vents
awk '{print $1,$2}' $plotdatapath/puna_mafic_vents.txt | gmt project -C$A3 -E$B3 -Fxypqrs -W-5/5  -Lw -Q > temp_sa.txt
awk '{print $3,4.1}' temp_sa.txt | gmt psxy $proj_cross $bound_cross $Bcross -Ss0.15  -Gorange -P  -W0.08p -O -K >> $output
#Plotting VOLCANO
awk '{print $2,$1,$3}' $plotdatapath/holocene_volcano.txt > temp_volcano.txt
awk '{print $2,$1,$3}' $plotdatapath/pliestocene_volcano.txt >> temp_volcano.txt
gmt project temp_volcano.txt -C$A3 -E$B3 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_galloc.txt
awk '{print $4, $3/1000.0}' temp_galloc.txt | gmt psxy $proj_cross $bound_cross -St0.15 -Gmagenta -W0.01,black -O -K    >> $output

#Plotting scale and marker
echo " 5 5.2 A3" | gmt pstext $proj_cross $bound_cross -F+f5  -W0.4p -O -K >> $output
echo " 213 5.2 B3" | gmt pstext $proj_cross $bound_cross -F+f5  -W0.4p -O -K >> $output

##########################CROSS-SECTION 4##################################
A4="-68.3/-26.75"
B4="-66.1/-26.75"

gmt psbasemap  $proj_cross $bound_cross $Bcross -O -P -Y-2.1 -K >> $output
	
#Plotting velocity model	
awk '{print $1,$2,$3,$4,$5}'  $modelpath/velmodel_coord_s.dat | gmt project -C$A4 -E$B4 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_tomo.txt
awk '{ print $6,-$3,$4+$5}' temp_tomo.txt  | gmt blockmean $bound_cross2 -I1/1 -C > temp1.xyz
gmt surface temp1.xyz -I0.05/0.05  $bound_cross2 -Gtemp1.grd  
gmt grd2cpt temp1.grd  -C$cptpath/temper.cpt -I  -M -S$crange > tomo.cpt
gmt grdimage temp1.grd -Ctomo.cpt $bound_cross $proj_cross -O -K  >> $output

#Masking by semblance
awk '{print $1,$2,$3,$4}'   $modelpath/semblance_average_chk20_coord_comb.dat | gmt project -C$A4 -E$B4 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_sem.txt
awk '{ if ( $4>=0.65 ) print $5,-$3,$4}' temp_sem.txt | gmt psmask  $bound_cross -I5/1 -S1  $proj_cross  -O -K -N -Gwhite >>$output
gmt psmask   -C  -O -K  >>$output

#Plotting earthquakes
awk '{print $8,$7,$9}' $eqpath/catalog_hypodd_puna_crust_v5.txt | gmt project -C$A4 -E$B4 -Fxyzpqrs -W-5/5  -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross $Bcross -Sc0.07  -Gred -P  -W0.05p -O -K >> $output

#Plotting topography
gmt project -C$A4 -E$B4 -G.2  -Q > topo.xy
gmt grdtrack topo.xy -G$grdpath/dem_puna_resamp.grd > topo.xz
# Padding top and bottom numbers with y value 0 to color the topography
head -1 topo.xz | awk '{print $1, $2, $3, 0}' > top
tail -1 topo.xz | awk '{print $1, $2, $3, 0}' > bottom
cat topo.xz >> top
cat bottom >> top
mv top topo.xz
rm -f bottom
awk '{print $3, 0.15 + $4/1000.0}' topo.xz | gmt psxy $proj_cross $bound_cross $Bcross   -O -K -V  >> $output

#Plotting vents
awk '{print $1,$2}' $plotdatapath/puna_mafic_vents.txt | gmt project -C$A4 -E$B4 -Fxypqrs -W-5/5  -Lw -Q > temp_sa.txt
awk '{print $3,4.1}' temp_sa.txt | gmt psxy $proj_cross $bound_cross $Bcross -Ss0.15  -Gorange -P  -W0.08p -O -K >> $output
#Plotting volcano
awk '{print $2,$1,$3}' $plotdatapath/holocene_volcano.txt > temp_volcano.txt
awk '{print $2,$1,$3}' $plotdatapath/pliestocene_volcano.txt >> temp_volcano.txt
gmt project temp_volcano.txt -C$A4 -E$B4 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_galloc.txt
awk '{print $4,$3/1000.0}' temp_galloc.txt | gmt psxy $proj_cross $bound_cross -St0.15 -Gmagenta -W0.01,black -O -K    >> $output

#Plotting scale and marker
echo " 5 5.2 A4" | gmt pstext $proj_cross $bound_cross -F+f5 -W0.4p -O -K >> $output
echo " 213 5.2 B4" | gmt pstext $proj_cross $bound_cross -F+f5  -W0.4p -O -K >> $output

##########################CROSS-SECTION 5##################################
A5="-68.3/-27.0"
B5="-66.1/-27.0"

gmt psbasemap  $proj_cross $bound_cross $Bcross2 -O -P -Y-2.1 -K >> $output
	
#Plotting velocity model	
awk '{print $1,$2,$3,$4,$5}' $modelpath/velmodel_coord_s.dat | gmt project -C$A5 -E$B5 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_tomo.txt
awk '{ print $6,-$3,$4+$5}' temp_tomo.txt  | gmt blockmean $bound_cross2 -I1/1 -C > temp1.xyz
gmt surface temp1.xyz -I0.05/0.05  $bound_cross2 -Gtemp1.grd  
gmt grd2cpt temp1.grd  -C$cptpath/temper.cpt -I  -M -S$crange > tomo.cpt
gmt grdimage temp1.grd -Ctomo.cpt $bound_cross $proj_cross -O -K  >> $output

#Masking by semblance
awk '{print $1,$2,$3,$4}' $modelpath/semblance_average_chk20_coord_comb.dat | gmt project -C$A5 -E$B5 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_sem.txt
awk '{ if ( $4>=0.65 ) print $5,-$3,$4}' temp_sem.txt | gmt psmask  $bound_cross -I5/1 -S1  $proj_cross  -O -K -N -Gwhite >>$output
gmt psmask   -C  -O -K  >>$output

#Plotting earthquakes
awk '{print $8,$7,$9}' $eqpath/catalog_hypodd_puna_crust_v5.txt | gmt project -C$A5 -E$B5 -Fxyzpqrs -W-5/5  -Lw -Q > temp_sa.txt
awk '{print $4,-$3}' temp_sa.txt | gmt psxy $proj_cross $bound_cross $Bcross2 -Sc0.07  -Gred -P  -W0.05p -O -K >> $output

#Plotting topography
gmt project -C$A5 -E$B5 -G.2  -Q > topo.xy
gmt grdtrack topo.xy -G$grdpath/dem_puna_resamp.grd > topo.xz
# Padding top and bottom numbers with y value 0 to color the topography
head -1 topo.xz | awk '{print $1, $2, $3, 0}' > top
tail -1 topo.xz | awk '{print $1, $2, $3, 0}' > bottom
cat topo.xz >> top
cat bottom >> top
mv top topo.xz
rm -f bottom
awk '{print $3, 0.15 + $4/1000.0}' topo.xz | gmt psxy $proj_cross $bound_cross $Bcross2   -O -K -V  >> $output

#Plotting vents
awk '{print $1,$2}' $plotdatapath/puna_mafic_vents.txt | gmt project -C$A5 -E$B5 -Fxypqrs -W-5/5  -Lw -Q > temp_sa.txt
awk '{print $3,4.1}' temp_sa.txt | gmt psxy $proj_cross $bound_cross -Ss0.15  -Gorange -P  -W0.08p -O -K >> $output
#Plotting volcano
awk '{print $2,$1,$3}' $plotdatapath/holocene_volcano.txt > temp_volcano.txt
awk '{print $2,$1,$3}' $plotdatapath/pliestocene_volcano.txt >> temp_volcano.txt
gmt project temp_volcano.txt -C$A5 -E$B5 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_galloc.txt
awk '{print $4,$3/1000.0}' temp_galloc.txt | gmt psxy $proj_cross $bound_cross -St0.15 -Gmagenta -W0.01,black -O -K    >> $output

#Plotting scale and marker
echo " 5 5.2 A5" | gmt pstext $proj_cross $bound_cross -F+f5 -W0.4p -O -K >> $output
echo " 213 5.2 B5" | gmt pstext $proj_cross $bound_cross -F+f5  -W0.4p -O -K >> $output

#color scale
gmt psscale -Dx2.0/-1+w3.2/0.3+h+e -Ctomo.cpt -Ba0.2+l"Vs(km/s)" -G3.0/3.88 -O -K  >> $output

echo "0 0" | gmt psxy -Sc0.001 $proj_cross $bound_cross -O >> $output

gmt psconvert -A1 -Tg -E400 $output
gmt psconvert -A1 -Tf -E400 $output

rm *.xy *.xz *.txt  *.grd *.cpt *.xyz *.ps
