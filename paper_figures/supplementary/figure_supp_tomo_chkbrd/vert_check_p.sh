#Script to plot checkerboards in cross-sections: P

gmt gmtset PAPER_MEDIA = A2
gmt gmtset FONT_ANNOT_PRIMARY = 6p,Helvetica,black
gmt gmtset FONT_LABEL		= 6p

proj_cross=" -JX3i/0.9i"
Bcross="-Ba50f10:"Distance-km"::,:/a3f1:"Depth-km"::,:WeSn"
bound_cross="-R0/218/-20/7"
bound_cross2="-R0/218/-20/3"

stationpath="/Users/sankha/Desktop/research/Spuna_plateau/station"
plotdatapath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/plotdata"
grdpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/grdfiles"
cptpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/cptfiles"
modelpath="/Users/sankha/Desktop/research/Spuna_plateau/lotos/output"

output="checkerboard_20_cross_p.ps"

gmt makecpt -T-10/10/1 -C$cptpath/tomo_lotos.cpt -I -M > tomo.cpt
	
#################################Cross-section 1#####################################
A1="-68.3/-26.05"
B1="-66.1/-26.05"

gmt psbasemap  $proj_cross $bound_cross $Bcross  -P -Y15 -K > $output
	
#Plotting velocity model	
awk '{print $1,$2,$3,$6}'  $modelpath/checkerboard_20_coord_p.dat | gmt project -C$A1 -E$B1 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_tomo.txt
awk '{print $5,-$3,$4}' temp_tomo.txt  | gmt blockmean $bound_cross2 -I1/1 -C > temp1.xyz
gmt surface temp1.xyz -I0.05/0.05  $bound_cross2 -Gtemp1.grd  
gmt grd2cpt temp1.grd  -C$cptpath/tomo_lotos.cpt  -M -S-10/10/1 > tomo.cpt
gmt grdimage temp1.grd -Ctomo.cpt $bound_cross $proj_cross -O -K  >> $output

#input contour
awk '{print $1,$2,$3,$4}'  $modelpath/checkerboard_20_coord_input.dat | gmt project -C$A1 -E$B1 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_sem.txt
awk '{print $5,-$3,$4}' temp_sem.txt | gmt xyz2grd  -I4/1 -Gtemp_sem.grd $bound_cross
gmt grdcontour temp_sem.grd $proj_cross -C+1  -O -K -W0.2,black,- >>$output
gmt grdcontour temp_sem.grd $proj_cross -C+-1  -O -K -W0.2,black,- >>$output

#contour
awk '{print $1,$2,$3,$4}'  $modelpath/semblance_average_chk20_coord_comb.dat | gmt project -C$A1 -E$B1 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_sem.txt
awk '{print $5,-$3,$4}' temp_sem.txt | gmt xyz2grd  -I4/1 -Gtemp_sem.grd $bound_cross
gmt grdcontour temp_sem.grd $proj_cross -C+0.65  -O -K -W0.2,black >>$output

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

#Plotting volcano
awk '{print $2,$1,$3}' $plotdatapath/holocene_volcano.txt > temp_volcano.txt
awk '{print $2,$1,$3}' $plotdatapath/pliestocene_volcano.txt >> temp_volcano.txt
gmt project temp_volcano.txt -C$A1 -E$B1 -W-10/10 -Fxyzpqrs -Lw -Q  > temp_galloc.txt
awk '{print $4, $3/1000.0}' temp_galloc.txt | gmt psxy $proj_cross $bound_cross -St0.2 -Gmagenta -W0.01,black -O -K    >> $output

#Plotting scale and marker
echo " 5 5.2 A1" | gmt pstext $proj_cross $bound_cross -F+f7  -W0.4p -O -K >> $output
echo " 213 5.2 B1" | gmt pstext $proj_cross $bound_cross -F+f7  -W0.4p -O -K >> $output
	
#####################Cross-section 2####################################
A2="-68.3/-26.26"
B2="-66.1/-26.26"

