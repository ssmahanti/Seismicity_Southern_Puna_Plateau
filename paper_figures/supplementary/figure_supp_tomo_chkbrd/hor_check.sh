#Script to plot checkerboard results on the map:

## overriding gmt defaults 
gmt set MAP_FRAME_TYPE plain
gmt set MAP_FRAME_WIDTH 5p
gmt set MAP_TICK_PEN_PRIMARY 1p
gmt set FONT_ANNOT_PRIMARY 8p,Helvetica,black
gmt set FORMAT_GEO_MAP=D
gmt set PS_PAGE_ORIENTATION LANDSCAPE

#Porjection and bounds
bound_map="-R-68.51/-65.68/-28/-25.4"
proj_map="-JM3i"
bmap="-Ba.5f.1:""::,:/a.5f.1:""::,:WeSn"

stationpath="/Users/sankha/Desktop/research/Spuna_plateau/station"
plotdatapath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/plotdata"
grdpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/grdfiles"
cptpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/cptfiles"
modelpath="/Users/sankha/Desktop/research/Spuna_plateau/lotos/output"

output="checkerboard_20208_map_dep1.ps"

###########################################Vp model###############################################################

gmt set FONT_ANNOT_PRIMARY 8p,Helvetica,black	
gmt psbasemap  $proj_map $bound_map $bmap $shifty -K > $output
		
#plot checkerboard
awk '{ if ( $3==1 ) print $1,$2,$6}' $modelpath/checkerboard_20_coord_p.dat | gmt blockmean $bound_map -I.005/.005 -C > temp1.xyz
gmt surface temp1.xyz  -I0.002/0.002   $bound_map -Gtemp1.grd  
gmt grd2cpt temp1.grd  -C$cptpath/tomo_lotos.cpt  -M -S-10/10/1 > tomo.cpt
gmt grdimage temp1.grd -Ctomo.cpt $bound_map $proj_map -O -K  >> $output

 #Semblence contour
awk '{ if ( $3==1 ) print $1,$2,$4 }' $modelpath/semblance_average_chk20_coord_comb.dat | gmt xyz2grd  -I0.05 -Gtemp_sem.grd $bound_map
gmt grdcontour temp_sem.grd $proj_map -C+0.66  -O -K -W0.4,black >>$output

#Input contour
awk '{ if ( $3==1 ) print $1,$2,$4 }' $modelpath/checkerboard_20_coord_input.dat | gmt xyz2grd  -I0.05 -Gtemp_sem.grd $bound_map
gmt grdcontour temp_sem.grd $proj_map -C+1  -O -K -W0.1,black,- >>$output
gmt grdcontour temp_sem.grd $proj_map -C+-1  -O -K -W0.1,black,- >>$output

##Stations and volcanoes
awk '{print $1,$2}' $stationpath/spuna_stations.txt | gmt psxy $proj_map $bound_map -Sd0.18 -Gcyan -W0.2p,black -O -K >>$output
awk '{print $2,$1}' $plotdatapath/holocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.22 -W0.2p,black -Gmagenta -O -K >>$output
awk '{print $2,$1}' $plotdatapath/pliestocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.22 -W0.2p,black -Gmagenta -O -K >>$output

#cross-section lines
echo -68.3 -26.05 "A1" >tmp_map.txt
echo -66.1 -26.05 "B1" >>tmp_map.txt
echo ">>" >> tmp_map.txt
echo -68.3 -26.26 "A2" >>tmp_map.txt
echo -66.1 -26.26 "B2" >>tmp_map.txt
echo ">>" >> tmp_map.txt
echo -68.3 -26.42 "A3" >>tmp_map.txt
echo -66.1 -26.42 "B3" >>tmp_map.txt
echo ">>" >> tmp_map.txt
echo -68.3 -26.8 "A4" >>tmp_map.txt
echo -66.1 -26.8 "B4" >>tmp_map.txt
echo ">>" >> tmp_map.txt
echo -68.3 -27.0 "A5" >>tmp_map.txt
echo -66.1 -27.0 "B5" >>tmp_map.txt
gmt psxy $proj_map $bound_map tmp_map.txt -W0.4p,magenta,-  -O -K>> $output
gmt pstext $proj_map $bound_map tmp_map.txt -F+f7 -W0.1p,magenta -Gwhite -O -K >> $output

