#Script for plotting velocity model on map: S

## overriding gmt defaults
gmt set MAP_FRAME_TYPE plain
gmt set MAP_FRAME_WIDTH 5p
gmt set MAP_TICK_PEN_PRIMARY 1p
gmt set FONT_ANNOT_PRIMARY 8p,Helvetica,black
gmt set PS_PAGE_ORIENTATION LANDSCAPE
gmt set FORMAT_GEO_MAP=D

bound_map="-R-68.51/-65.68/-27.6/-25.5"
proj_map="-JM5i"
bmap="-Ba.5f.1:""::,:/a.5f.1:""::,:WeSn"

eventpath_hypodd="/Users/sankha/Desktop/research/Spuna_plateau/hypodd/output"
stationpath="/Users/sankha/Desktop/research/Spuna_plateau/station"
plotdatapath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/plotdata"
grdpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/grdfiles"
cptpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/cptfiles"
modelpath="/Users/sankha/Desktop/research/Spuna_plateau/lotos/output"

output="velmodel_map_dep1_s.ps"

#Plot
gmt set FONT_ANNOT_PRIMARY 10p,Helvetica,black		
gmt psbasemap  $proj_map $bound_map $bmap $shifty -K > $output

#Plot velocity model		
awk '{ if ( $3==1 ) print $1,$2,$5+$4}' $modelpath/velmodel_coord_s.dat | gmt blockmean $bound_map -I.005/.005 -C > temp1.xyz
gmt surface temp1.xyz  -I0.001/0.001   $bound_map -Gtemp1.grd  
gmt grd2cpt temp1.grd  -C$cptpath/temper.cpt -I  -M -S3.0/3.9/0.02 > tomo.cpt
gmt grdimage temp1.grd -Ctomo.cpt $bound_map $proj_map -O -K  >> $output

#Masking	
awk '{ if ( $3==1 && $4>0.66) print $1,$2,$4}' $modelpath/semblance_average_chk20_coord_comb.dat | gmt psmask  $bound_map -I.1m/.1m -S3k  $proj_map  -O -K -N -Gwhite >>$output
gmt psmask   -C  -O -K  >>$output
   
 #Semblence contour
awk '{ if ( $3==1 ) print $1,$2,$4 }' $modelpath/semblance_average_chk20_coord_comb.dat | gmt xyz2grd  -I0.05 -Gtemp_sem.grd $bound_map
gmt grdcontour temp_sem.grd $proj_map -C+0.66  -O -K -W0.4,black >>$output

#topography
gmt grdcut $grdpath/dem_puna_resamp.grd -Gdem_tmp.grd $bound_map
gmt grdgradient dem_tmp.grd -Nt1 -A75 -Gtemp_puna.grd
gmt grdimage dem_tmp.grd -Itemp_puna.grd -C$cptpath/white2.cpt $bound_map $proj_map  -O -K -t65 >> $output

##Stations and volcanoes
awk '{print $1,$2}' $stationpath/spuna_stations.txt | gmt psxy $proj_map $bound_map -Sd0.18 -Gcyan -W0.2p,black -O -K >>$output
awk '{print $2,$1}' $plotdatapath/holocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.22 -W0.2p,black -Gmagenta -O -K >>$output
awk '{print $2,$1}' $plotdatapath/pliestocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.22 -W0.2p,black -Gmagenta -O -K >>$output
#Earthquakes
awk '{print $8,$7,$9}' $eventpath_hypodd/catalog_hypodd_puna_crust_v5.txt| gmt psxy $proj_map $bound_map -Sc0.08 -W0.01p -Gred -O  -K  >>$output
#vents
gmt psxy $plotdatapath/puna_mafic_vents.txt $proj_map $bound_map  -Ss0.13 -W0.2p,black -Gorange -O -K >>$output

#cross-section lines
echo -68.3 -25.93 "A1" >tmp_map.txt
echo -66.1 -25.93 "B1" >>tmp_map.txt
echo ">>" >> tmp_map.txt
echo -68.3 -26.15 "A2" >>tmp_map.txt
echo -66.1 -26.15 "B2" >>tmp_map.txt
echo ">>" >> tmp_map.txt
echo -68.3 -26.45 "A3" >>tmp_map.txt
echo -66.1 -26.45 "B3" >>tmp_map.txt
echo ">>" >> tmp_map.txt
echo -68.3 -26.75 "A4" >>tmp_map.txt
echo -66.1 -26.75 "B4" >>tmp_map.txt
echo ">>" >> tmp_map.txt
echo -68.3 -27.00 "A5" >>tmp_map.txt
echo -66.1 -27.00 "B5" >>tmp_map.txt
gmt psxy $proj_map $bound_map tmp_map.txt -W0.6p,magenta,-  -O -K>> $output
gmt pstext $proj_map $bound_map tmp_map.txt -F+f9 -W0.1p,magenta -Gwhite -O -K >> $output

#scales
gmt set MAP_FRAME_PEN 0.4p
gmt set MAP_TICK_PEN_PRIMARY 0.4p
gmt set FONT +7p,Helvetica,black
gmt set MAP_TICK_LENGTH 2p
gmt set MAP_ANNOT_OFFSET_PRIMARY 2p
gmt gmtset FONT_ANNOT_PRIMARY = 9p,Helvetica,black
gmt gmtset FONT_LABEL		= 9p

gmt psbasemap  $proj_map $bound_map  -LjBR+c27S+w40k+l+ab+f+o0.9c -P -K -O >> $output
gmt psscale $proj_map $bound_map -Dx4.2/-1.0+w4.2/0.35+h+e -Ctomo.cpt  -Ba0.2+l"Vs(km/s)" -G3.0/3.88 -O -K  >> $output	
echo -66.35 -25.6 "1 km below sea level" | gmt pstext -F+f15+a0+jCM $proj_map $bound_map -O -K -W0.5p,black -Gwhite >> $output

echo "0 0" | gmt psxy -Sc0.001 $proj_map $bound_map -O >> $output

gmt psconvert -A1 -Tg -E500 $output
gmt psconvert -A1 -Tf -E500 $output

rm *.grd  *.txt *.xyz *.cpt *.ps *.xy *.xz