gmt psbasemap  $proj_cross $bound_cross $Bcross -O -P -Y-3 -K >> $output
	
#Plotting velocity model	
awk '{print $1,$2,$3,$6}'  $modelpath/checkerboard_20_coord_p.dat | gmt project -C$A2 -E$B2 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_tomo.txt
awk '{print $5,-$3,$4}' temp_tomo.txt  | gmt blockmean $bound_cross2 -I1/1 -C > temp1.xyz
gmt surface temp1.xyz -I0.05/0.05  $bound_cross2 -Gtemp1.grd  
gmt grd2cpt temp1.grd  -C$cptpath/tomo_lotos.cpt  -M -S-10/10/1 > tomo.cpt
gmt grdimage temp1.grd -Ctomo.cpt $bound_cross $proj_cross -O -K  >> $output

#input contour
awk '{print $1,$2,$3,$4}'  $modelpath/checkerboard_20_coord_input.dat | gmt project -C$A2 -E$B2 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_sem.txt
awk '{print $5,-$3,$4}' temp_sem.txt | gmt xyz2grd  -I4/1 -Gtemp_sem.grd $bound_cross
gmt grdcontour temp_sem.grd $proj_cross -C+1  -O -K -W0.2,black,- >>$output
gmt grdcontour temp_sem.grd $proj_cross -C+-1  -O -K -W0.2,black,- >>$output

#semblance contour
awk '{print $1,$2,$3,$4}'  $modelpath/semblance_average_chk20_coord_comb.dat | gmt project -C$A2 -E$B2 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_sem.txt
awk '{print $5,-$3,$4}' temp_sem.txt | gmt xyz2grd  -I4/1 -Gtemp_sem.grd $bound_cross
gmt grdcontour temp_sem.grd $proj_cross -C+0.65  -O -K -W0.2,black >>$output

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

#Plotting volcano
awk '{print $2,$1,$3}' $plotdatapath/holocene_volcano.txt > temp_volcano.txt
awk '{print $2,$1,$3}' $plotdatapath/pliestocene_volcano.txt >> temp_volcano.txt
gmt project temp_volcano.txt -C$A2 -E$B2  -W-5/5 -Fxyzpqrs -Lw -Q  > temp_galloc.txt
awk '{print $4, $3/1000.0}' temp_galloc.txt | gmt psxy $proj_cross $bound_cross -St0.2 -Gmagenta -W0.01,black -O -K    >> $output

#Plotting scale and marker
echo " 5 5.2 A2" | gmt pstext $proj_cross $bound_cross -F+f7  -W0.4p -O -K >> $output
echo " 213 5.2 B2" | gmt pstext $proj_cross $bound_cross -F+f7  -W0.4p -O -K >> $output

#####################Cross-section 3####################################
A3="-68.3/-26.42"
B3="-66.1/-26.42"

gmt psbasemap  $proj_cross $bound_cross $Bcross -O -P -Y-3 -K >> $output
	
#Plotting velocity model	
awk '{print $1,$2,$3,$6}'  $modelpath/checkerboard_20_coord_p.dat | gmt project -C$A3 -E$B3 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_tomo.txt
awk '{ print $5,-$3,$4}' temp_tomo.txt  | gmt blockmean $bound_cross2 -I0.5/0.5 -C > temp1.xyz
gmt surface temp1.xyz -I0.05/0.05  $bound_cross2 -Gtemp1.grd  
gmt grd2cpt temp1.grd  -C$cptpath/tomo_lotos.cpt  -M -S-10/10/1 > tomo.cpt
gmt grdimage temp1.grd -Ctomo.cpt $bound_cross $proj_cross -O -K  >> $output

