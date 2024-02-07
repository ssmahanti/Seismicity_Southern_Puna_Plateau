#Plotting script for P-T axis on the map

gmt gmtset MAP_FRAME_TYPE="plain"
gmt gmtset PAPER_MEDIA = A3
gmt gmtset FONT_ANNOT_PRIMARY = 12p,Helvetica,black
gmt gmtset FONT_LABEL		= 12p

#filepaths
stationpath="/Users/sankha/Desktop/research/Spuna_plateau/station"
plotdatapath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/plotdata"
grdpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/grdfiles"
cptpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/cptfiles"

#change filename as required
output="eventmap_axes_v2.ps"

#############plot of basemap and topography#######################################################
bound_map="-R-69.5/-65.3/-28.5/-25"
proj_map="-JM8i"
bmap="-Ba1f.5:""::,:/a1f.5:""::,:WeSn"

gmt psbasemap  $proj_map $bound_map $bmap -P -K > $output
gmt grdgradient $grdpath/dem_puna_resamp.grd -Nt1 -A75 -Gtemp_puna.grd
gmt grdimage $grdpath/dem_puna_resamp.grd -Itemp_puna.grd -C$cptpath/white2.cpt $bound_map $proj_map  -O -K -t25>> $output

##Stations and volcanoes
awk '{print $1,$2}' $stationpath/spuna_stations.txt | gmt psxy $proj_map $bound_map -Sd0.35 -Gcyan -W0.4p,black -O -K >>$output
awk '{print $2,$1}' $plotdatapath/holocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.38 -W0.2p,black -Gmagenta -O -K >>$output
awk '{print $2,$1}' $plotdatapath/pliestocene_volcano.txt | gmt psxy $proj_map $bound_map -St0.38 -W0.2p,black -Gmagenta -O -K >>$output

awk '{print $2,$3}' focmec_axes_v2.dat | gmt psxy $proj_map $bound_map -Sc0.08 -W0.1 -O -GBLACK  -K>> $output

awk '{ if ($12<45 && $12>-45 ) print $2,$3,$11,0.6}' focmec_axes_v2.dat | gmt psxy $proj_map $bound_map -SV11P+jb+eai -O -Gred -W0.5p -K>> $output
awk '{ if ($12<45 && $12>-45 ) print $2,$3,$11-180,0.6}' focmec_axes_v2.dat | gmt psxy $proj_map $bound_map -SV11P+jb+ea -O -Gred  -W0.5p -K>> $output

awk '{ if ($10<45 && $10>-45 ) print $2,$3,$9,0.5}' focmec_axes_v2.dat | gmt psxy $proj_map $bound_map -SV9P+jb+bai -O -Ggreen  -W0.5p -K>> $output
awk '{ if ($10<45 && $10>-45 ) print $2,$3,$9-180,0.5}' focmec_axes_v2.dat | gmt psxy $proj_map $bound_map -SV9P+jb+ba -O -Ggreen  -W0.5p -K>> $output

#white box
gmt psxy  $proj_map $bound_map -W0.7,black -Gwhite -O -K << EOF >> $output
-67.0 -28.1
-67.0 -28.5
-65.3 -28.5
-65.3 -28.1
-67.0 -28.1
EOF

#labels
echo "-66.7 -28.2 90 0.9" | gmt psxy $proj_map $bound_map -SV13P+jb+bai -O -GGREEN -W0.5p -K >> $output
echo "-66.7 -28.2 -90 0.9" | gmt psxy $proj_map $bound_map -SV12P+jb+bai -O -GGREEN -W0.5p -K >> $output

echo "-65.9 -28.2 "P-Axis Direction"" | gmt pstext $proj_map $bound_map -F+f15  -K  -O  >>$output

echo "-66.7 -28.4 90 0.9" | gmt psxy $proj_map $bound_map -SV13P+jb+eai -O -Gred -W0.5p -K >> $output
echo "-66.7 -28.4 -90 0.9" | gmt psxy $proj_map $bound_map -SV13P+jb+eai -O -Gred -W0.5p -K >> $output

echo "-65.9 -28.4 "T-Axis Direction"" | gmt pstext $proj_map $bound_map -F+f15  -K  -O >>$output

gmt gmtset FONT_ANNOT_PRIMARY = 11p,Helvetica,black
gmt gmtset FONT_LABEL		= 11p
gmt gmtset MAP_ANNOT_OFFSET=2p
gmt gmtset MAP_LABEL_OFFSET=1p
gmt psbasemap  $proj_map $bound_map  -LjTR+c27S+w40k+l+ab+f+o0.5c -P  -O >> $output

gmt psconvert -Tg -A1  -E400 $output
gmt psconvert -Tf -A1  -E400 $output

rm *.grd *.cpt *.ps