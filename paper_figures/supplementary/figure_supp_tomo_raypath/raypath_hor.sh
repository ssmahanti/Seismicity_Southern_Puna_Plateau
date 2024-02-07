#Script for plotting raypaths:

#Defaults
gmt set MAP_FRAME_TYPE plain
gmt set MAP_FRAME_WIDTH 5p
gmt set MAP_TICK_PEN_PRIMARY 1p
gmt set FONT_ANNOT_PRIMARY 10p,Helvetica,black
gmt set FORMAT_GEO_MAP = D
gmt set PS_PAGE_ORIENTATION LANDSCAPE

bound_map="-R-69.5/-65.5/-28.5/-25"
proj_map="-JM3i"
bmap="-Ba1f.2:""::,:/a1f.2:""::,:WeSn"

stationpath="/Users/sankha/Desktop/research/Spuna_plateau/station"
plotdatapath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/plotdata"
grdpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/grdfiles"
cptpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/cptfiles"
modelpath="/Users/sankha/Desktop/research/Spuna_plateau/lotos/output"
output="hor_raypath_P.ps"

gmt makecpt -T0/5500/50 -D -C$cptpath/natural.cpt > topo2.cpt
#plot raypath and topography

gmt grdgradient $grdpath/dem_puna_resamp.grd -Nt1 -A45 -Gtemp_puna.grd

for ((i=1;i<=4;i++))  #four subplots
do
	gmt set FONT_ANNOT_PRIMARY 10p,Helvetica,black
	shiftx=-X9.5
	shifty=-Y8.5
	shiftx2=-X-9.5
	shifty2=-Y-8.5
	if [ $i == 1 ]
	then
		gmt psbasemap  $proj_map $bound_map $bmap $shifty -K > $output
	elif [ $i == 3 ]
	then 
		gmt psbasemap  $proj_map $bound_map $bmap $shifty2 $shiftx2  -O -K >> $output
	else
		gmt psbasemap  $proj_map $bound_map $bmap $shiftx   -O -K >> $output
	fi

	gmt grdimage $grdpath/dem_puna_resamp.grd -Itemp_puna.grd -Ctopo2.cpt $bound_map -t40 $proj_map -O -K >> $output
	gmt psxy $modelpath/rays/rays_hor1$i.dat $proj_map $bound_map -Sc0.01 -Ggray55  -O -K >>$output #raypaths
	awk '{print $1,$2}' $stationpath/spuna_stations.txt | gmt psxy $proj_map $bound_map -Sd0.15 -W0.01p,black -Gcyan -O -K >>$output #stations
	
	#cross-section lines
	if [ $i == 1 ]
	then
		echo -68.3 -25.93 "A1" >tmp_map.txt
		echo -65.9 -25.93 "B1" >>tmp_map.txt
		echo ">>" >> tmp_map.txt
		echo -68.3 -26.15 "A2" >>tmp_map.txt
		echo -65.9 -26.15 "B2" >>tmp_map.txt
		echo ">>" >> tmp_map.txt
		echo -68.3 -26.42 "A3" >>tmp_map.txt
		echo -65.9 -26.42 "B3" >>tmp_map.txt
		echo ">>" >> tmp_map.txt
		echo -68.3 -26.75 "A4" >>tmp_map.txt
		echo -65.9 -26.75 "B4" >>tmp_map.txt
		echo ">>" >> tmp_map.txt
		echo -68.3 -27.00 "A5" >>tmp_map.txt
		echo -65.9 -27.00 "B5" >>tmp_map.txt
		gmt psxy $proj_map $bound_map tmp_map.txt -W0.4p,magenta,- -Gblack -O -K >> $output
		gmt pstext $proj_map $bound_map tmp_map.txt -W0.5p,magenta -Gwhite -O -K >> $output
	fi
	pensize=0.3	
	k2=$(( (i-1)*5 ))
	echo -67.4 -25.2 "Depth=$k2 km" | gmt pstext -F+f10+a0+jCM $proj_map $bound_map -O -K -W0.5p,black -Gwhite >> $output
done

echo "0 0" | gmt psxy -Sc0.001 $proj_map $bound_map -O >> $output
gmt psconvert -A1 -Tg -E500 $output
rm *.grd *.cpt *.txt *.xyz *.ps