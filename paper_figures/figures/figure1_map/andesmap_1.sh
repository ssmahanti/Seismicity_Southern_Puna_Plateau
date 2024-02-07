#Script to plot figure 1a:
#set configuration parameters
gmt gmtset MAP_FRAME_TYPE plain
gmt gmtset MAP_FRAME_WIDTH 2p
gmt gmtset FONT_ANNOT_PRIMARY 10p,Helvetica,black
gmt gmtset FORMAT_GEO_MAP=D
gmt gmtset FONT_LABEL		= 10p

#GMT projection, boundary
proj="-JM5i"
range="-R-80/-50/-40/-10"
B="-Ba5f5:::,:/a5f5:::,:WeSn"

#filepaths
stationpath="/Users/sankha/Desktop/research/Spuna_plateau/station"
plotdatapath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/plotdata"
grdpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/grdfiles"


output="andesmap_1.ps"

#cpt files
gmt makecpt -T-12000/6000/50 -D -Cgeo > topo2.cpt

#plot map and topography
gmt psbasemap $proj $range $B  -K >  $output
gmt grdcut $grdpath/ETOPO1.grd -GSAM.grd $range
gmt grdimage $grdpath/ETOPO1.grd  -Ctopo2.cpt  $range $proj -O -K -t20>>$output
gmt pscoast $proj $range  -N1/0.25p  -O -K >> $output

#slab 2.0
gmt grdcontour $grdpath/sam_slab2.grd $range $proj -W0.5,PURPLE -C50 -A100+f6 -Gl-75/-30/-60/-30 -K -O >> $output
#Volcanoes
awk '{print $2,$1}' $plotdatapath/holocene_volcano.txt | gmt psxy $proj $range -St0.25 -W0.13p,black -Gmagenta -O -K >>$output
#Earthquakes from ISC-EHB Bulletin
awk '{ if ($5>200) print $4,$3}' $plotdatapath/isc_ehb_andes.txt | gmt psxy $proj $range -Sc0.097 -W0.12p,black -Gred -O -K >>$output

#Plot trench
gap=0.6
size=0.06
gmt psxy $plotdatapath/trench.txt $proj $range  -W1p,black  -Sf${gap}i/${size}i+l+t -G0 -O -K >> $output

#Box for southern Puna
gmt psxy $proj $range -W1.5,black -O -K << EOF >> $output
-69.5 -25
-66.5 -25
-66.5 -28.5
-69.5 -28.5
-69.5 -25
EOF

#Plot scale
gmt gmtset FONT_ANNOT_PRIMARY 8p,Helvetica,black
gmt gmtset FONT_LABEL		= 8p
gmt gmtset MAP_LABEL_OFFSET		= 2p
gmt psbasemap  $proj $range  -LjBL+c27S+w400k+l+ab+f+o0.2c/0.8c -P  -O -K>> $output

echo "0 0" | gmt psxy $proj $range -St0.001 -W0.2p,black -Gwhite -O  >>$output

gmt psconvert -Tf -E300 $output -A1
gmt psconvert -Tg -E300 $output -A1

#######################################################################################################
#Plot the inset globe

output2="globe.ps"

gmt pscoast -Rg -JG-60/-10/3i -B30g15 -Dc -A5000 -Ggray -SGray100 -P  -K > $output2
#Boundary
gmt psxy -Rg -JG-60/-10/3i -W1.5,red -O  << EOF >> $output2
-80 -10
-50 -10
-50 -40
-80 -40
-80 -10
EOF

gmt psconvert -Tf -A1 $output2 

rm *.grd *.cpt *.ps *.txt