#input contour
awk '{print $1,$2,$3,$4}'  $modelpath/checkerboard_20_coord_input.dat | gmt project -C$A3 -E$B3 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_sem.txt
awk '{print $5,-$3,$4}' temp_sem.txt | gmt xyz2grd  -I4/1 -Gtemp_sem.grd $bound_cross
gmt grdcontour temp_sem.grd $proj_cross -C+1  -O -K -W0.2,black,- >>$output
gmt grdcontour temp_sem.grd $proj_cross -C+-1  -O -K -W0.2,black,- >>$output

#contour
awk '{print $1,$2,$3,$4}'  $modelpath/semblance_average_chk20_coord_comb.dat | gmt project -C$A3 -E$B3 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_sem.txt
awk '{print $5,-$3,$4}' temp_sem.txt | gmt xyz2grd  -I4/1 -Gtemp_sem.grd $bound_cross
gmt grdcontour temp_sem.grd $proj_cross -C+0.65  -O -K -W0.2,black >>$output

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

#Plotting volcano
awk '{print $2,$1,$3}' $plotdatapath/holocene_volcano.txt > temp_volcano.txt
awk '{print $2,$1,$3}' $plotdatapath/pliestocene_volcano.txt >> temp_volcano.txt
gmt project temp_volcano.txt -C$A3 -E$B3 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_galloc.txt
awk '{print $4, $3/1000.0}' temp_galloc.txt | gmt psxy $proj_cross $bound_cross -St0.2 -Gmagenta -W0.01,black -O -K    >> $output

#Plotting scale and marker
echo " 5 5.2 A3" | gmt pstext $proj_cross $bound_cross -F+f7  -W0.4p -O -K >> $output
echo " 213 5.2 B3" | gmt pstext $proj_cross $bound_cross -F+f7  -W0.4p -O -K >> $output

#####################Cross-section 4####################################
A4="-68.3/-26.8"
B4="-66.1/-26.8"

gmt psbasemap  $proj_cross $bound_cross $Bcross -O -P -Y-3 -K >> $output
	
#Plotting velocity model	
awk '{print $1,$2,$3,$6}' $modelpath/checkerboard_20_coord_p.dat | gmt project -C$A4 -E$B4 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_tomo.txt
awk '{ print $5,-$3,$4}' temp_tomo.txt  | gmt blockmean $bound_cross2 -I1/1 -C > temp1.xyz
gmt surface temp1.xyz -I0.05/0.05  $bound_cross2 -Gtemp1.grd  
gmt grd2cpt temp1.grd  -C$cptpath/tomo_lotos.cpt  -M -S-10/10/1 > tomo.cpt
gmt grdimage temp1.grd -Ctomo.cpt $bound_cross $proj_cross -O -K  >> $output

#input contour
awk '{print $1,$2,$3,$4}'  $modelpath/checkerboard_20_coord_input.dat | gmt project -C$A4 -E$B4 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_sem.txt
awk '{print $5,-$3,$4}' temp_sem.txt | gmt xyz2grd  -I4/1 -Gtemp_sem.grd $bound_cross
gmt grdcontour temp_sem.grd $proj_cross -C+1  -O -K -W0.2,black,- >>$output
gmt grdcontour temp_sem.grd $proj_cross -C+-1  -O -K -W0.2,black,- >>$output

#contour
awk '{print $1,$2,$3,$4}'  $modelpath/semblance_average_chk20_coord_comb.dat | gmt project -C$A4 -E$B4 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_sem.txt
awk '{print $5,-$3,$4}' temp_sem.txt | gmt xyz2grd  -I4/1 -Gtemp_sem.grd $bound_cross
gmt grdcontour temp_sem.grd $proj_cross -C+0.65 -O -K -W0.2,black >>$output


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

#Plotting volcano
awk '{print $2,$1,$3}' $plotdatapath/holocene_volcano.txt > temp_volcano.txt
awk '{print $2,$1,$3}' $plotdatapath/pliestocene_volcano.txt >> temp_volcano.txt
gmt project temp_volcano.txt -C$A4 -E$B4 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_galloc.txt
awk '{print $4,$3/1000.0}' temp_galloc.txt | gmt psxy $proj_cross $bound_cross -St0.2 -Gmagenta -W0.01,black -O -K    >> $output