#scale
gmt set MAP_FRAME_PEN 0.4p
gmt set MAP_TICK_PEN_PRIMARY 0.4p
gmt set FONT +6p,Helvetica,black
gmt set MAP_TICK_LENGTH 2p
gmt set MAP_ANNOT_OFFSET_PRIMARY 2p
gmt psbasemap  $proj_map $bound_map  -LjRB+c27S+w40k+l+ab+f+o0.4c -P -K -O >> $output
gmt psscale $proj_map $bound_map -Dx2.6/-1.0+w2.6/0.25+h+e -Ctomo.cpt -Ba3+l"dVp(%)" -G-10/10 -O -K  >> $output	
echo -66.5 -25.5 "1 km below sea level" | gmt pstext -F+f10+a0+jCM $proj_map $bound_map -O -K -W0.5p,black -Gwhite >> $output

###########################################Vs model###############################################################

gmt set FONT_ANNOT_PRIMARY 8p,Helvetica,black	
gmt psbasemap  $proj_map $bound_map $bmap $shifty -K -O -X9 >> $output
		
#checkerboard
awk '{ if ( $3==1 ) print $1,$2,$6}' $modelpath/checkerboard_20_coord_s.dat | gmt blockmean $bound_map -I.005/.005 -C > temp1.xyz
gmt surface temp1.xyz  -I0.002/0.002   $bound_map -Gtemp1.grd  
gmt grd2cpt temp1.grd  -C$cptpath/tomo_lotos.cpt  -M -S-10/10/1 > tomo.cpt
gmt grdimage temp1.grd -Ctomo.cpt $bound_map $proj_map -O -K  >> $output

 #Semblence contour
awk '{ if ( $3==1 ) print $1,$2,$4 }' $modelpath/semblance_average_chk20_coord_comb.dat | gmt xyz2grd  -I0.05 -Gtemp_sem.grd $bound_map
gmt grdcontour temp_sem.grd $proj_map -C+0.66  -O -K -W0.4,black >>$output

#Input contour
awk '{ if ( $3==1 ) print $1,$2,$4 }' $modelpath/checkerboard_20_coord_input.dat | gmt xyz2grd  -I0.05 -Gtemp_sem.grd $bound_map
gmt grdcontour temp_sem.grd $proj_map -C+1  -O -K -W0.1,black,- >>$output
gmt grdcontour temp_sem.grd $proj_map -C+-1  -O -K -W0.1,black,- >>$output

##Stations and volcanoes
awk '{print $1,$2}' $stationpath/spuna_stations.txt | gmt psxy $proj_map $bound_map -Sd0.18 -Gcyan -W0.2p,black -O -K >>$output
awk '{print $2,$1}' $plotdatapath/holocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.22 -W0.2p,black -Gmagenta -O -K >>$output
awk '{print $2,$1}' $plotdatapath/pliestocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.22 -W0.2p,black -Gmagenta -O -K >>$output

gmt psxy $proj_map $bound_map tmp_map.txt -W0.4p,magenta,-  -O -K>> $output
gmt pstext $proj_map $bound_map tmp_map.txt -F+f7 -W0.1p,magenta -Gwhite -O -K >> $output

#scale
gmt set MAP_FRAME_PEN 0.4p
gmt set MAP_TICK_PEN_PRIMARY 0.4p
gmt set FONT +6p,Helvetica,black
gmt set MAP_TICK_LENGTH 2p
gmt set MAP_ANNOT_OFFSET_PRIMARY 2p
gmt psbasemap  $proj_map $bound_map  -LjRB+c27S+w40k+l+ab+f+o0.4c -P -K -O >> $output
gmt psscale $proj_map $bound_map -Dx2.6/-1.0+w2.6/0.25+h+e -Ctomo.cpt -Ba3+l"dVs(%)" -G-10/10 -O -K  >> $output	
echo -66.5 -25.5 "1 km below sea level" | gmt pstext -F+f10+a0+jCM $proj_map $bound_map -O -K -W0.5p,black -Gwhite >> $output

echo "0 0" | gmt psxy -Sc0.001 $proj_map $bound_map -O >> $output

gmt psconvert -A1 -Tg -E500 $output
gmt psconvert -A1 -Tf -E500 $output

rm *.grd  *.txt *.xyz *.cpt *.ps
