#Script for plotting raypaths: Vertical

gmt set MAP_FRAME_TYPE plain
gmt set MAP_FRAME_WIDTH 5p
gmt set MAP_TICK_PEN_PRIMARY 1p
gmt set FONT_ANNOT_PRIMARY 10p,Helvetica,black
gmt set PS_PAGE_ORIENTATION LANDSCAPE
gmt set LABEL_FONT 10p,Helvetica,black
gmt set LABEL_OFFSET 0.1c

proj_cross=" -JX4.3i/1.2i"
bound_cross="-R0/240/-30/7"
Bcross="-Ba50f10:"Distance\(km\)"::,:/a5f5:"Depth\(km\)"::,:WeSn"

#filepaths
stationpath="/Users/sankha/Desktop/research/Spuna_plateau/station"
plotdatapath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/plotdata"
grdpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/grdfiles"
cptpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/cptfiles"
modelpath="/Users/sankha/Desktop/research/Spuna_plateau/lotos/output"
output="vert_raypath_P.ps"

k1=0

for i in 1 2 3 4 5
do
	gmt set FONT_ANNOT_PRIMARY 9p,Helvetica,black
	shift2=-Y-4.5
	shift1=-Y20
	if [ $i == 1 ]
	then
		gmt psbasemap  $proj_cross $bound_cross $Bcross $shift1 -P  -K > $output
	else
		gmt psbasemap  $proj_cross $bound_cross $Bcross $shift2 -P -O -K >> $output
	fi
	
	gmt psxy $modelpath/rays/rays_ver1$i.dat $proj_cross $bound_cross -Sc0.1p -Ggray55 -O -K >>$output #rays
	awk '{print $1,$2}' $modelpath/rays/ztr_ver$i.dat | gmt psxy $proj_cross $bound_cross  -Sc0.07 -Gred1 -W0.01p,gray30  -O -K >>$output #events

	pensize=0.5
	k1=$(( k1+1 ))
	echo " 5 -27 A$k1" | gmt pstext $proj_cross $bound_cross -F+f10  -W1p -O -K >> $output
	echo " 235 -27 B$k1" | gmt pstext $proj_cross $bound_cross -F+f10  -W1p -O -K >> $output	
done

echo "0 0" | gmt psxy -Sc0.001 $proj_cross $bound_cross -O >> $output
gmt psconvert -A1 -Tg -E500 $output

rm *.grd *.cpt *.txt *.xyz *.ps