#Plotting scale and marker
echo " 5 5.2 A4" | gmt pstext $proj_cross $bound_cross -F+f7 -W0.4p -O -K >> $output
echo " 213 5.2 B4" | gmt pstext $proj_cross $bound_cross -F+f7  -W0.4p -O -K >> $output


#####################Cross-section 5####################################
A5="-68.3/-27.0"
B5="-66.1/-27.0"

gmt psbasemap  $proj_cross $bound_cross $Bcross -O -P -Y-3 -K >> $output
	
#Plotting velocity model	
awk '{print $1,$2,$3,$6}' $modelpath/checkerboard_20_coord_p.dat | gmt project -C$A5 -E$B5 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_tomo.txt
awk '{ print $5,-$3,$4}' temp_tomo.txt  | gmt blockmean $bound_cross2 -I1/1 -C > temp1.xyz
gmt surface temp1.xyz -I0.05/0.05  $bound_cross2 -Gtemp1.grd  
gmt grd2cpt temp1.grd  -C$cptpath/tomo_lotos.cpt  -M -S-10/10/1 > tomo.cpt
gmt grdimage temp1.grd -Ctomo.cpt $bound_cross $proj_cross -O -K  >> $output

#input contour
awk '{print $1,$2,$3,$4}'  $modelpath/checkerboard_20_coord_input.dat | gmt project -C$A5 -E$B5 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_sem.txt
awk '{print $5,-$3,$4}' temp_sem.txt | gmt xyz2grd  -I4/1 -Gtemp_sem.grd $bound_cross
gmt grdcontour temp_sem.grd $proj_cross -C+1  -O -K -W0.2,black,- >>$output
gmt grdcontour temp_sem.grd $proj_cross -C+-1  -O -K -W0.2,black,- >>$output

#contour
awk '{print $1,$2,$3,$4}'  $modelpath/semblance_average_chk20_coord_comb.dat | gmt project -C$A5 -E$B5 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_sem.txt
awk '{print $5,-$3,$4}' temp_sem.txt | gmt xyz2grd  -I4/1 -Gtemp_sem.grd $bound_cross
gmt grdcontour temp_sem.grd $proj_cross -C+0.65  -O -K -W0.2,black >>$output


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
awk '{print $3, 0.15 + $4/1000.0}' topo.xz | gmt psxy $proj_cross $bound_cross $Bcross   -O -K -V  >> $output

#Plotting volcano
awk '{print $2,$1,$3}' $plotdatapath/holocene_volcano.txt > temp_volcano.txt
awk '{print $2,$1,$3}' $plotdatapath/pliestocene_volcano.txt >> temp_volcano.txt
gmt project temp_volcano.txt -C$A5 -E$B5 -Fxyzpqrs -W-5/5  -Lw -Q  > temp_galloc.txt
awk '{print $4,$3/1000.0}' temp_galloc.txt | gmt psxy $proj_cross $bound_cross -St0.2 -Gmagenta -W0.01,black -O -K    >> $output

#Plotting scale and marker
echo " 5 5.2 A5" | gmt pstext $proj_cross $bound_cross -F+f7 -W0.4p -O -K >> $output
echo " 213 5.2 B5" | gmt pstext $proj_cross $bound_cross -F+f7  -W0.4p -O -K >> $output

###############################################################
gmt psscale -Dx2.6/-1+w2.4/0.3+h+e -Ctomo.cpt -Ba3+l"dVp(%)" -G-10/10 -O -K  >> $output

echo "0 0" | gmt psxy -Sc0.001 $proj_cross $bound_cross -O >> $output
gmt psconvert -A1 -Tg -E500 $output
gmt psconvert -A1 -Tf -E500 $output

rm *.xy *.xz  *.ps *.xyz *.grd *.cpt *.txt

